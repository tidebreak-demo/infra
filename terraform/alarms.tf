resource "aws_cloudwatch_metric_alarm" "dispatch_backlog" {
  alarm_name          = "dispatch-backlog"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 500
  metric_name         = "ApproximateNumberOfMessagesVisible"
}
