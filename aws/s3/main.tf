resource "aws_s3_bucket" "main" {


  bucket              = var.bucket
  bucket_prefix       = var.bucket_prefix
  acl                 = var.acl
  tags                = var.tags
  force_destroy       = var.force_destroy
  acceleration_status = var.acceleration_status
  request_payer       = var.request_payer



  # Max 1 block - replication_configuration
  dynamic "replication_configuration" {
    for_each = length(keys(var.replication_configuration)) == 0 ? [] : [var.replication_configuration]

    content {
      role = replication_configuration.value.role

      dynamic "rules" {
        for_each = replication_configuration.value.rules

        content {
          id       = lookup(rules.value, "id", null)
          priority = lookup(rules.value, "priority", null)
          prefix   = lookup(rules.value, "prefix", null)
          status   = rules.value.status

          dynamic "destination" {
            for_each = length(keys(lookup(rules.value, "destination", {}))) == 0 ? [] : [lookup(rules.value, "destination", {})]

            content {
              bucket             = destination.value.bucket
              storage_class      = lookup(destination.value, "storage_class", null)
              replica_kms_key_id = lookup(destination.value, "replica_kms_key_id", null)
              account_id         = lookup(destination.value, "account_id", null)

              dynamic "access_control_translation" {
                for_each = length(keys(lookup(destination.value, "access_control_translation", {}))) == 0 ? [] : [lookup(destination.value, "access_control_translation", {})]

                content {
                  owner = access_control_translation.value.owner
                }
              }
            }
          }

          dynamic "source_selection_criteria" {
            for_each = length(keys(lookup(rules.value, "source_selection_criteria", {}))) == 0 ? [] : [lookup(rules.value, "source_selection_criteria", {})]

            content {

              dynamic "sse_kms_encrypted_objects" {
                for_each = length(keys(lookup(source_selection_criteria.value, "sse_kms_encrypted_objects", {}))) == 0 ? [] : [lookup(source_selection_criteria.value, "sse_kms_encrypted_objects", {})]

                content {

                  enabled = sse_kms_encrypted_objects.value.enabled
                }
              }
            }
          }

          dynamic "filter" {
            for_each = length(keys(lookup(rules.value, "filter", {}))) == 0 ? [] : [lookup(rules.value, "filter", {})]

            content {
              prefix = lookup(filter.value, "prefix", null)
              tags   = lookup(filter.value, "tags", null)
            }
          }

        }
      }
    }
  }

  # Max 1 block - server_side_encryption_configuration
  dynamic "server_side_encryption_configuration" {
    for_each = length(keys(var.server_side_encryption_configuration)) == 0 ? [] : [var.server_side_encryption_configuration]

    content {

      dynamic "rule" {
        for_each = length(keys(lookup(server_side_encryption_configuration.value, "rule", {}))) == 0 ? [] : [lookup(server_side_encryption_configuration.value, "rule", {})]

        content {

          dynamic "apply_server_side_encryption_by_default" {
            for_each = length(keys(lookup(rule.value, "apply_server_side_encryption_by_default", {}))) == 0 ? [] : [
            lookup(rule.value, "apply_server_side_encryption_by_default", {})]

            content {
              sse_algorithm     = apply_server_side_encryption_by_default.value.sse_algorithm
              kms_master_key_id = lookup(apply_server_side_encryption_by_default.value, "kms_master_key_id", null)
            }
          }
        }
      }
    }
  }

  # Max 1 block - object_lock_configuration
  dynamic "object_lock_configuration" {
    for_each = length(keys(var.object_lock_configuration)) == 0 ? [] : [var.object_lock_configuration]

    content {
      object_lock_enabled = object_lock_configuration.value.object_lock_enabled

      dynamic "rule" {
        for_each = length(keys(lookup(object_lock_configuration.value, "rule", {}))) == 0 ? [] : [lookup(object_lock_configuration.value, "rule", {})]

        content {
          default_retention {
            mode  = lookup(lookup(rule.value, "default_retention", {}), "mode")
            days  = lookup(lookup(rule.value, "default_retention", {}), "days", null)
            years = lookup(lookup(rule.value, "default_retention", {}), "years", null)
          }
        }
      }
    }
  }

}

