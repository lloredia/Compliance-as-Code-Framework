output "sns_topic_arn" {
  description = "SNS topic that receives CIS 4.x alarm notifications."
  value       = aws_sns_topic.cis.arn
}

output "alarm_names" {
  description = "Names of the CIS metric alarms."
  value       = sort([for alarm in aws_cloudwatch_metric_alarm.cis : alarm.alarm_name])
}
