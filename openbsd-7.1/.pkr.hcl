locals {
  version      = "0.1.0"
  ssh_password = "vagrant"
}

source "virtualbox-iso" "default" {
  guest_os_type = "OpenBSD_64"

  cpus   = 2
  memory = 14 * 1024 * 0.75

  disk_size            = 14000 # 14 GB
  hard_drive_interface = "scsi"

  iso_url      = "https://cdn.openbsd.org/pub/OpenBSD/7.1/amd64/install71.iso"
  iso_checksum = "file:https://cdn.openbsd.org/pub/OpenBSD/7.1/amd64/SHA256"

  ssh_username = "root"
  ssh_password = local.ssh_password

  guest_additions_mode = "disable" # OpenBSD is unsupported
  acpi_shutdown        = true

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
      "pkg_add git got cmake meson autoconf-2.71 automake-1.16.3 libtool",
    ]
  }

  provisioner "shell" {
    inline = ["syspatch"]

    # An exit code of 2 from syspatch(8) indicates that we tried to install patches,
    # but we could not. In OpenBSD 7.1, this can happen when syspatch(8) must update
    # itself first.
    valid_exit_codes = [0, 2]
  }

  post-processors {
    post-processor "vagrant" {
      vagrantfile_template_generated = false
    }
  }
}
