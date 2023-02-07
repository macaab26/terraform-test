resource "aws_cloudwatch_log_subscription_filter" "logs_lambdafunction_logfilter" {
  name = "logs_lambdafunction_logfilter"
  log_group_name = "/ecs/wordpress"
  filter_pattern = "?Error"
  destination_arn = aws_lambda_function.alleventmonitoring_lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.alleventmonitoring_lambda.function_name
  principal = "logs.us-east-1.amazonaws.com"
}

data "archive_file" "Resource_monitoring_lambdascript" {
  type        = "zip"
  source_file = "lambda_script/lambda_function.py"
  output_path = "lambda_zipped/lambda_function.zip"
}

resource "aws_lambda_function" "alleventmonitoring_lambda" {
  function_name = "alleventmonitoring_lambda"
  handler       = "lambda_function.lambda_handler"
  package_type  = "Zip"
  filename      = data.archive_file.Resource_monitoring_lambdascript.output_path

  role             = aws_iam_role.iam_for_alleventmonitoring.arn
  runtime          = "python3.9"
  source_code_hash = data.archive_file.Resource_monitoring_lambdascript.output_base64sha256

  timeouts {}

  tracing_config {
    mode = "PassThrough"
  }
}

resource "aws_sns_topic" "alleventsns" {
  name = "alleventsns"
}


resource "aws_sns_topic_subscription" "snstoemail_email-target" {
  topic_arn = aws_sns_topic.alleventsns.arn
  protocol  = "email"
  endpoint  = "example@gmail.com" #Configure your email direction
}

resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.alleventsns.arn

  policy = data.aws_iam_policy_document.sns_topic_policy.json
}


data "aws_iam_policy_document" "sns_topic_policy" {
  policy_id = "__default_policy_ID"

  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        <AccountID>, #Configure your account ID
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.alleventsns.arn,
    ]

    sid = "__default_statement_ID"
  }
}