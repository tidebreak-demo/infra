resource "aws_sqs_queue" "ci_cache_bundle_dlq" {
  name                      = "ci-cache-bundle-dlq"
  message_retention_seconds = 1209600

  tags = {
    Service = "dispatch"
    Queue   = "ci-cache-bundle"
  }
}

resource "aws_sqs_queue" "ci_cache_bundle" {
  name                       = "ci-cache-bundle"
  visibility_timeout_seconds = 120
  message_retention_seconds  = 345600

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.ci_cache_bundle_dlq.arn
    maxReceiveCount     = 5
  })

  tags = {
    Service = "dispatch"
  }
}

resource "aws_cloudwatch_metric_alarm" "ci_cache_bundle_backlog" {
  alarm_name          = "ci-cache-bundle-backlog"
  namespace           = "AWS/SQS"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 5
  threshold           = 50
  comparison_operator = "GreaterThanThreshold"

  dimensions = {
    QueueName = aws_sqs_queue.ci_cache_bundle.name
  }
}
