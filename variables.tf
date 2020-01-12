## Variables Section ##

variable "region"  {
    default  = "us-east-1"
}

variable "dnsonoroff" {
    default  = "true"
}

variable "username" {
    default  = "rcbiswal"
}

variable "ec2-key" {
    default = "my-virginia-key"
}

variable "vpcid" {
    default  = "vpc-480c2b32"
}

variable "webaccess-sg" {
    default  = "sg-07cb856e75c667e08"
}

variable "elb-webaccess-port80" {
    default  = "sg-0f3254d76961acc38"
}

variable "zone" {
   default = "rcb.com."
}

variable "alarms_email" {
   default = "rcbiswal@gmail.com"
}
