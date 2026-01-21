variable "IMAGE_TAG" {}
variable "USER_ID" {}
variable "USER_NAME" {}
variable "GROUP_ID" {}
variable "GROUP_NAME" {}

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
