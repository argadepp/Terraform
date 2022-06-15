provider "aws" {
  region = "ap-south-1"
  access_key = "AccessKey"
  secret_key = "SecreateKey"
}

/////   EC2 Instance Creation 

# resource "aws_instance" "terraform_test" {
#   ami = "ami-047192301059260b6"
#   instance_type = "t2.micro"
#   security_groups = [ "all-open" ]
#   //user_data = "sudo apt update && sudo apt install nginx -y && sudo systemctl enable nginx"
#   key_name = "terraformkey"
#   tags = {
#     "Name" = "Web Server"
#   }
# }

//// S3 Bucket Creation 

# resource "aws_s3_bucket" "mys3bucket" {
#   bucket = "pratikargade-teraform-test-bucket-01"
# }

# output "s3bucket" {
#   value = aws_s3_bucket.mys3bucket 
# }



################ Create Elastic IP and Ec2 Instance and Associate EIP to EC2 ######################

# resource "aws_eip" "myeip" {
#   vpc = true
# }

# resource "aws_instance" "myinstance" {
#     ami = "ami-047192301059260b6"
#     instance_type = "t2.micro"
#     security_groups = [ "all-open" ]
#    //user_data = "sudo apt update && sudo apt install nginx -y && sudo systemctl enable nginx"
#     key_name = "terraformkey"
  
# }

# resource "aws_eip_association" "eipassociation" {
#   instance_id = aws_instance.myinstance.id
#   allocation_id = aws_eip.myeip.id
# }


####################### End #########################################################################


resource "aws_vpc" "myvpc2" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" = "CustomVpc"
  }
}

resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.myvpc2.id
    map_public_ip_on_launch = true
    cidr_block = "10.0.0.0/24"
    tags = {
      "Name" = "Public_SubNet"
    }
  
}

resource "aws_internet_gateway" "myig_for_public_subnet" {
  vpc_id = aws_vpc.myvpc2.id
  tags = {
    "Name" = "mycustumig"
  }
}

resource "aws_route_table" "public_route" {
      vpc_id = aws_vpc.myvpc2.id
    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myig_for_public_subnet.id
  }

  tags = {
Name ="Public Route Table"

  }
}

resource "aws_route_table_association" "publicrt_association" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route.id
  //gateway_id = aws_internet_gateway.myig_for_public_subnet.id
  
  

}

resource "aws_security_group" "all_open" {
    name        = "all-open"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.myvpc2.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [ "0.0.0.0/0"]
    
  }
  
   
    tags = {
      Name = "all-open-sg"
      
    }
  
}

resource "aws_instance" "test_instance_myvpc2" {
      ami = "ami-047192301059260b6"
      instance_type = "t2.micro"
      //security_groups = [ "all-open" ]
      key_name = "terraformkey"
      subnet_id = aws_subnet.public_subnet.id
      tags = {
        "Name" = "my-terraform-instance-1"
      }
      security_groups = [ aws_security_group.all_open.id ]
}

