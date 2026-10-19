resource "aws_sqs_queue" "rds_slow_query_logging_dlq" {
  name                      = "rds-slow-query-logging-dlq"
  message_retention_seconds = 1209600

  tags = {
    Service = "dispatch"
    Queue   = "rds-slow-query-logging"
  }
}

resource "aws_sqs_queue" "rds_slow_query_logging" {
  name                       = "rds-slow-query-logging"
  visibility_timeout_seconds = 180
  message_retention_seconds  = 345600

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.rds_slow_query_logging_dlq.arn
    maxReceiveCount     = 5
  })

  tags = {
    Service = "dispatch"
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_slow_query_logging_backlog" {
  alarm_name          = "rds-slow-query-logging-backlog"
  namespace           = "AWS/SQS"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 5
  threshold           = 100
  comparison_operator = "GreaterThanThreshold"

  dimensions = {
    QueueName = aws_sqs_queue.rds_slow_query_logging.name
  }
}
