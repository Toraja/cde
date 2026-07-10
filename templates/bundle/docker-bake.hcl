variable "ENV_BUNDLE" {
  default = "xxx-bundle"
}

variable "PROJECT_BASE_IMAGE" {
  default = "target:xxx-bundle_base"
}

# --- base ---
# Remove this if you do not need common setup for all the projects

target "xxx-bundle_base" {
  inherits = ["common"]
  context = "${envbundleprefix()}/base/ctx"
  contexts = {
    baseimage = "target:root"
  }
  tags = [tagname("base")]
}

# --- projects ---
