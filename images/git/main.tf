terraform {
  required_providers {
    oci = { source = "chainguard-dev/oci" }
    apko = {
      source                = "chainguard-dev/apko"
      configuration_aliases = [apko.alpine]
    }
  }
}

provider "apko" {
  alias = "alpine"

  extra_repositories = ["https://dl-cdn.alpinelinux.org/alpine/edge/main", "https://dl-cdn.alpinelinux.org/alpine/edge/community"]
  # These packages match chainguard-images/static
  extra_packages = ["alpine-baselayout-data", "alpine-release", "ca-certificates-bundle"]
  // Don't build for riscv64, 386, arm/v6
  // Only build for: amd64, arm/v7, arm64, ppc64le, s390x
  default_archs = ["amd64", "arm/v7", "arm64", "ppc64le", "s390x"]
}

locals {
  accounts = toset(["nonroot", "root"])
}

variable "target_repository" {
  description = "The docker repo into which the image and attestations should be published."
}

resource "oci_tag" "alpine" {
  depends_on = [module.test-latest-alpine]
  digest_ref = module.latest-alpine["nonroot"].image_ref
  tag        = "alpine"
}

resource "oci_tag" "alpine-root" {
  depends_on = [module.test-latest-alpine]
  digest_ref = module.latest-alpine["root"].image_ref
  tag        = "alpine-root"
}
