variable "project_name"       { type = string }
variable "environment"        { type = string }
variable "instance_type"      { type = string }
variable "ami_id"             { type = string }
variable "key_pair_name"      { type = string }
variable "subnet_id"          { type = string }
variable "security_group_ids" { type = list(string) }