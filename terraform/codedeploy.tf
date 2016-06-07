resource "aws_codedeploy_app" "ghost" {
  name = "ghost"
}

resource "aws_iam_role_policy" "ghost_deploy_policy" {
  name = "ghost_deploy_policy"
  role = "${aws_iam_role.ghost_deploy_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:Describe*",
                "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
                "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
                "autoscaling:Describe*",
                "autoscaling:EnterStandby",
                "autoscaling:ExitStandby",
                "autoscaling:UpdateAutoScalingGroup",
                "autoscaling:CompleteLifecycleAction",
                "autoscaling:DeleteLifecycleHook",
                "autoscaling:PutLifecycleHook",
                "autoscaling:RecordLifecycleActionHeartbeat",
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceStatus",
                "tag:GetTags",
                "tag:GetResources",
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role" "ghost_deploy_role" {
  name = "ghost_deploy_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "codedeploy.amazonaws.com",
          "ec2.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_codedeploy_deployment_group" "ghost_deploy_group" {
  app_name              = "${aws_codedeploy_app.ghost.name}"
  deployment_group_name = "ghost_deploy_group"
  service_role_arn      = "${aws_iam_role.ghost_deploy_role.arn}"
  deployment_config_name = "CodeDeployDefault.OneAtATime"
  autoscaling_groups = ["${aws_autoscaling_group.ghost_asg.id}"]

}
