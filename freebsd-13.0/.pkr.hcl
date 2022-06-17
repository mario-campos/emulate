locals {
  version      = "0.1.3"
  ssh_password = "vagrant"
}

source "virtualbox-iso" "default" {
  guest_os_type = "FreeBSD_64"

  disk_size            = 14000 # 14 GB
  hard_drive_interface = "scsi"
  nic_type             = "virtio"

  iso_url      = "https://download.freebsd.org/ftp/releases/amd64/amd64/ISO-IMAGES/13.0/FreeBSD-13.0-RELEASE-amd64-disc1.iso"
  iso_checksum = "file:https://download.freebsd.org/ftp/releases/amd64/amd64/ISO-IMAGES/13.0/CHECKSUM.SHA256-FreeBSD-13.0-RELEASE-amd64"

  ssh_username = "root"
  ssh_password = local.ssh_password

  guest_additions_mode = "disable"
  acpi_shutdown        = true

  boot_command = [
    # Menu prompt
    "<enter><wait15s>",

    # Welcome
    "I<wait5>", # Install

    # Keymap selection
    "<enter><wait>",

    # Set Hostname
    "freebsd.local<enter><wait>",

    # Distribution Select
    "k<spacebar>", # deselect kernel-dbg
    "<enter><wait>",

    # Partitioning
    "<down><enter><wait>", # Auto (UFS)

    # Partition
    "E<wait>", # Entire Disk

    # >Partition Scheme
    "<enter><wait>", # MBR

    # Partition Editor
    "F<wait>", # Finish

    # Confirmation
    "C<wait30s>", # Commit

    # Root Password
    "${local.ssh_password}<enter><wait>",
    "${local.ssh_password}<enter><wait>",

    # Network Configuration
    "<enter><wait>",

    # Configure IPv4
    "Y<wait>", # Yes

    # Configure DHCP
    "Y<wait10>", # Yes

    # Configure IPv6
    "N<wait>", # No

    # DNS Configuration
    "<enter><wait>",

    # Select a region
    "0<enter><wait>", # UTC

    # Confirmation
    "Y<wait>", # Yes

    # Calendar
    "S<wait>", # Skip

    # Time & Date
    "S<wait>", # Skip

    # System Configuration
    "n<spacebar><wait>", # select ntpdate
    "d<spacebar><wait>", # deselect dumpdev
    "<enter><wait>",

    # System Hardening
    "<enter><wait>",

    # Add User Accounts
    "N<wait>", # No

    # Final Configuration
    "<enter><wait>", # Exit

    # Manual Configuration
    "Y<wait>", # Yes

    # Permit root to SSH in.
    "sed -i -e 's/^#PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config<enter><wait>",

    # Disable autoboot delay and prevent user from interrupting it.
    "echo 'autoboot_delay=\"-1\"' >> /boot/loader.conf<enter><wait>",

    # Change root's shell, so the 'shell' provisioner will work.
    "chsh -s /bin/sh root<enter><wait>",

    # Create ~/.ssh, because Packer will not create parent directories with the 'file' provisioner.
    "mkdir -m 0700 /root/.ssh<enter><wait>",

    # Return to installation prompt.
    "exit<enter><wait>",

    # Complete
    "R" # Reboot
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
    environment_vars = ["ASSUME_ALWAYS_YES=yes"]
    inline = [
      "pkg update -f",
      "pkg install autoconf automake cmake git got libtool meson pkgconf",
    ]
  }

  post-processors {
    post-processor "vagrant" {
      vagrantfile_template_generated = false
    }
  }
}
