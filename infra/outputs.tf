output "vm_external_ip" {
  description = "External IP of the brain VM"
  value       = google_compute_address.brain_ip.address
}

output "vm_name" {
  description = "Name of the brain VM"
  value       = google_compute_instance.brain.name
}
