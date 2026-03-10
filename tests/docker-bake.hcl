target "root_test" {
  inherits = ["root"]
  context = "../root/ctx"
  contexts = {
    catalog = "../catalog"
  }
  dockerfile = "test.Dockerfile"
  tags = ["cde-test/root"]
}
