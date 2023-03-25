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

# --- go ---

variable "GO_BASE_IMAGE" {
  default = "${BASE_IMAGE}"
}

target "go" {
  inherits = ["common"]
  context = "go/ctx"
  contexts = {
    baseimage = "${GO_BASE_IMAGE}"
  }
  tags = [tagname("go")]
}

# --- python ---

variable "PYTHON_BASE_IMAGE" {
  default = "${BASE_IMAGE}"
}

target "python" {
  inherits = ["common"]
  context = "python/ctx"
  contexts = {
    baseimage = "${PYTHON_BASE_IMAGE}"
  }
  tags = [tagname("python")]
}

# --- rust ---

variable "RUST_BASE_IMAGE" {
  default = "${BASE_IMAGE}"
}

target "rust" {
  inherits = ["common"]
  context = "rust/ctx"
  contexts = {
    baseimage = "${RUST_BASE_IMAGE}"
  }
  tags = [tagname("rust")]
}
