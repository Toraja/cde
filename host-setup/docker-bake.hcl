variable "IMAGE_TAG" {
  validation {
    condition = IMAGE_TAG != ""
    error_message = "IMAGE_TAG is required"
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

target "test" {
  args = {
    IMAGE_TAG = IMAGE_TAG
    USER_ID = USER_ID
    USER_NAME = USER_NAME
    GROUP_ID = GROUP_ID
    GROUP_NAME = GROUP_NAME
  }
  tags = ["cde/host-setup-test"]
}
