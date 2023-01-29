
<p align=center><a href="https://learn.srlinux.dev"><img src=https://gitlab.com/rdodin/pics/-/wikis/uploads/71f0c7b44733ec328c40ab9eae996cb7/srl-ygotsrl-2.svg?sanitize=true /></a></p>

---

This repository contains generated Go module that provides API for Nokia SR Linux Network OS. The module is generated with [ygot](https://github.com/openconfig/ygot) project.

ygot (**Y**ANG **Go** **T**ools) is a collection of Go utilities that can be used to:

* Generate a set of Go structures and enumerated values for a set of YANG modules, with associated helper methods.
* Validate the contents of the Go structures against the YANG schema (e.g., validating range and regular expression constraints).
* Render the Go structures to an output format - such as JSON, or a set of gNMI Notifications for use in a deployment of streaming telemetry.

## Usage

To use the generated Go package, users should first identify which SR Linux version(s) they would like to interact with, as the package is generated per each SR Linux release.

For example, to start using the package generated for SR Linux v21.11.1 download the relevant module:

```bash
go get github.com/srl-labs/ygotsrl/v21 v21.11.1
```

and import the `ygotsrl` package from it:

```go
package main

import (
 "github.com/srl-labs/ygotsrl/v21"
)

func main() {
  srl := new(ygotsrl.Device)
}
```

### Versioning

Each module is published with the tag matching SR Linux release number. All available releases can be browsed on the [tags](https://github.com/srl-labs/ygotsrl/tags) page.

Because of the adherence to the SR Linux versioning convention, `ygotsrl` Go module has to artificially follow the SemVer rules. Branches are created per each major release - `v21`, `v22`, `v23` and so on. Make sure to use the correct major version string when importing the module.

> **Warning**  
> Because of the immutability of the Go package cache you might find that the latest tag for a given release might not work. In that case [check](https://github.com/srl-labs/ygotsrl/tags) if a tag with `-patchX` suffix exists and make sure to use them.
> The list of releases for which patch releases have been issued:  
>
> * `22.11.1-patch1`
> * `22.6.4-patch1`
> * `22.6.3-patch1`
> * `22.6.2-patch1`
> * `22.6.1-patch1`

## Package documentation

Package documentation can be found at [pkg.go.dev](https://pkg.go.dev/github.com/srl-labs/ygotsrl/v22). [Switch](https://pkg.go.dev/github.com/srl-labs/ygotsrl/v22?tab=versions) the required major version number if necessary.

## Generation flags

The Go structures and enumerated values provided by this package are generated off of [SR Linux YANG Modules](https://github.com/nokia/srlinux-yang-models).

The generator command used to generate the files can be found in the [Makefile](Makefile#L79).

If you'd like to deviate from the chosen generator options, please follow the [`ygot`](https://github.com/openconfig/ygot) guidelines and regenerate the files manually.

## Repository structure

The main branch of this repository contains only the documentation. To reveal the generated Go files for a given release select the tag that matches the SR Linux release version.

For instance, tag `v22.6.2-patch1` corresponds to the SR Linux release 22.6.2.
