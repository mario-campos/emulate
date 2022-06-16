locals {
  version      = "0.1.1"
  ssh_password = "vagrant"
}

source "virtualbox-iso" "default" {
  guest_os_type = "NetBSD_64"

  disk_size            = 14000 # 14 GB
  hard_drive_interface = "scsi"

  iso_url      = "https://cdn.netbsd.org/pub/NetBSD/NetBSD-9.2/images/NetBSD-9.2-amd64.iso"
  iso_checksum = "sha512:5ee0ea101f73386b9b424f5d1041e371db3c42fdd6f4e4518dc79c4a08f31d43091ebe93425c9f0dcaaed2b51131836fe6774f33f89030b58d64709b35fda72f"

  ssh_username = "root"
  ssh_password = local.ssh_password

  guest_additions_mode = "disable"
  acpi_shutdown        = true

  boot_wait = "30s"
  boot_command = [
    # Language selection
    "<enter><wait>",	# English

    # Keyboard type
    "b<enter><wait>",	# US-English

    # Installation menu
    "<enter><wait>",	# Install NetBSD to hard disk

    # Shall we continue?
    "b<enter><wait>",	# Yes

    # Which disk?
    "<enter><wait>",    # sd0

    # Partitioning scheme
    "<enter><wait>",	# GPT

    # Correct geometry?
    "<enter><wait>",	# This is the correct geometry

    # How to partition?
    "b<enter><wait>",	# Use default partition sizes

    # Review: partition sizes
    "<enter><wait>",	# Partition sizes OK

    # Shall we continue?
    "b<enter><wait>",	# Yes

    # Select bootblocks
    "<enter><wait>",	# Use BIOS console

    # Select your distribution
    "<enter><wait>",	# Full installation

    # Install from
    "<enter><wait1m>",	# install media

    # Installation complete
    "<enter><wait>",	# Hit enter to continue

    # Configure additional items
    "a<enter><wait>",	# Configure network

    # Which network interface?
    "<enter><wait>",	# wm0

    # Network media type
    "<enter><wait>",	# autoselect

    # Perform autoconfiguration
    "<enter><wait15>",	# Yes

    # Are they OK?
    "<enter><wait>",	# Yes

    # Do you want it installed in /etc?
    "<enter><wait>",	# Yes

    "d<enter><wait>",	# Set root password

    # Are you sure?
    "<enter><wait>",	# Yes

    # Enter password
    "${local.ssh_password}<enter><wait>", # this first one is a warning
    "${local.ssh_password}<enter><wait>",
    "${local.ssh_password}<enter><wait>",

    "g<enter>",		# Enable sshd
    "h<enter>",		# Enable ntpd
    "i<enter>",		# Run ntpdate at boot
    "l<enter>",		# Disable cgd
    "n<enter>",		# Disable raidframe
    "x<enter>",		# Finished configuring

    # Hit enter to continue
    "<enter><wait>",

    # Installation menu
    "d<enter><wait1m>",# Reboot

    # Login prompt
    "root<enter><wait>",
    "${local.ssh_password}<enter><wait>",

    # Modify sshd_config to enable root login
    "sed -i 's/^#PermitRootLogin.*$/PermitRootLogin yes/' /etc/ssh/sshd_config<enter>",
    "service sshd restart<enter>",
  ]
}

build {
  sources = ["sources.virtualbox-iso.default"]

  provisioner "shell" {
    environment_vars = ["PKG_PATH=https://cdn.netbsd.org/pub/pkgsrc/packages/NetBSD/x86_64/9.2/All"]
    inline = [
      "/usr/sbin/pkg_add git got clang cmake meson pkg-config autoconf automake libtool ca-certificates",
    ]
  }

  provisioner "file" {
    source      = "${path.root}/sshd_config"
    destination = "/etc/ssh/sshd_config"
  }

  provisioner "file" {
    source      = "${path.root}/authorized_keys"
    destination = "authorized_keys"
  }

  provisioner "shell" {
    inline = [
      "mkdir -m 0700 .ssh",
      "install -m 0600 authorized_keys .ssh",
    ]
  }

  post-processors {
    post-processor "vagrant" {
      vagrantfile_template_generated = false
    }
  }
}
