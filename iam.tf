resource "aws_iam_role" "ecs-autoscaler-role" {
  name = "ecs-autoscaler"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "application-autoscaling.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-autoscaler" {
  role = aws_iam_role.ecs-autoscaler-role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole"
}

resource "aws_iam_role" "iam_for_alleventmonitoring" {

  name = "iam_for_alleventmonitoring"

  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "lambda.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )

  managed_policy_arns   = [aws_iam_policy.AWSLambdaBasicExecutionRole.arn, aws_iam_policy.AWSLambdaSNSPublishPolicyExecutionRole.arn,aws_iam_policy.AWSLambdaSNSTopicDestinationExecutionRole.arn]

  inline_policy {}
}

resource "aws_iam_policy" "AWSLambdaBasicExecutionRole" {
  name = "AWSLambdaBasicExecutionRole-alleventmonitoring_lambda"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
})
}

resource "aws_iam_policy" "AWSLambdaSNSPublishPolicyExecutionRole" {
  name = "AWSLambdaSNSPublishPolicyExecutionRole-alleventmonitoring_lambda"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sns:Publish"
            ],
            "Resource": "arn:aws:sns:*:*:*"
        }
    ]
})
}

resource "aws_iam_policy" "AWSLambdaSNSTopicDestinationExecutionRole" {
  name = "AWSLambdaSNSTopicDestinationExecutionRole-alleventmonitoring_lambda"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "sns:Publish",
            "Resource": aws_sns_topic.alleventsns.arn
        }
    ]
  })
}