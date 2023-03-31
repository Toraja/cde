# --- common ---
variable "BASE_IMAGE" {
  default = "target:root"
}
variable "USER_NAME" {}
variable "ENV_PREFIX" {
  default = "env"
}
variable "ENV_BUNDLE" {} # must be overwritten in docker-bake.hcl of each env

function "tagname" {
  params = []
  variadic_params = items
  result = join("/", ["cde", ENV_BUNDLE, join("/", items)])
}
function "envbundleprefix" {
  params = []
  result = join("/", [ENV_PREFIX, ENV_BUNDLE])
}

target "common" {
  args = {
    USER_NAME = "${USER_NAME}"
  }
  contexts = {
    catalog = "catalog"
  }
}

# --- root ---

variable "USER_ID" {}
variable "GROUD_ID" {}
variable "GROUP_NAME" {}
variable "DOCKER_GROUP_ID" {}

target "root" {
  inherits = ["common"]
  context = "root/ctx"
  args = {
    USER_ID = USER_ID
    GROUD_ID = GROUD_ID
    GROUP_NAME = GROUP_NAME
    DOCKER_GROUP_ID = DOCKER_GROUP_ID
  }
  tags = ["${ENV_PREFIX}/root"]
}
