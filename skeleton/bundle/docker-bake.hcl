variable "ENV_BUNDLE" {
  default = "bundle"
}

variable "PROJECT_BASE_IMAGE" {
  default = "target:bundle_base"
}

# --- base ---
# Use this if you need common setup for all the project

variable "BASE_BASE_IMAGE" {
  default = "target:root"
}

target "bundle_base" {
  inherits = ["common"]
  context = "${envbundleprefix()}/base/ctx"
  contexts = {
    baseimage = "${BASE_BASE_IMAGE}"
  }
  tags = [tagname("base")]
}

# --- project ---

target "bundle_project" {
  inherits = ["common"]
  context = "${envbundleprefix()}/project/ctx"
  contexts = {
    baseimage = "${PROJECT_BASE_IMAGE}"
  }
  tags = [tagname("project")]
}
