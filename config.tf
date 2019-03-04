// things need to do: 
// 1. Change api key
// 2. Change ssh key 
// 3. Change main instance
// 4. Change remote execute private key
// 5. Change remote execute github repo that you are deploying
// 6. Change last remote execute for handling ansible playbook and steps after that


provider "vultr" {
    api_key = "INSERT_YOUR_OWN_KEY"
}

data "vultr_region" "sydney" {
    filter {
        name = "name"
        values = [
            "Sydney"]
    }
}

// Find the ID for CoreOS Container Linux.
data "vultr_os" "centos" {
    filter {
        name = "name"
        values = [
            "CentOS 7 x64"]
    }
}

// Change according to the plan you want
data "vultr_plan" "starter" {
    filter {
        name = "price_per_month"
        values = [
            "10.00"]
    }

    filter {
        name = "ram"
        values = [
            "2048"]
    }
}

// Find the ID of an existing SSH key.
// Please ensure that you have your key inside the platform you are trying to deploy to
data "vultr_ssh_key" "myNewMBP" {
    filter {
        name = "name"
        values = [
            "myNewMBP"
        ]
    }
}

// main instance of your deployment
resource "vultr_instance" "bob" {
    name = "bob"
    region_id = "${data.vultr_region.sydney.id}"
    plan_id = "${data.vultr_plan.starter.id}"
    os_id = "${data.vultr_os.centos.id}"
    ssh_key_ids = [
        "${data.vultr_ssh_key.myNewMBP.id}"]
    hostname = "bob"
    firewall_group_id = "${vultr_firewall_group.firewall.id}"

    provisioner "local-exec" {
        command = "echo ${vultr_instance.bob.hostname}"
    }

}

resource "null_resource" "bobSetup" {

    connection {
        host = "${vultr_instance.bob.ipv4_address}"
    }

    provisioner "remote-exec" {
        inline = [
            "sudo yum install -y python ansible git"
            ]

        connection {
            type = "ssh"
            user = "root"
            private_key = "${file("~/.ssh/id_rsa")}"
        }
    }


    provisioner "remote-exec" {
        inline = [
            "cd /root && ssh-keyscan github.com >> ~/.ssh/known_hosts && echo \"PUT_YOUR_PRIVATE_KEY_HERE" > .ssh/id_rsa && chmod 0600 .ssh/id_rsa "
            ]

        connection {
            type = "ssh"
            user = "root"
            private_key = "${file("~/.ssh/id_rsa")}"
        }
    }
    
    // DONT FORGET TO CHANGE THE REPO THAT YOU ARE TRYING TO DEPLOY
    // PLEASE ENSURE THAT YOU HAVE AN ENV AND ANSIBLE DIRECTORY CONTAINING ANSIBLE PLAYBOOKS INSIDE TO RUN 
    // UPDATE THIS REMOTE EXEC FILE ACCORDING TO WHAT YOU NEED TO DO AFTER RUNNING THE ANSIBLE PLAYBOOK
    provisioner "remote-exec" {
        inline = [
            "cd /root && ssh-keyscan github.com >> ~/.ssh/known_hosts && git clone git@github.com:bob/bob.git && cd bob && git checkout master && git pull && cd env/ansible && ansible-playbook -i ./host bob-services.yaml && source ~/.bash_profile && cd /go/into/bob && go get"
            ]

        connection {
            type = "ssh"
            user = "root"
            private_key = "${file("~/.ssh/id_rsa")}"
        }
    }

}


// Create a new firewall group.
resource "vultr_firewall_group" "firewall" {
    description = "Basic firewall setup"
}

// Add a firewall rule to the group allowing SSH access.
resource "vultr_firewall_rule" "ssh" {
    firewall_group_id = "${vultr_firewall_group.firewall.id}"
    cidr_block = "0.0.0.0/0"
    protocol = "tcp"
    from_port = 22
    to_port = 22
}