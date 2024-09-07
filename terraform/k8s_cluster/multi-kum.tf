resource "proxmox_vm_qemu" "k8s-masters" {
    count = 3
    name = "kum0${count.index + 1}"
    desc = "A test for using terraform and cloudinit"

    # Node name has to be the same name as within the cluster
    # this might not include the FQDN
    target_node = "pve-0${count.index + 1}"

    # The destination resource pool for the new VM
    # pool = "pool0"

    # The template name to clone this vm from
    clone = "ubuntu-2204-cloudinit-template2"

    # Activate QEMU agent for this VM
    agent = 1

    # VMID to keep things in order, since they build in parallel
    vmid = "80${count.index + 1}"
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
        virtio {
            virtio0 {
                disk {
                    size            = 32
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
        macaddr = "bc:24:11:aa:aa:0${count.index + 1}"
    }

    # Setup the ip address using cloud-init.
    boot = "order=virtio0"
    # Keep in mind to use the CIDR notation for the ip.
    ipconfig0 = "ip=dhcp"

    sshkeys = var.sshkeys
}
