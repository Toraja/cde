variable "ENV_BUNDLE" {
  default = "xxx-bundle"
}

variable "PROJECT_BASE_IMAGE" {
  default = "target:xxx-bundle_base"
}

# --- base ---
# Use this if you need common setup for all the project

variable "BASE_BASE_IMAGE" {
  default = "target:root"
}

target "xxx-bundle_base" {
  inherits = ["common"]
  context = "${envbundleprefix()}/base/ctx"
  contexts = {
    baseimage = "${BASE_BASE_IMAGE}"
  }
  tags = [tagname("base")]
}

# --- project ---

target "xxx-bundle_yyy-project" {
  inherits = ["common"]
  context = "${envbundleprefix()}/yyy-project/ctx"
  contexts = {
    baseimage = "${PROJECT_BASE_IMAGE}"
  }
  tags = [tagname("yyy-project")]
}
