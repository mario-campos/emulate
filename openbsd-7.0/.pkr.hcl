variables {
  headless = true
}

locals {
  version      = "0.1.0"
  ssh_password = "vagrant"
}

source "virtualbox-iso" "default" {
  guest_os_type = "OpenBSD_64"

  cpus   = 2
  memory = 14 * 1024 * 0.75

  disk_size            = 10 * 1024
  hard_drive_interface = "scsi"

  iso_url      = "https://cdn.openbsd.org/pub/OpenBSD/7.0/amd64/install70.iso"
  iso_checksum = "file:https://cdn.openbsd.org/pub/OpenBSD/7.0/amd64/SHA256"

  ssh_username = "root"
  ssh_password = local.ssh_password

  guest_additions_mode = "disable" # OpenBSD is unsupported
  shutdown_command     = "shutdown -p now"
  headless             = var.headless

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
  sources = ["sources.virtualbox-iso.default"]

  provisioner "file" {
    source      = "${path.root}/sshd_config"
    destination = "/etc/ssh/sshd_config"
  }

  provisioner "file" {
    source      = "${path.root}/authorized_keys"
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
      vagrantfile_template = "${path.root}/Vagrantfile"
    }
    post-processor "vagrant-cloud" {
      box_tag = "emulate/${basename(abspath(path.root))}"
      version = local.version
    }
  }
}
