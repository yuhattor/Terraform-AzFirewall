variable "scriptping" {
  type =  string
}

variable "frontdoorname" {
  type =  string
}

variable "scriptiis" {
  type =  string
}

variable "vmsize" {
  type =  string
}

variable "adminname" {
  type = string
  default = "rfonseca"
}

variable "adminpwd" {
  type = string
  default = "P@ssword123456"
}

variable "location" {
    type = string
}

variable "prefix" {
    type = string
}

variable "rgname" {
    type = string
}

variable "client_secret" {
    type = string
}

variable "client_id" {
    type = string
}

variable "subscription_id" {
    type = string
}

variable "tenant_id" {
    type = string
}
