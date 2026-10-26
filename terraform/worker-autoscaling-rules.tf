resource "aws_sqs_queue" "worker_autoscaling_rules_dlq" {
  name                      = "worker-autoscaling-rules-dlq"
  message_retention_seconds = 1209600

  tags = {
    Service = "dispatch"
    Queue   = "worker-autoscaling-rules"
  }
}

resource "aws_sqs_queue" "worker_autoscaling_rules" {
  name                       = "worker-autoscaling-rules"
  visibility_timeout_seconds = 120
  message_retention_seconds  = 345600

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.worker_autoscaling_rules_dlq.arn
    maxReceiveCount     = 5
  })

  tags = {
    Service = "dispatch"
  }
}

resource "aws_cloudwatch_metric_alarm" "worker_autoscaling_rules_backlog" {
  alarm_name          = "worker-autoscaling-rules-backlog"
  namespace           = "AWS/SQS"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 5
  threshold           = 50
  comparison_operator = "GreaterThanThreshold"

  dimensions = {
    QueueName = aws_sqs_queue.worker_autoscaling_rules.name
  }
}
