# --- common ---
variable "BASE_IMAGE" {
  default = "target:root"
}
variable "USER_NAME" {}
variable "ENV_PREFIX" {
  default = "env/"
}

function "tagname" {
  params = []
  variadic_params = items
  result = join("/", ["cde", join("/", items)])
}

target "common" {
  args = {
    USER_NAME = "${USER_NAME}"
  }
  contexts = {
    catalogs = "catalogs"
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
  tags = [tagname("root")]
}
