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

  headless             = true
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

  provisioner "file" {
    source      = "sshd_config"
    destination = "/etc/ssh/sshd_config"
  }

  provisioner "file" {
    source      = "authorized_keys"
    destination = ".ssh/authorized_keys"
  }

  provisioner "shell" {
    inline = [
      "rcctl disable cron pflogd slaacd sndiod",
      "pkg_add git-2.33.0 got-0.60",
    ]
  }

  post-processors {
    post-processor "vagrant" {
      compression_level    = 9
      vagrantfile_template = "Vagrantfile"
    }
    post-processor "vagrant-cloud" {
      box_tag             = "emulate/openbsd-7.0"
      version             = "0.1.4"
      keep_input_artifact = false
    }
  }
}
