output "recorder_name" {
  description = "Name of the AWS Config configuration recorder."
  value       = aws_config_configuration_recorder.this.name
}

output "bucket_name" {
  description = "Config delivery bucket name."
  value       = module.bucket.bucket_id
}

output "access_log_bucket_name" {
  description = "Access-log bucket for the Config delivery bucket."
  value       = module.bucket.access_log_bucket_id
}

output "conformance_pack_name" {
  description = "Name of the CIS-aligned conformance pack, when enabled."
  value       = try(aws_config_conformance_pack.cis[0].name, null)
}

output "region" {
  description = "Region the recorder was created in."
  value       = data.aws_region.current.name
}
