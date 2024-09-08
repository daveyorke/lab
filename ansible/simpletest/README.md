# Ansible learnings
Context: newly-deployed Rocky linux vm from cloud-init, using my *dave* ssh keys

Created testfolder
Created inventory file
```bash
[rocky]
rocky9-01.dave.lan
```
Created static DHCP mapping in Pfsense to map rocky to 192.168.88.101 (although IP  addresses work too in the inventory)


Attempted:
```bash
ansible -m ping  rocky -i inventory.txt

The authenticity of host 'rocky9-01.dave.lan (192.168.88.101)' can't be established.
ED25519 key fingerprint is SHA256:C5hNcar6px0y8T7jgqV6mMOf7qUIXPoni1FLzuRDlWg.
This host key is known by the following other names/addresses:
    ~/.ssh/known_hosts:40: [hashed name]
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```

Created ~/.ansible.cfg for my customizations (home lab testing only, wouldn't do this in prod)
This will allow me to run ansible playbooks against new machines without having to interact.
```
[defaults]
host_key_checking = False
```
**(Stowed and pushed this config to my git repo (.stowdotfiles))**

Next run:
```bash
ansible -m ping  rocky -i inventory.txt 

rocky9-01.dave.lan | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}

```

### Now try installing package
```bash

#using only ansible command
ansible -m dnf rocky -i inventory.txt -a 'name=htop state=latest'

rocky9-01.dave.lan | FAILED! => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "msg": "This command has to be run under the root user.",
    "results": []
}

```

with become and prompt for password:
```bash
ansible -m dnf rocky -i inventory.txt -a 'name=htop state=latest' -b -K

BECOME password: 
rocky9-01.dave.lan | FAILED! => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "failures": [
        "No package htop available."
    ],
    "msg": "Failed to install some of the specified packages",
    "rc": 1,
    "results": []
}

```

Couldn't find htop, probably need to enable EPEL repository. (did this locally on rocky9)

```bash
dnf config-manager --set-enabled crb
dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
```


SUCCESS!
```bash
ansible -m dnf rocky -i inventory.txt -a 'name=htop state=latest' -b -K

BECOME password: 
rocky9-01.dave.lan | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": true,
    "msg": "",
    "rc": 0,
    "results": [
        "Installed: hwloc-libs-2.4.1-5.el9.x86_64",
        "Installed: htop-3.3.0-1.el9.x86_64"
    ]
}

