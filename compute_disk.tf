resource "google_compute_disk" "additional_disk" {
  name = "persistent-disk"
  size = var.disk_size
  type = var.disk_type
  zone = "${local.region}-a"
}
resource "google_compute_attached_disk" "attachvmtoaddtnl" {
  disk     = google_compute_disk.additional_disk.id
  instance = google_compute_instance.demo.id
  zone     = "${local.region}-a"
  depends_on = [
    google_compute_disk.additional_disk
  ]
}