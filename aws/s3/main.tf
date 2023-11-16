resource "aws_s3_bucket" "main" {


  bucket              = var.bucket
  bucket_prefix       = var.bucket_prefix

  tags                = var.tags
  force_destroy       = var.force_destroy






resource "aws_s3_bucket_policy" "main" {
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





resource "aws_s3_bucket_website_configuration" "main" {
  count = var.website_configuration != null ? 1 : 0
  bucket = aws_s3_bucket.main.id

  routing_rules = var.website_configuration.routing_rules
  dynamic "index_document" {
    for_each = var.website_configuration.index_document != null ? [0] : []
    content {
      suffix = var.website_configuration.index_document.suffix
    }
  }
  dynamic "error_document" {
    for_each = var.website_configuration.error_document != null ? [0] : []
    content {
      key = var.website_configuration.error_document.key
    }
  }
  dynamic "redirect_all_requests_to" {
    for_each = var.website_configuration.redirect_all_requests_to != null ? [0] : []
    content {
      host_name = var.website_configuration.redirect_all_requests_to.host_name
      protocol = var.website_configuration.redirect_all_requests_to.protocol
    }
  }
}


resource "aws_s3_bucket_cors_configuration" "main" {
  count = var.cors_configuration != null ? 1 : 0
  bucket = aws_s3_bucket.main.id

  dynamic "cors_rule" {
    for_each = var.cors_configuration.cors_rule != null ? [0] : []
    content {
      allowed_headers = var.cors_configuration.cors_rule.allowed_headers
      allowed_methods = var.cors_configuration.cors_rule.allowed_methods
      allowed_origins = var.cors_configuration.cors_rule.allowed_origins
      expose_headers = var.cors_configuration.cors_rule.expose_headers
      id = var.cors_configuration.cors_rule.id
      max_age_seconds = var.cors_configuration.cors_rule.allowmax_age_secondsed_headers
    }
  }
 }
}

resource "aws_s3_bucket_versioning" "main" {
  count = var.versioning != null ? 1 : 0
  bucket = aws_s3_bucket.main.id

  mfa = var.versioning.mfa 
  dynamic "versioning_configuration" {
    for_each = var.versioning.versioning_configuration != null ? [0] : []
    content {
      status = var.versioning.versioning_configuration.status
      mfa_delete = var.versioning.versioning_configuration.mfa_delete
    }
  }
}


resource "aws_s3_bucket_logging" "main" {
  count = var.logging != null ? 1 : 0
  bucket = aws_s3_bucket.main.id

  target_bucket = var.logging.target_bucket
  target_prefix = var.logging.target_prefix 

  dynamic "target_grant" {
    for_each = var.logging.target_grant != null ? [0] : []
    content {
      permission = var.logging.target_grant.permission
      dynamic "grantee" {
        for_each = var.logging.target_grant.grantee != null ? [0] : []
        content {
          email_address = var.logging.target_grant.grantee.email_address
          id = var.logging.target_grant.grantee.id
          type = var.logging.target_grant.grantee.type
          uri = var.logging.target_grant.grantee.uri
        }
      }
    }
  }
}


resource "aws_s3_bucket_lifecycle_configuration" "main" {
  count = var.lifecycle_configuration != null ? 1 : 0
  bucket = aws_s3_bucket.main.id

  dynamic "rule" {
    for_each = var.lifecycle_configuration.rule != null ? [0] : []
    content {
      dynamic "abort_incomplete_multipart_upload" {
        for_each = var.lifecycle_configuration.rule.abort_incomplete_multipart_upload != null ? [0] : []
        content {
          days_after_initiation = var.lifecycle_configuration.rule.abort_incomplete_multipart_upload.days_after_initiation
        }
      }
      dynamic "expiration" {
        for_each = var.lifecycle_configuration.rule.expiration != null ? [0] : []
        content {
          date = var.lifecycle_configuration.rule.expiration.date
          days = var.lifecycle_configuration.rule.expiration.days
          expired_object_delete_marker = var.lifecycle_configuration.rule.expiration.expired_object_delete_marker
        }
      }
      dynamic "filter" {
        for_each = var.lifecycle_configuration.rule.filter != null ? [0] : []
        content {
          dynamic "and" {
            for_each = var.lifecycle_configuration.rule.filter.and != null ? [0] : []
            content {
              object_size_greater_than = var.lifecycle_configuration.rule.filter.and.object_size_greater_than 
              object_size_less_than = var.lifecycle_configuration.rule.filter.and.object_size_less_than 
              prefix = var.lifecycle_configuration.rule.filter.and.prefix 
              tags = var.lifecycle_configuration.rule.filter.and.tags 
            }
          }
          dynamic "tag" {
            for_each = var.lifecycle_configuration.rule.filter.tag != null ? [0] : []
            content {
              key = var.lifecycle_configuration.rule.filter.tag.key 
              value = var.lifecycle_configuration.rule.filter.tag.value 
            }
          }
          object_size_greater_than = var.lifecycle_configuration.rule.filter.object_size_greater_than
          object_size_less_than = var.lifecycle_configuration.rule.filter.object_size_less_than
          prefix = var.lifecycle_configuration.rule.filter.prefix
        }
      }
      dynamic "noncurrent_version_expiration" {
        for_each = var.lifecycle_configuration.rule.noncurrent_version_expiration != null ? [0] : []
        content {
          newer_noncurrent_versions = var.lifecycle_configuration.rule.noncurrent_version_expiration.newer_noncurrent_versions
          noncurrent_days = var.lifecycle_configuration.rule.noncurrent_version_expiration.noncurrent_days
        }
      }
      dynamic "noncurrent_version_transition" {
        for_each = var.lifecycle_configuration.rule.noncurrent_version_transition != null ? [0] : []
        content {
          newer_noncurrent_versions = var.lifecycle_configuration.rule.noncurrent_version_transition.newer_noncurrent_versions
          noncurrent_days = var.lifecycle_configuration.rule.noncurrent_version_transition.noncurrent_days
          storage_class = var.lifecycle_configuration.rule.noncurrent_version_transition.storage_class
        }
      }
      dynamic "transition" {
        for_each = var.lifecycle_configuration.rule.transition != null ? [0] : []
        content {
          days = var.lifecycle_configuration.rule.transition.days
          date = var.lifecycle_configuration.rule.transition.date
          storage_class = var.lifecycle_configuration.rule.transition.storage_class
        }
      }
      id = var.lifecycle_configuration.rule.id
      status = var.lifecycle_configuration.rule.abort_incomplete_multipstatusart_upload
    }
  }
}

resource "aws_s3_bucket_replication_configuration" "main" {
  depends_on = [aws_s3_bucket_versioning.main]
  count = var.replication_configuration != null ? 1 : 0
  bucket = aws_s3_bucket.main.id

  role   = aws_iam_role.replication_configuration.arn
  token = aws_iam_role.replication_configuration.arn

  dynamic "rule" {
    for_each = var.replication_configuration.rule != null ? [0] : []
    content {
      id = var.replication_configuration.rule.id
      status = var.replication_configuration.rule.status
      priority = var.replication_configuration.rule.priority

      dynamic "delete_marker_replication" {
        for_each = var.replication_configuration.rule.delete_marker_replication != null ? [0] : []
        content {
          status = var.replication_configuration.rule.delete_marker_replication.status
        }
      }
      dynamic "destination" {
        for_each = var.replication_configuration.rule.destination != null ? [0] : []
        content {
          dynamic "access_control_translation" {
            for_each = var.replication_configuration.rule.destination.access_control_translation != null ? [0] : []
            content {
              owner = var.replication_configuration.rule.destination.access_control_translation.owner
            }
          }
          dynamic "encryption_configuration" {
            for_each = var.replication_configuration.rule.destination.encryption_configuration != null ? [0] : []
            content {
              replica_kms_key_id = var.replication_configuration.rule.destination.encryption_configuration.replica_kms_key_id
            }
          }
          dynamic "metrics" {
            for_each = var.replication_configuration.rule.destination.metrics != null ? [0] : []
            content {
              dynamic "event_threshold" {
                for_each = var.replication_configuration.rule.destination.metrics.event_threshold != null ? [0] : []
                content {
                  minutes = var.replication_configuration.rule.destination.metrics.event_threshold.minutes
                }
              }
              status = var.replication_configuration.rule.destination.metrics.status
            }
          }
          dynamic "replication_time" {
            for_each = var.replication_configuration.rule.destination.replication_time != null ? [0] : []
            content {
                dynamic "time" {
                  for_each = var.replication_configuration.rule.destination.replication_time.time != null ? [0] : []
                  content {
                    minutes = var.replication_configuration.rule.destination.replication_time.time.minutes
                  }
                }
              status = var.replication_configuration.rule.destination.replication_time.status
            }
          }
          account = var.replication_configuration.rule.destination.account
          bucket = var.replication_configuration.rule.destination.bucket
          storage_class = var.replication_configuration.rule.destination.storage_class
        }
      }
      dynamic "filter" {
        for_each = var.replication_configuration.rule.filter != null ? [0] : []
        content {
            dynamic "and" {
              for_each = var.replication_configuration.rule.filter.and != null ? [0] : []
              content {
                prefix = var.replication_configuration.rule.filter.and.prefix
                tags = var.replication_configuration.rule.filter.and.tags
              }
            }
            dynamic "tag" {
              for_each = var.replication_configuration.rule.filter.tag != null ? [0] : []
              content {
                key = var.replication_configuration.rule.filter.tag.key
                value = var.replication_configuration.rule.filter.tag.value
              }
            }
          prefix = var.replication_configuration.rule.filter.prefix
        }
      }
      dynamic "source_selection_criteria" {
        for_each = var.replication_configuration.rule.source_selection_criteria != null ? [0] : []
        content {
            dynamic "replica_modifications" {
              for_each = var.replication_configuration.rule.source_selection_criteria.replica_modifications != null ? [0] : []
              content {
                status = var.replication_configuration.rule.source_selection_criteria.replica_modifications.status
              }
            }
            dynamic "sse_kms_encrypted_objects" {
              for_each = var.replication_configuration.rule.source_selection_criteria.sse_kms_encrypted_objects != null ? [0] : []
              content {
                status = var.replication_configuration.rule.source_selection_criteria.sse_kms_encrypted_objects.status
              }
            }
        }
      }
      dynamic "existing_object_replication" {
        for_each = var.replication_configuration.rule.existing_object_replication != null ? [0] : []
        content {
          status = var.replication_configuration.rule.existing_object_replication.status
        }
      }
    }
  }
}




resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  count = var.server_side_encryption_configuration != null ? 1 : 0
  bucket = aws_s3_bucket.main.id
  expected_bucket_owner = var.server_side_encryption_configuration.expected_bucket_owner

  dynamic "rule" {
    for_each = var.server_side_encryption_configuration.rule != null ? [0] : []
    content {
      bucket_key_enabled = var.server_side_encryption_configuration.rule.bucket_key_enabled
        dynamic "apply_server_side_encryption_by_default" {
          for_each = var.server_side_encryption_configuration.rule.apply_server_side_encryption_by_default != null ? [0] : []
          content {
            sse_algorithm = var.server_side_encryption_configuration.rule.apply_server_side_encryption_by_default.sse_algorithm
            kms_master_key_id = var.server_side_encryption_configuration.rule.apply_server_side_encryption_by_default.kms_master_key_id
          }
        }
    }
  }
}

