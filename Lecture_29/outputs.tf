output "instance_cpu_core_count" {
  value = aws_instance.public_instance.cpu_core_count
}

output "public_instance_ip" {
  value = aws_instance.public_instance.public_ip
}
output "public_instance_state" {
  value = aws_instance.public_instance.instance_state
}

output "private_instance_0_ip" {
  value = aws_instance.private_instance[0].private_ip
}
output "private_instance_0_state" {
  value = aws_instance.private_instance[0].instance_state
}

output "private_instance_1_ip" {
  value = aws_instance.private_instance[1].private_ip
}
output "private_instance_1_state" {
  value = aws_instance.private_instance[1].instance_state
}
