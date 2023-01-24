
# ygotsrl

## Introduction
ygot (**Y**ANG **Go** **T**ools) is a collection of Go utilities that can be used to:

 * Generate a set of Go structures and enumerated values for a set of YANG modules, with associated helper methods.
 * Validate the contents of the Go structures against the YANG schema (e.g., validating range and regular expression constraints).
 * Render the Go structures to an output format - such as JSON, or a set of gNMI Notifications for use in a deployment of streaming telemetry.

## Generated Go Structures from YANG
This repository contains the generated Go structures and enumerated values for the SRLinux YANG Modules, which can be found on `https://github.com/nokia/srlinux-yang-models`
The purpose is to remove boilerplate and allow developers to focus on writing code using these Go structures as a library.

The generator runs with following flags:
```
generator -output_file=work/ygotsrl.go
  -logtostderr
  -path=nokia/srlinux-yang-models 
  -package_name=ygotsrl -generate_fakeroot -fakeroot_name=Device 
  -compress_paths=false 
  -shorten_enum_leaf_names 
  -typedef_enum_with_defmod 
  -enum_suffix_for_simple_union_enums 
  -generate_rename 
  -generate_append 
  -generate_getters 
  -generate_delete 
  -generate_simple_unions 
  -generate_populate_defaults 
  -include_schema 
  -exclude_state 
  -yangpresence 
  -include_model_data 
  -generate_leaf_getters 
  nokia/srlinux-yang-models/srl_nokia/models/*/*.yang
```
If you'd like to deviate from this behaviour, please follow the [`ygot`](https://github.com/openconfig/ygot) guidelines.

## Repository structure
The main branch of this repository contains only the documentation. To reveal the generated Go files for a given release select the tag that matches the SR Linux release version.

For instance, tag `v22.6.2` corresponds to the SR Linux release 22.6.2.

## Download
There are several ways to download the Go files for a specific SR Linux release. The below examples are provided for `v22.6.2` version.

### Clone with git
Clone the yang files for a specific release with the following `git` command:
```
git clone -b v22.6.2 --depth 1 https://github.com/srl-labs/ygotsrl
```

### Download archives
To download the proto files for a specific release in the `zip` or `tgz` archive, navigate to the GitHub [`tag`](https://github.com/srl-labs/ygotsrl/tags) page, which contains the links to the archives.

If needed, the download link can be programmatically derived using the following rule:

**for zip**
`https://github.com/srl-labs/ygotsrl/archive/tags/` + `$tag` + `.zip`

**for tar.gz**
`https://github.com/srl-labs/ygotsrl/archive/tags/` + `$tag` + `.tar.gz`