resource "google_storage_bucket" "brain_backup" {
  name          = "${var.gcp_project_id}-brain-private"
  location      = var.gcp_region
  storage_class = "NEARLINE"
  force_destroy = false

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 365
    }
  }
}

output "backup_bucket_name" {
  value = google_storage_bucket.brain_backup.name
}
