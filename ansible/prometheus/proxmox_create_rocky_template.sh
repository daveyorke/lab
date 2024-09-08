# Execute these commands from PVE-01
#
# grab Rocky 9 cloud image:
wget https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2

# get libguestfs to install packages to the disk image (on PVE-01)
apt update && apt install libguestfs-tools

# use virt-customize to install guest tools into our image - NOT REQUIRED FOR ROCKY LINUX
#virt-customize -a Rocky-9-GenericCloud-Base.latest.x86_64.qcow2 --verbose --install qemu-guest-agent,liburing

# create VM template
qm create 9004 --name "rocky9-cloudinit-template" --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0,tag=88

# import cloudinit image
qm importdisk 9004 Rocky-9-GenericCloud-Base.latest.x86_64.qcow2 cephpool01

# attach disk to template
qm set 9004 --scsihw virtio-scsi-pci --scsi0 cephpool01:vm-9004-disk-0

# set boot order
qm set 9004 --boot c --bootdisk scsi0

# attach cloud init drive
qm set 9004 --ide2 cephpool01:cloudinit

# set up serial console
qm set 9004 --serial0 socket --vga serial0

# enable guest agent
qm set 9004 --agent enabled=1

# make it a template
qm template 9004
