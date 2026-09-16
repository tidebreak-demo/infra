resource "aws_sqs_queue" "secrets_rotation_schedule_dlq" {
  name                      = "secrets-rotation-schedule-dlq"
  message_retention_seconds = 1209600

  tags = {
    Service = "dispatch"
    Queue   = "secrets-rotation-schedule"
  }
}

resource "aws_sqs_queue" "secrets_rotation_schedule" {
  name                       = "secrets-rotation-schedule"
  visibility_timeout_seconds = 120
  message_retention_seconds  = 345600

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.secrets_rotation_schedule_dlq.arn
    maxReceiveCount     = 5
  })

  tags = {
    Service = "dispatch"
  }
}

resource "aws_cloudwatch_metric_alarm" "secrets_rotation_schedule_backlog" {
  alarm_name          = "secrets-rotation-schedule-backlog"
  namespace           = "AWS/SQS"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 5
  threshold           = 50
  comparison_operator = "GreaterThanThreshold"

  dimensions = {
    QueueName = aws_sqs_queue.secrets_rotation_schedule.name
  }
}
