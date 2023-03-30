variable "ENV_GROUP" {
  default = "sample"
}

variable "PROJECT_BASE_IMAGE" {
  default = "target:sample_base"
}

# --- base ---

variable "BASE_BASE_IMAGE" {
  default = "target:root"
}

target "sample_base" {
  inherits = ["common"]
  context = "${envgroupprefix()}/base/ctx"
  contexts = {
    baseimage = "${BASE_BASE_IMAGE}"
  }
  tags = [tagname("base")]
}

# --- project ---

target "sample_project" {
  inherits = ["common"]
  context = "${envgroupprefix()}/project/ctx"
  contexts = {
    baseimage = "${PROJECT_BASE_IMAGE}"
  }
  tags = [tagname("project")]
}
