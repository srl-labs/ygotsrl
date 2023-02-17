# Make target to generate and release ygot-generated Go API for Nokia SR Linux
# usage exmaples:
#
# 1 to generate Go package but not releasing it:
# SRLINUX_VERSION=v21.11.2 RELEASE_SUFFIX=rc1 make generate
# will generate structs for srlinux 21.11.2, create a v21 branch (if needed), initialize Go package and commit and tag the result
#
# 2 to generate Go pacakge and publish it on GitHub:
# SRLINUX_VERSION=v21.11.2 RELEASE_SUFFIX=rc1 make release
# will do everything that `make generate` does plus pushing the files and tags to the remote
#
# Once package is uploaded on Github, one can refresh the Go package cache with:
# GOPROXY=proxy.golang.org go list -m github.com/srl-labs/ygotsrl/v22@v22.11.1-patch1
#
# TODO (rdodin): add link to a tutorial

.DEFAULT_GOAL := help

YGOT_VERSION ?= v0.24.4
WORKDIR = work
OUTDIR = output
GO_PKG_NAME = github.com/srl-labs/ygotsrl
SRL_MAJOR_VER=$(shell echo ${SRLINUX_VERSION} | cut -d . -f 1)

## ONESHELL makes Make to use singe shell sessions for command lines defined in targets.
## We use it here to inline bash scripts, like in remove-invert-match target
.ONESHELL:

release: generate ## Main target that generates and releases Go structs.
	# push generated code upstream as well as all lightweight and annotated tags
	git push --tags origin ${SRL_MAJOR_VER}

generate-and-commit: generate commit-and-tag ## Generate the structs, creates a commit and tag, but doesn't push to remote repo.

generate: install-ygot fetch-srl-yang fix-yang generate-structs checkout-branch create-go-module format ## Generate the structs.

install-ygot: ## Install ygot. The version is read from YGOT_VERSION env var. Defaults to 0.24.4.
	go install github.com/openconfig/ygot/generator@${YGOT_VERSION}

fetch-srl-yang: ## Download SR Linux YANG models for a provided release tag. Release tag is read from SRLINUX_VERSION env var.
	set -e
	test -n "$(SRLINUX_VERSION)" || (echo 'SRLINUX_VERSION is not set. For example, do: SRLINUX_VERSION=v21.11.1 make fetch-srl-yang' && exit 1)
	mkdir -p ${WORKDIR}
	cd ${WORKDIR} && curl -L https://github.com/nokia/srlinux-yang-models/archive/tags/${SRLINUX_VERSION}.tar.gz | tar -xz --strip-components=1

checkout-branch: ## Checkout to the branch matching the SR Linux's major release version.
	set -e
	git fetch --all

	set +e
	git checkout ${SRL_MAJOR_VER}

	if [ $$? -eq 1 ];
	then
		set -e
		echo "branch ${SRL_MAJOR_VER} doesn't exist yet, we will create it"
		git checkout --orphan ${SRL_MAJOR_VER}

		# removing all git checked-in files keeping .gitignore and license files
		# https://stackoverflow.com/questions/36753573/how-do-i-exclude-files-from-git-ls-files
		git rm -rf .github
		git rm -rf Makefile
		git rm -rf README.md
		
		git add .gitignore
		git commit -a -m "Init branch"
	fi
	
	set -e
	git checkout ${SRL_MAJOR_VER}
	# update from remote
	git pull

create-go-module: checkout-branch
	# SRL_MAJOR_VER=$(shell echo ${SRLINUX_VERSION} | cut -d . -f 1)
	# remove single go file that we generated before starting
	# splitting files
	rm -f ygotsrl.go .
	go mod init ${GO_PKG_NAME}/${SRL_MAJOR_VER}
	go mod tidy
	if [ "${SRL_MAJOR_VER}" = "v22" ]; then go get github.com/openconfig/gnmi@v0.0.0-20220617175856-41246b1b3507; fi

commit-and-tag: ## Commit and tag generated structs.
	TAG=${SRLINUX_VERSION}
	# add release suffix if defined
	if [ ! -z "${RELEASE_SUFFIX}" ]; then TAG=$$TAG"-${RELEASE_SUFFIX}"; fi
	echo $$TAG
	git add .
	git commit -a -m "added ${SRLINUX_VERSION} structs"
	git tag $$TAG

fix-yang: remove-invert-match remove-tools-schema ## Top level target that fixes SR Linux YANG to conform with ygot capabilities. Calls targets: remove-invert-match.

remove-invert-match: ## Comment out `invert-match` modifier that is unsupported by goyang.
	if grep -q '^\s*modifier ' ${WORKDIR}/srlinux-yang-models/srl_nokia/models/common/srl_nokia-common.yang; then
		sed -i 's%modifier invert-match%//modifier invert-match%g' ${WORKDIR}/srlinux-yang-models/srl_nokia/models/common/srl_nokia-common.yang
		sed -i 's%modifier \"invert-match\"%//modifier \"invert-match\"%g' ${WORKDIR}/srlinux-yang-models/srl_nokia/models/common/srl_nokia-common.yang
	fi

remove-tools-schema: ## Delete tools schema files from SR Linux native YANG collection.
	rm -f ${WORKDIR}/srlinux-yang-models/srl_nokia/models/*/*tools*.yang

generate-structs: ## Generate Go structs for YANG files using ygot generator.
	mkdir -p ${OUTDIR}
	generator \
		-output_dir=${OUTDIR} \
		-path=${WORKDIR}/srlinux-yang-models \
		-package_name=ygotsrl -generate_fakeroot -fakeroot_name=Device -compress_paths=false \
		-structs_split_files_count=20 \
		-logtostderr \
		-shorten_enum_leaf_names \
		-typedef_enum_with_defmod \
		-enum_suffix_for_simple_union_enums \
		-generate_rename \
		-generate_append \
		-generate_getters \
		-generate_delete \
		-generate_simple_unions \
		-generate_populate_defaults \
		-include_schema \
		-exclude_state \
		-yangpresence \
		-include_model_data \
		-generate_leaf_getters \
		-ignore_unsupported \
		${WORKDIR}/srlinux-yang-models/srl_nokia/models/*/*.yang

cleanup: ## Remove work and output directories
	rm -rf work
	rm -rf output

GOFUMPT_CMD := docker run --rm -it -e GOFUMPT_SPLIT_LONG_LINES=on -v $(CURDIR):/work ghcr.io/hellt/gofumpt:0.3.1
GOFUMPT_FLAGS := -l -w .

GODOT_CMD := docker run --rm -it -v $(CURDIR):/work ghcr.io/hellt/godot:1.4.11
GODOT_FLAGS := -w .

GOIMPORTS_CMD := docker run --rm -it -v $(CURDIR):/work ghcr.io/hellt/goimports:0.5.0
GOIMPORTS_FLAGS := -w ${OUTDIR}/*

format: goimports gofumpt godot # Apply Go formatters.
	# copy files after formatting to .
	cp -a ${OUTDIR}/* .

goimports:
	${GOIMPORTS_CMD} ${GOIMPORTS_FLAGS}

gofumpt:
	${GOFUMPT_CMD} ${GOFUMPT_FLAGS}

godot:
	${GODOT_CMD} ${GODOT_FLAGS}

help: # Yeah, it's not mine - https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'