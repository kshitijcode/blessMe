data "aws_iam_policy_document" "bless-policy-kms-document" {
  statement {
    sid = "AllowKMSDecryption"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey"]
    resources = [
      var.kms-key-arn]
  }
}

data "aws_iam_policy_document" "bless-policy-cloudwatch-document" {
  statement {
    actions = [
      "kms:GenerateRandom",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"]
    resources = [
      "*"]
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = [
      "sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com"]
    }
  }
}
resource "aws_iam_policy" "bless-policy-cloudwatch" {
  name = "bless-cloudwatch-policy"
  description = "CloudWatch Policy for Bless Service"

  policy = data.aws_iam_policy_document.bless-policy-cloudwatch-document.json
}
resource "aws_iam_policy" "bless-policy-kms" {
  name = "bless-cloudwatch-kms"
  description = "KMS Policy for Bless Service"

  policy = data.aws_iam_policy_document.bless-policy-kms-document.json
}


module "role" {
  source = "git@github.com:WynkLimited/platform.git//modules//iam-role"

  role-name = "bless-lambda-${var.region}"
  description = "IAM role with permissions to perform actions on CloudWatch & KMS resources for Bless"
  assume-role-policy = data.aws_iam_policy_document.instance-assume-role-policy.json
  policies = [
    aws_iam_policy.bless-policy-kms.arn,
    aws_iam_policy.bless-policy-cloudwatch.arn
  ]
}
