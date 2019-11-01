module "kms" {
  source = "../../global/kms-key"
}

module "iam" {
  source = "../../global/iam"
  kms-key-arn = module.kms.kms-key-arn
}

resource "aws_lambda_function" "BLESS" {
  filename = "../../../bless/artifact/bless_lambda.zip"
  function_name = "BLESS"
  role = module.iam.bless-lambda-arn-role
  handler = "bless_lambda.lambda_handler"
  source_code_hash = filebase64sha256("../../../bless/artifact/bless_lambda.zip")
  runtime = "python3.7"
  kms_key_arn = module.kms.kms-key-arn
  timeout = 20
}

