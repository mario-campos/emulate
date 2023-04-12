locals {
  version      = "0.1.1"
  ssh_password = "vagrant"
}

source "virtualbox-iso" "default" {
  guest_os_type = "OpenBSD_64"

  # Use 2 vCPUs to install OpenBSD, so that it will use the bsd.mp kernel.
  cpus = 2

  # The VM needs 1024 MB of RAM in order install successfully.
  memory = 1024

  disk_size            = 14000 # 14 GB
  hard_drive_interface = "scsi"
  nic_type             = "virtio"

  iso_url      = "https://cdn.openbsd.org/pub/OpenBSD/7.2/amd64/install72.iso"
  iso_checksum = "file:https://cdn.openbsd.org/pub/OpenBSD/7.2/amd64/SHA256"

  ssh_username = "root"
  ssh_password = local.ssh_password

  guest_additions_mode = "disable" # OpenBSD is unsupported
  acpi_shutdown        = true

  http_content = {
    "/install.conf" = templatefile("install.conf.template", {
      root_password = local.ssh_password
      disklabel_url = "https://raw.githubusercontent.com/mario-campos/emulate/main/openbsd-7.1/disklabel.template"
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

  # Disable unnecessary services to save CPU cycles.
  provisioner "shell" {
    inline = [
      "rcctl disable check_quotas cron dhcpleased library_aslr ntpd pf pflogd resolvd slaacd smtpd sndiod syslogd",
    ]
  }

  provisioner "shell" {
    inline = ["pkg_add git got cmake meson autoconf-2.71 automake-1.16.5 libtool"]
  }

  # Run dhclient instead of running dhcpleased; save some CPU cycles.
  provisioner "shell" {
    inline = ["echo '!dhclient \\$if' > /etc/hostname.vio0"]
  }

  # Disable KARL (since it's useless in a CI/CD VM) and set date and time at first-boot
  # in one fell swoop.
  provisioner "shell" {
    inline = ["sed -i 's|/usr/libexec/reorder_kernel &|rdate time.cloudflare.com|' /etc/rc"]
  }

  # syspatch(8) may sometimes "fail" (with an exit code of 2) if it must update
  # itself first. No worries -- just gotta run it again.
  provisioner "shell" {
    inline           = ["syspatch"]
    valid_exit_codes = [0, 2]
  }
  provisioner "shell" {
    inline = ["syspatch"]
    valid_exit_codes = [0, 2]
  }

  post-processors {
    post-processor "vagrant" {
      vagrantfile_template_generated = false
    }
  }
}
