variable "ENV_BUNDLE" {} # This is defined only to disable validation

target "root" {
  inherits = ["common"]
  context = "root/ctx"
  args = {
    DOCKER_GROUP_ID = DOCKER_GROUP_ID
    BASE_IMAGE_TAG = BASE_IMAGE_TAG
  }
  tags = ["cde/root"]
}
