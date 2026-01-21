# --- common ---
variable "BASE_IMAGE" {
  default = "target:root"
}
variable "BASE_IMAGE_TAG" {
  validation {
    condition = BASE_IMAGE_TAG != ""
    error_message = "BASE_IMAGE_TAG is required"
  }
}
variable "USER_ID" {
  validation {
    condition = USER_ID != ""
    error_message = "USER_ID is required"
  }
}
variable "USER_NAME" {
  validation {
    condition = USER_NAME != ""
    error_message = "USER_NAME is required"
  }
}
variable "GROUP_ID" {
  validation {
    condition = GROUP_ID != ""
    error_message = "GROUP_ID is required"
  }
}
variable "GROUP_NAME" {
  validation {
    condition = GROUP_NAME != ""
    error_message = "GROUP_NAME is required"
  }
}
variable "DOCKER_GROUP_ID" {
  validation {
    condition = DOCKER_GROUP_ID != ""
    error_message = "DOCKER_GROUP_ID is required"
  }
}

variable "ENV_PREFIX" {
  default = "env"
}
variable "ENV_BUNDLE" {
  validation {
    condition = ENV_BUNDLE != ""
    error_message = "ENV_BUNDLE must be overwritten in docker-bake.hcl of each env"
  }
}

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
