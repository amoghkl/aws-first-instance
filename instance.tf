

#output "keyname" {
#  value = aws_key_pair.key-tf.key_name
#}


#output "securityGroupDetails" {
#  value = aws_security_group.allow_tls.id
#}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["${var.image_name}"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

#creating instance
resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.key-tf.key_name
  vpc_security_group_ids = ["${aws_security_group.allow_tls.id}"]
  tags = {
    Name = "first-tf-instance"
  }
  user_data = file("${path.module}/script.sh")

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${path.module}/id_rsa")
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "readme.md"      #terraform residing machine
    destination = "/tmp/readme.md" #remote machine
  }

  provisioner "file" {
    content     = "this is test content" #terraform residing machine
    destination = "/tmp/content.md"      #remote machine
  }

  provisioner "local-exec" {
    command = "echo ${self.public_ip} > /tmp/mypublicip.txt"
  }

  provisioner "local-exec" {
    working_dir = "/tmp/"
    command     = "echo ${self.public_ip} > mypublicipintmp.txt"
  }

  provisioner "local-exec" {
    on_failure = continue
    command    = "env>env.txt"
    environment = {
      envname = "envvalue"
    }
  }

  provisioner "local-exec" {
    command = "echo 'at Create'"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "echo 'at delete'"
  }

  provisioner "remote-exec" {
    inline = [
      "ifconfig > /tmp/ifconfig.output",
      "echo 'hello amogh' > /tmp/test.txt"
    ]
  }

  provisioner "remote-exec" {
    on_failure = continue
    script     = "./testscript.sh"
  }


  #provisioner "local-exec" {
  #  interpreter = [
  #    "usr/bin/python3", "-c"
  #  ]
  #  command = "print('Hello World')"
  #}

  #provisioner "file" {
  #    source      = "D:/Demo/redis_json"
  #    destination = "/tmp/"
  #  }
  #  user_data = <<EOF
  #!/bin/bash
  #sudo apt-get update
  #sudo apt-get install nginx -y
  #sudo echo "Hi Amogh" >/var/www/html/index.nginx-debian.html
  #EOF  
}

#ssh -i id_rsa ubuntu@34.238.84.32