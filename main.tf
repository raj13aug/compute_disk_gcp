data "google_compute_image" "demo" {
  family  = "ubuntu-2204-lts"
  project = "ubuntu-os-cloud"
}

locals {
  region            = "us-central1"
  availability_zone = "us-central1-a"
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
}

resource "google_compute_address" "external-static-ip" {
  name   = "ip-${var.name}"
  region = var.region
}

resource "google_compute_instance" "demo" {
  project = var.project_id

  name         = var.name
  machine_type = "e2-micro"
  zone         = "${local.region}-a"

  tags = ["demo"]

  boot_disk {
    auto_delete = true

    initialize_params {
      image = data.google_compute_image.demo.self_link

      labels = {
        managed_by = "terraform"
      }
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.external-static-ip.address
    }
  }


  metadata = {
    sshKeys = "ubuntu:${tls_private_key.ssh.public_key_openssh}"
  }

  # We can install any tools we need for the demo in the startup script
  metadata_startup_script = <<EOT
    sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb 
    sudo mkdir -p /data-mount 
    sudo mount -o discard,defaults /dev/sdb /data-mount 
    sudo chmod a+w /data-mount 
    sudo cp /etc/fstab /etc/fstab.backup 
    echo UUID=`sudo blkid -s UUID -o value /dev/sdb` /data-mount ext4 discard,defaults,noatime,nofail 0 2 | sudo tee -a /etc/fstab 
EOT

  depends_on = [google_compute_address.external-static-ip]

}


resource "google_compute_firewall" "demo-ssh-ipv4" {


  name    = "staging-demo-ssh-ipv4"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = [22]
  }

  allow {
    protocol = "udp"
    ports    = [22]
  }

  allow {
    protocol = "sctp"
    ports    = [22]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = google_compute_instance.demo.tags
}


resource "local_file" "local_ssh_key" {
  content  = tls_private_key.ssh.private_key_pem
  filename = "${path.root}/ssh-keys/ssh_key"
}

resource "local_file" "local_ssh_key_pub" {
  content  = tls_private_key.ssh.public_key_openssh
  filename = "${path.root}/ssh-keys/ssh_key.pub"
}

output "instance_ip" {
  value = google_compute_instance.demo.network_interface.0.access_config.0.nat_ip
}

output "instance_ssh_key" {
  value      = "${abspath(path.root)}/ssh_key"
  depends_on = [tls_private_key.ssh]
}