resource "aws_s3_bucket_policy" "this" {
  count = var.create_bucket && (var.attach_elb_log_delivery_policy || var.attach_policy) ? 1 : 0

  bucket = aws_s3_bucket.this[0].id
  policy = var.attach_elb_log_delivery_policy ? data.aws_iam_policy_document.elb_log_delivery[0].json : var.policy
}

# AWS Load Balancer access log delivery policy
data "aws_elb_service_account" "this" {
  count = var.create_bucket && var.attach_elb_log_delivery_policy ? 1 : 0
}

data "aws_iam_policy_document" "elb_log_delivery" {
  count = var.create_bucket && var.attach_elb_log_delivery_policy ? 1 : 0

  statement {
    sid = ""

    principals {
      type        = "AWS"
      identifiers = data.aws_elb_service_account.this.*.arn
    }

    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.this[0].arn}/*",
    ]
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  count = var.create_bucket && var.attach_public_policy ? 1 : 0

  # Chain resources (s3_bucket -> s3_bucket_policy -> s3_bucket_public_access_block)
  # to prevent "A conflicting conditional operation is currently in progress against this resource."
  bucket = (var.attach_elb_log_delivery_policy || var.attach_policy) ? aws_s3_bucket_policy.this[0].id : aws_s3_bucket.this[0].id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}


resource "aws_s3_bucket_website_configuration" "main" {
  count = var.website != null ? 1 : 0
  bucket = aws_s3_bucket.main.id

  dynamic "index_document" {
    for_each = var.website.index_document != null ? [0] : []
    content {
      suffix = var.website.index_document
    }
  }

  dynamic "error_document" {
    for_each = var.website.error_document != null ? [0] : []
    content {
      key = var.website.error_document
    }
  }

  dynamic "redirect_all_requests_to" {
    for_each = var.website.redirect_all_requests_to != null ? [0] : []
    content {
      host_name = var.website.redirect_all_requests_to.host_name
      protocol = var.website.redirect_all_requests_to.protocol
    }
  }

  routing_rules = var.website.routing_rules
}


resource "aws_s3_bucket_cors_configuration" "main" {
  count = var.cors_rule != null ? 1 : 0
  bucket = aws_s3_bucket.main.id

  cors_rule {
  allowed_headers = var.cors_rule.allowed_headers
  allowed_methods = var.cors_rule.allowed_methods
  allowed_origins = var.cors_rule.allowed_origins
  expose_headers = var.cors_rule.expose_headers
  max_age_seconds = var.cors_rule.allowmax_age_secondsed_headers
  }
}


resource "aws_s3_bucket_versioning" "main" {
  count = var.versioning != null ? 1 : 0
  bucket = aws_s3_bucket.main.id

  dynamic "versioning_configuration" {
    for_each = var.versioning.versioning_configuration != null ? [0] : []
    content {
      status = var.versioning.versioning_configuration.status
      mfa_delete = var.versioning.versioning_configuration.mfa_delete
    }
  }

  expected_bucket_owner = var.versioning.expected_bucket_owner
  mfa = var.versioning.mfa 
}


resource "aws_s3_bucket_logging" "main" {
  count = var.logging != null ? 1 : 0
  bucket = aws_s3_bucket.main.id

  target_bucket = var.logging.target_bucket
  target_prefix = var.logging.target_prefix 
  expected_bucket_owner = var.logging.expected_bucket_owner

  dynamic "target_grant" {
    for_each = var.logging.target_grant != null ? [0] : []
    content {
      dynamic "grantee" {
        for_each = var.logging.target_grant.grantee != null ? [0] : []
        content {
          email_address = var.logging.target_grant.grantee.email_address
          id = var.logging.target_grant.grantee.id
          type = var.logging.target_grant.grantee.type
          uri = var.logging.target_grant.grantee.uri
        }
      }
      permission = var.logging.target_grant.permission
    }
  }
}


resource "aws_s3_bucket_lifecycle_configuration" "main" {
  count = var.lifecycle_rule != null ? 1 : 0
  bucket = aws_s3_bucket.main.id
  
  expected_bucket_owner = var.lifecycle_rule.expected_bucket_owner

  dynamic "rule" {
    for_each = var.lifecycle_rule.rule != null ? [0] : []
    content {
      dynamic "abort_incomplete_multipart_upload" {
        for_each = var.lifecycle_rule.rule.abort_incomplete_multipart_upload != null ? [0] : []
        content {
          days_after_initiation = var.lifecycle_rule.rule.abort_incomplete_multipart_upload.days_after_initiation
        }
      }
      dynamic "expiration" {
        for_each = var.lifecycle_rule.rule.expiration != null ? [0] : []
        content {
          date = var.lifecycle_rule.rule.expiration.date
          days = var.lifecycle_rule.rule.expiration.days
          expired_object_delete_marker = var.lifecycle_rule.rule.expiration.expired_object_delete_marker
        }
      }
      dynamic "filter" {
        for_each = var.lifecycle_rule.rule.filter != null ? [0] : []
        content {
          dynamic "and" {
            for_each = var.lifecycle_rule.rule.filter.and != null ? [0] : []
            content {
              object_size_greater_than = var.lifecycle_rule.rule.filter.and.object_size_greater_than 
              object_size_less_than = var.lifecycle_rule.rule.filter.and.object_size_less_than 
              prefix = var.lifecycle_rule.rule.filter.and.prefix 
              tags = var.lifecycle_rule.rule.filter.and.tags 
            }
          }
          dynamic "tag" {
            for_each = var.lifecycle_rule.rule.filter.tag != null ? [0] : []
            content {
              key = var.lifecycle_rule.rule.filter.tag.key 
              value = var.lifecycle_rule.rule.filter.tag.value 
            }
          }
          object_size_greater_than = var.lifecycle_rule.rule.filter.object_size_greater_than
          object_size_less_than = var.lifecycle_rule.rule.filter.object_size_less_than
          prefix = var.lifecycle_rule.rule.filter.prefix
        }
      }
      dynamic "noncurrent_version_expiration" {
        for_each = var.lifecycle_rule.rule.noncurrent_version_expiration != null ? [0] : []
        content {
          newer_noncurrent_versions = var.lifecycle_rule.rule.noncurrent_version_expiration.newer_noncurrent_versions
          noncurrent_days = var.lifecycle_rule.rule.noncurrent_version_expiration.noncurrent_days
        }
      }
      dynamic "noncurrent_version_transition" {
        for_each = var.lifecycle_rule.rule.noncurrent_version_transition != null ? [0] : []
        content {
          newer_noncurrent_versions = var.lifecycle_rule.rule.noncurrent_version_transition.newer_noncurrent_versions
          noncurrent_days = var.lifecycle_rule.rule.noncurrent_version_transition.noncurrent_days
          storage_class = var.lifecycle_rule.rule.noncurrent_version_transition.storage_class
        }
      }
      dynamic "transition" {
        for_each = var.lifecycle_rule.rule.transition != null ? [0] : []
        content {
          days = var.lifecycle_rule.rule.transition.days
          date = var.lifecycle_rule.rule.transition.date
          storage_class = var.lifecycle_rule.rule.transition.storage_class
        }
      }
      id = var.lifecycle_rule.rule.id
      status = var.lifecycle_rule.rule.abort_incomplete_multipstatusart_upload
    }
  }
}




