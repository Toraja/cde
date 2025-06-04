# --- common ---
variable "BASE_IMAGE" {
  default = "target:root"
}
variable "BASE_IMAGE_TAG" {
  # Default value must be set here.
  # If unset, BASE_IMAGE_TAG will be empty even if the default value of ARG is specified in Dockerfile.
  default = "rolling"
}
variable "HOME" {}
variable "USER_ID" {}
variable "USER_NAME" {}
variable "GROUP_ID" {}
variable "GROUP_NAME" {}
variable "DOCKER_GROUP_ID" {}

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
    USER_ID = USER_ID
    USER_NAME = USER_NAME
    GROUP_ID = GROUP_ID
    GROUP_NAME = GROUP_NAME
  }
  secret = [
    { type = "env", id = "GITHUB_TOKEN" },
  ]
  contexts = {
    catalog = "catalog"
  }
}

# --- root ---

target "root" {
  inherits = ["common"]
  context = "root/ctx"
  args = {
    DOCKER_GROUP_ID = DOCKER_GROUP_ID
    BASE_IMAGE_TAG = BASE_IMAGE_TAG
  }
  tags = ["cde/root"]
}

target "root_test" {
  inherits = ["root"]
  tags = ["cde/root-test"]
  dockerfile = "test.Dockerfile"
}
