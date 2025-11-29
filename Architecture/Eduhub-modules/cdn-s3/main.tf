# Inside your bucket module (modules/cdn-s3/main.tf)
data "aws_region" "current" {
}

resource "aws_s3_bucket" "this" {
  for_each = var.buckets
  bucket   = "${each.key}-${data.aws_region.current.name}"
}

resource "aws_s3_bucket_versioning" "this" {
  for_each = { for k, v in var.buckets : k => v if v.versioning }
  bucket   = aws_s3_bucket.this[each.key].id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  for_each = { for k, v in var.buckets : k => v if v.encryption }
  bucket   = aws_s3_bucket.this[each.key].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# modules/cdn-s3/main.tf  ← replace the entire lifecycle block

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  for_each = { for k, v in var.buckets : k => v if length(v.lifecycle_rules) > 0 }
  bucket   = aws_s3_bucket.this[each.key].id

  dynamic "rule" {
    for_each = each.value.lifecycle_rules
    content {
      id     = "transition-to-${rule.value.storage_class}"
      status = "Enabled"

      # This is the REQUIRED line that fixes the warning
      filter {}   # ← empty filter = applies to ALL objects (exactly what you want)

      transition {
        days          = rule.value.transition_days
        storage_class = rule.value.storage_class
      }
    }
  }
}