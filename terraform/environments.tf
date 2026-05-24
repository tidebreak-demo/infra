locals {
  environments = {
    staging    = { instance_type = "t4g.small" }
    production = { instance_type = "t4g.large" }
  }
}
