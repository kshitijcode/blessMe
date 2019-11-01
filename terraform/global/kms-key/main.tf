module "kms_key" {
  source = "git::https://github.com/cloudposse/terraform-aws-kms-key.git?ref=master"
  name = "bless-decrypt-${var.region}"
  description = "KMS key for Bless"
  enable_key_rotation = true
  alias = "alias/bless-decrypt-${var.region}"
}