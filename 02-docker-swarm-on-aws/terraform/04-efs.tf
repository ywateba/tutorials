resource "aws_efs_file_system" "efs" {
  creation_token = "my-efs"
  // ...existing code...
}

resource "aws_efs_mount_target" "efs_mount" {
  count          = var.number_of_azs 
  file_system_id = aws_efs_file_system.efs.id
  subnet_id      = element(concat(aws_subnet.private[*].id), count.index)
  security_groups = [aws_security_group.efs.id]
  // ...existing code...
}


