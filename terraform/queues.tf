resource "aws_sqs_queue" "dispatch" {
  name                       = "dispatch"
  visibility_timeout_seconds = 120
}
