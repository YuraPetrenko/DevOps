resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "MyVPC"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[1]
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id
}

resource "aws_security_group" "my_sg" {
  vpc_id      = aws_vpc.my_vpc.id
  description = "Allow SSH, HTTP, HTTPS"


  ingress {
    description = "SSH"
    from_port   = 22
    protocol    = "TCP"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPS"
    from_port   = 443
    protocol    = "TCP"
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    protocol    = "TCP"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route" "public_rt" {
  route_table_id         = aws_route_table.rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "prt" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_instance" "public_instance" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]

  key_name        = var.key_name
  user_data       = file("init.sh")
  tags = {
    Name = "public_instance"
  }

}

resource "aws_instance" "private_instance" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.private_subnet.id

  vpc_security_group_ids = [aws_security_group.my_sg.id]

  key_name        = var.key_name
  count           = 2

  tags = {
    Name = "private_instance${count.index + 1}"
  }
}

resource "aws_dynamodb_table" "state_lock" {
  name           = "state-lock"         # Назва таблиці
  billing_mode   = "PAY_PER_REQUEST"    # Оплата за запити (Free Tier-friendly)
  hash_key       = "LockID"             # Головний ключ (Partition key)

  attribute {
    name = "LockID"                     # Визначення Partition Key
    type = "S"                          # Тип даних ключа (String)
  }

  tags = {                              # Теги для ідентифікації
    Environment = "Terraform"
    Purpose     = "State Lock"
  }
}

terraform {
  backend "s3" {
    bucket         = "terra-state-bucket-2025"  # Назва створеного S3-бакета
    key            = "terraform.tfstate"       # Шлях до файлу стану в бакеті
    region         = "us-east-1"               # Регіон вашого S3-бакета
    dynamodb_table = "state-lock"              # Назва створеної таблиці DynamoDB
    encrypt        = true                      # Увімкнення шифрування
  }
}
