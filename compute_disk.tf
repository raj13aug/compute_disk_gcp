resource "google_compute_disk" "additional_disk" {
  name = "adds-disk"
  size = var.disk_size
  type = var.disk_type
  zone = "${local.region}-a"
}
resource "google_compute_attached_disk" "attachvmtoaddtnl" {
  disk     = google_compute_disk.additional_disk[count.index].id
  instance = google_compute_instance.demo
  zone     = "${local.region}-a"
  depends_on = [
    google_compute_disk.additional_disk
  ]
}