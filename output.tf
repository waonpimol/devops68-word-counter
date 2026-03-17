output "app_public_url" {
  value = "http://${aws_instance.nodejs_server.public_ip}:3008"
  description = "Copy URL นี้ไปเปิดใน Browser"
}