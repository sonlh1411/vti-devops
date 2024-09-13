variable "vpc_name" {
  default = "sonlh-tf-vpc"
}

variable "cidrvpc" {
  default = "10.0.0.0/16"
}

variable "tags" {
  default = {
    Name  = "sonlh-tf-vpc"
    Owner = "sonlh"
  }
}

variable "az_count" {
  default = 3
}


