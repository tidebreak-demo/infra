resource "aws_sqs_queue" "dispatch_queue_alarm_dlq" {
  name                      = "dispatch-queue-alarm-dlq"
  message_retention_seconds = 1209600

  tags = {
    Service = "dispatch"
    Queue   = "dispatch-queue-alarm"
  }
}

resource "aws_sqs_queue" "dispatch_queue_alarm" {
  name                       = "dispatch-queue-alarm"
  visibility_timeout_seconds = 120
  message_retention_seconds  = 345600

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dispatch_queue_alarm_dlq.arn
    maxReceiveCount     = 5
  })

  tags = {
    Service = "dispatch"
  }
}

resource "aws_cloudwatch_metric_alarm" "dispatch_queue_alarm_backlog" {
  alarm_name          = "dispatch-queue-alarm-backlog"
  namespace           = "AWS/SQS"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 5
  threshold           = 50
  comparison_operator = "GreaterThanThreshold"

  dimensions = {
    QueueName = aws_sqs_queue.dispatch_queue_alarm.name
  }
}
