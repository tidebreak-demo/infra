resource "aws_sqs_queue" "ci_cache_bundle" {
  name                       = "ci-cache-bundle"
  visibility_timeout_seconds = 120
  message_retention_seconds  = 345600
}
