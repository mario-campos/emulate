locals {
  ssh_password = "vagrant"
}

source "virtualbox-iso" "openbsd" {
  guest_os_type = "OpenBSD_64"

  iso_url      = "https://cdn.openbsd.org/pub/OpenBSD/7.0/amd64/install70.iso"
  iso_checksum = "file:https://cdn.openbsd.org/pub/OpenBSD/7.0/amd64/SHA256"

  ssh_username = "root"
  ssh_password = local.ssh_password

  disk_size            = 14336 # 14 GB
  hard_drive_interface = "scsi"

  guest_additions_mode = "disable" # OpenBSD is unsupported
  shutdown_command     = "shutdown -p now"

  http_content = {
    "/install.conf" = templatefile("install.conf.template", {
      root_password = local.ssh_password
    })
  }

  boot_wait = "20s"
  boot_command = [
    "A<enter>",
    "<wait>",
    "http://{{ .HTTPIP }}:{{ .HTTPPort }}/install.conf<enter>",
  ]
}

build {
  sources = ["sources.virtualbox-iso.openbsd"]
  provisioner "shell" {
    inline = [
      "rcctl disable cron pflogd slaacd sndiod",
      "pkg_add git-2.33.0 got-0.60",
    ]
  }
}
