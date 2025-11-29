# modules/storage/buckets/outputs.tf

# Output the full bucket objects (most useful)
output "buckets" {
  description = "Map of all created S3 buckets with all attributes"
  value       = aws_s3_bucket.this
}

# Output just the bucket names (super handy for scripts / frontend)
#module.buckets.bucket_names["eduhub-videos-eu-west-1"]
output "bucket_names" {
  description = "List of all bucket names created"
  value       = keys(var.buckets)
}

# Output the video bucket specifically (you'll use this a lot
output "video_bucket_name" {
  description = "Name of the video storage bucket"
  value = "eduhub-videos-${data.aws_region.current.name}"
}

output "assignment_bucket_name" {
  description = "Name of the assignment uploads bucket"
  value = "eduhub-assignments-${data.aws_region.current.name}"
}

output "backup_bucket_name" {
  description = "Name of the backup bucket"
  value = "eduhub-backups-${data.aws_region.current.name}"
}

# Optional: direct ARNs if your apps need them
#module.buckets.buckets["eduhub-videos-eu-west-1"].arn
output "bucket_arns" {
  description = "Map of bucket names to ARNs"
  value = {
    for name, bucket in aws_s3_bucket.this :
    name => bucket.arn
  }
}