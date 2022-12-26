data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${var.product_domain}-*",
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${var.product_domain}-*:*",
    ]
  }
  
  statement {
    effect = "Allow"
    
    actions = [
      "ssm:GetParameters",
    ]
    
    resources = [
      coalesce(var.postgres_password_ssm_pattern,
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/tvlk-secret/codebuild/${var.product_domain}/*")
    ]
  }
  
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    resources = [
      "arn:aws:iam::015110552125:role/BeiartfWriter_${var.product_domain}",
    ]
  }
  
  statement {
    effect = "Allow"
    
    actions = [
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcs",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:CreateNetworkInterface",
    ]
    
    resources = [
      "*",
    ]
  }
  
  statement {
    effect = "Allow"
    
    actions = [
      "ec2:CreateNetworkInterfacePermission",
    ]
    
    resources = [
      "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:network-interface/*",
    ]
    
    condition {
      test     = "StringEquals"
      variable = "ec2:AuthorizedService"
      values   = [ "codebuild.amazonaws.com" ]
    }
  }
}

data "aws_iam_policy_document" "allow_cmk" {
  statement {
    effect = "Allow"
    
    actions = [
      "kms:Decrypt"
    ]
    
    resources = "${var.key_arns}"
  }
}