resource "aws_s3_bucket_object_lock_configuration" "main" {
  count = var.object_lock_configuration != null ? 1 : 0
  bucket = aws_s3_bucket.main.id
  expected_bucket_owner = var.object_lock_configuration.expected_bucket_owner
  object_lock_enabled = var.object_lock_configuration.object_lock_enabled
  token = var.object_lock_configuration.token

  dynamic "rule" {
    for_each = var.object_lock_configuration.rule != null ? [0] : []
    content {
        dynamic "default_retention" {
          for_each = var.object_lock_configuration.rule.default_retention != null ? [0] : []
          content {
            days = var.object_lock_configuration.rule.default_retention.days
            mode = var.object_lock_configuration.rule.default_retention.mode
            years = var.object_lock_configuration.rule.default_retention.years
          }
        }
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "main" {
  count = var.bucket_ownership_controls != null ? 1 : 0
  bucket = aws_s3_bucket.main.id

  dynamic "rule" {
    for_each = var.bucket_ownership_controls.rule != null ? [0] : []
    content {
      object_ownership = var.bucket_ownership_controls.rule.object_ownership
    }
  }
}

resource "aws_s3_bucket_acl" "main" {
  depends_on = [aws_s3_bucket_ownership_controls.main]
  count = var.aws_s3_bucket_acl != null ? 1 : 0

  bucket = aws_s3_bucket.example.id
  acl    = var.acl
  expected_bucket_owner = var.expected_bucket_owner
  dynamic "access_control_policy" {
    for_each = var.aws_s3_bucket_acl.access_control_policy != null ? [0] : []
    content {
      dynamic "grant" {
        for_each = var.aws_s3_bucket_acl.access_control_policy.grant != null ? [0] : []
        content {
          grantee = var.aws_s3_bucket_acl.access_control_policy.grant.grantee
          permission = var.aws_s3_bucket_acl.access_control_policy.grant.permission
        }
      }
      dynamic "owner" {
        for_each = var.aws_s3_bucket_acl.access_control_policy.owner != null ? [0] : []
        content {
          id = var.aws_s3_bucket_acl.access_control_policy.owner.id
          display_name = var.aws_s3_bucket_acl.access_control_policy.owner.display_name
        }
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  count = var.attach_public_policy != null ? 1 : 0

  bucket = aws_s3_bucket.main.id
  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_accelerate_configuration" "main" {
  count = var.acceleration_status != null ? 1 : 0

  bucket = aws_s3_bucket.main.id
  expected_bucket_owner = var.expected_bucket_owner
  status = var.acceleration_status
}


resource "aws_s3_bucket_request_payment_configuration" "main" {
  count = var.request_payer != null ? 1 : 0

  bucket = aws_s3_bucket.main.id
  payer  = var.request_payer
}