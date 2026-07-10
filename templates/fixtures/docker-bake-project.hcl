
target "xxx-bundle_yyy-project" {
  inherits = ["common"]
  context = "${envbundleprefix()}/yyy-project/ctx"
  contexts = {
    baseimage = "${PROJECT_BASE_IMAGE}"
  }
  tags = [tagname("yyy-project")]
}
