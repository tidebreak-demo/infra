resource "aws_sqs_queue" "log_retention_tiering_dlq" {
  name                      = "log-retention-tiering-dlq"
  message_retention_seconds = 1209600

  tags = {
    Service = "dispatch"
    Queue   = "log-retention-tiering"
  }
}

resource "aws_sqs_queue" "log_retention_tiering" {
  name                       = "log-retention-tiering"
  visibility_timeout_seconds = 120
  message_retention_seconds  = 345600

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.log_retention_tiering_dlq.arn
    maxReceiveCount     = 5
  })

  tags = {
    Service = "dispatch"
  }
}

resource "aws_cloudwatch_metric_alarm" "log_retention_tiering_backlog" {
  alarm_name          = "log-retention-tiering-backlog"
  namespace           = "AWS/SQS"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 5
  threshold           = 50
  comparison_operator = "GreaterThanThreshold"

  dimensions = {
    QueueName = aws_sqs_queue.log_retention_tiering.name
  }
}
