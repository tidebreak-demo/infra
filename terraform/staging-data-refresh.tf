resource "aws_sqs_queue" "staging_data_refresh_dlq" {
  name                      = "staging-data-refresh-dlq"
  message_retention_seconds = 1209600

  tags = {
    Service = "dispatch"
    Queue   = "staging-data-refresh"
  }
}

resource "aws_sqs_queue" "staging_data_refresh" {
  name                       = "staging-data-refresh"
  visibility_timeout_seconds = 120
  message_retention_seconds  = 345600

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.staging_data_refresh_dlq.arn
    maxReceiveCount     = 5
  })

  tags = {
    Service = "dispatch"
  }
}

resource "aws_cloudwatch_metric_alarm" "staging_data_refresh_backlog" {
  alarm_name          = "staging-data-refresh-backlog"
  namespace           = "AWS/SQS"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 5
  threshold           = 50
  comparison_operator = "GreaterThanThreshold"

  dimensions = {
    QueueName = aws_sqs_queue.staging_data_refresh.name
  }
}
