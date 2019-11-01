variable "region" {
  description = "Region"
  type = string
  default = "ap-south-1"
}

variable "kms-key-arn" {
  description = "ARN of Bless KMS Key for encryption & Decryption of Passwords"
  type = string
}