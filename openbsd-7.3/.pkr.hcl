source "virtualbox-iso" "default" {
  guest_os_type = "OpenBSD_64"

  # Use 2 vCPUs to install OpenBSD, so that it will use the bsd.mp kernel.
  cpus = 2

  # The VM needs 1024 MB of RAM in order install successfully.
  memory = 1024

  disk_size            = 14000 # 14 GB
  hard_drive_interface = "scsi"
  nic_type             = "virtio"

  iso_interface	= "sata"
  iso_url       = "https://cdn.openbsd.org/pub/OpenBSD/7.3/amd64/install73.iso"
  iso_checksum  = "file:https://cdn.openbsd.org/pub/OpenBSD/7.3/amd64/SHA256"

  ssh_username = "root"
  ssh_password = "vagrant"

  guest_additions_mode = "disable" # OpenBSD is unsupported
  shutdown_command     = "shutdown -p now"

  boot_wait = "50s"
  boot_command = [
    "A<enter>",
    "<wait>",
    "https://raw.githubusercontent.com/mario-campos/emulate/main/openbsd-7.3/install.conf<enter>",
  ]
}

build {
  sources = ["sources.virtualbox-iso.default"]

  provisioner "file" {
    source      = "${path.root}/sshd_config"
    destination = "/etc/ssh/sshd_config"
  }

  provisioner "shell" {
    inline = ["pkg_add git got cmake meson autoconf-2.71 automake-1.16.5 libtool"]
  }

  post-processors {
    post-processor "vagrant" {
      vagrantfile_template_generated = false
    }
  }
}
