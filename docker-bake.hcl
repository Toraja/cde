# --- common---
variable "BASE_IMAGE" {
  default = "target:base"
}
variable "IMAGE_TAG_PREFIX" {
  default = "cde/"
}
variable "LABEL_PREFIX" {
  default = "cde."
}
variable "USER_NAME" {}

target "common" {
  args = {
    USER_NAME = "${USER_NAME}"
  }
}

# --- base---

variable "USER_ID" {}
variable "GROUD_ID" {}
variable "GROUP_NAME" {}
variable "DOCKER_GROUP_ID" {}

target "base" {
  inherits = ["common"]
  context = "base/ctx"
  args = {
    USER_ID = "${USER_ID}"
    GROUD_ID = "${GROUD_ID}"
    GROUP_NAME = "${GROUP_NAME}"
    DOCKER_GROUP_ID = "${DOCKER_GROUP_ID}"
  }
  tags = ["${IMAGE_TAG_PREFIX}base"]
  labels = {
    "${LABEL_PREFIX}base" = true
  }
}

# --- go---

variable "GO_BASE_IMAGE" {
  default = "${BASE_IMAGE}"
}

target "go" {
  inherits = ["common"]
  context = "go/ctx"
  contexts = {
    baseimage = "${GO_BASE_IMAGE}"
  }
  tags = ["${IMAGE_TAG_PREFIX}go"]
  labels = {
    "${LABEL_PREFIX}go" = true
  }
}

# --- python---

variable "PYTHON_BASE_IMAGE" {
  default = "${BASE_IMAGE}"
}

target "python" {
  inherits = ["common"]
  context = "python/ctx"
  contexts = {
    baseimage = "${PYTHON_BASE_IMAGE}"
  }
  tags = ["${IMAGE_TAG_PREFIX}python"]
  labels = {
    "${LABEL_PREFIX}python" = true
  }
}

# --- rust---

variable "RUST_BASE_IMAGE" {
  default = "${BASE_IMAGE}"
}

target "rust" {
  inherits = ["common"]
  context = "rust/ctx"
  contexts = {
    baseimage = "${RUST_BASE_IMAGE}"
  }
  tags = ["${IMAGE_TAG_PREFIX}rust"]
  labels = {
    "${LABEL_PREFIX}rust" = true
  }
}
