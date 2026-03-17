provider "aws" {
  region = var.aws_region
}

# สร้าง Key Pair ใหม่และบันทึก Private Key ลงไฟล์ (เฉพาะถ้ายังไม่มี)
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.example.public_key_openssh
 
  # ป้องกันการแทนที่ Key Pair เดิมถ้ามีอยู่แล้วใน AWS หรือ State
  lifecycle {
    ignore_changes = [public_key]
  }
}

resource "local_file" "private_key" {
  content         = tls_private_key.example.private_key_pem
  filename        = "${path.module}/${var.key_name}.pem"
  file_permission = "0400"
 
  # ป้องกันการสร้างไฟล์ใหม่หากมีอยู่แล้ว (ในระดับ Logic ของ Terraform คือถ้า Content เปลี่ยนถึงจะแก้)
  # แต่ tls_private_key ปกติจะเสถียรใน State file
}

resource "aws_security_group" "app_sg" {
  name_prefix = "app_sg"
  description = "Security Group for App and DB"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  ingress {
    from_port   = 3008
    to_port     = 3008
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 4. สร้าง EC2 โดยใช้ Variables
resource "aws_instance" "nodejs_server" {
  ami                    = "ami-0ed0867532b47cc2c"
  instance_type          = var.instance_type # ดึงจาก Variable
  key_name               = var.key_name      # ดึงจาก Variable
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
             
              echo "Starting User Data Script"

              # Prevent interactive prompts (like "kernel outdated" or "restart services")
              export DEBIAN_FRONTEND=noninteractive

              # 1. Update system package index
              sudo -E apt-get update -y

              # 2. Install curl and mysql-client
              sudo -E apt-get install -y curl git

              # 3. Use the robust NodeSource setup script (handles keys and sources.list automatically)
              # Using Node.js 20.x LTS
              sudo curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -

              # 4. Install Node.js (this includes npm)
              # The -E flag preserves the environment variables (specifically DEBIAN_FRONTEND)
              sudo -E apt-get install -y nodejs

              # 5. Verify installation
              echo "Node version: $(node -v)"
              echo "NPM version: $(npm -v)"

              # 6. Install Git
              sudo apt-get install -y git

              cd /home/ubuntu
              git clone https://github.com/waonpimol/devops68-word-counter.git
              cd devops68-word-counter

              npm install
             
              # Run the app
              nohup node index.js > app.log 2>&1 &
             
              echo "User Data Script Finished"
              EOF
 
  # Add this to ensure Terraform replaces the instance when user_data changes
  user_data_replace_on_change = true
}