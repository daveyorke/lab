resource "proxmox_vm_qemu" "rocky_linux" {
    count = 1
    name = "fedora40-0${count.index + 1}"
    desc = "Testing fedora 40 cloud init"

    # Node name has to be the same name as within the cluster
    # this might not include the FQDN
    target_node = "pve-01"

    # The destination resource pool for the new VM
    # pool = "pool0"

    # The template name to clone this vm from
    clone = "fedoracloud40-cloudinit-template"

    # Activate QEMU agent for this VM
    agent = 1

    # VMID to keep things in order, since they build in parallel
    vmid = "40${count.index + 1}"

    os_type = "cloud-init"
    cores = 4
    sockets = 1
    vcpus = 4
    cpu = "x86-64-v2-AES"
    memory = 4096
    scsihw = "virtio-scsi-single"

    ciuser = "dave"

    # Setup the disk
    disks {
        ide {
            ide2 {
                cloudinit {
                    storage = "cephpool01"
                }
            }
        }
        scsi {
            scsi0 {
                disk {
                    size            = 10
#                    cache           = "writeback"
                    storage         = "cephpool01"
#                    storage_type    = "rbd"
#                    iothread        = true
#                    discard         = true
                }
            }
        }
    }

    # Setup the network interface and assign a vlan tag: 256
    network {
        model = "virtio"
        bridge = "vmbr0"
        tag = 88
    #   macaddr = "bc:24:11:aa:aa:0${count.index + 4}"
    }

    # Setup the ip address using cloud-init.
    boot = "order=scsi0"
    # Keep in mind to use the CIDR notation for the ip.
    ipconfig0 = "ip=dhcp"

    sshkeys = var.sshkeys
}
