locals {
  username = "runner"
  password = "vagrant"
}

source "virtualbox-iso" "openbsd" {
  guest_os_type = "OpenBSD_64"

  iso_url = "https://cdn.openbsd.org/pub/OpenBSD/6.9/amd64/install69.iso"
  iso_checksum = "file:https://cdn.openbsd.org/pub/OpenBSD/6.9/amd64/SHA256"

  ssh_username = local.username
  ssh_password = local.password

  shutdown_command = "shutdown -p now"
  disk_size = 10240 # 10 GB
  guest_additions_mode = "disable"

  http_content = {
    "/install.conf" = templatefile("${path.root}/install.conf.template", {
      username = local.username,
      password = local.password,
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
}
