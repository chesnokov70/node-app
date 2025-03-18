
resource "aws_instance" "node_docker" {
  ami                    = data.aws_ami.ubuntu_ami.id # Ubuntu amd64 (x86_64)
  instance_type          = var.instance_type         # Free tier
  security_groups        = [aws_security_group.node_sg.name]
  key_name               = "ssh_instance_key" # Please use your key name
 
  root_block_device {
    volume_size = 30 # Adjust size based on needs, in GB
    volume_type = "gp3"
  }
  tags = {
    Name = "NodeAppServer"
  }
}


