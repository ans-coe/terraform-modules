resource "aws_iam_role" "codedeploy_role" {
  name = "${local.name}-codedeploy-role"
  path = "/"

  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy" "AWSCodeDeployRole" {
  // AWS Managed Policy
  arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

resource "aws_iam_role_policy_attachment" "codebuild-policy-attach" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = data.aws_iam_policy.AWSCodeDeployRole.arn
}

resource "aws_codedeploy_app" "deploy_app" {
  name = "${local.name}-codedeploy-app"
}

resource "aws_codedeploy_deployment_group" "deployment_group" {
  app_name              = aws_codedeploy_app.deploy_app.name
  deployment_group_name = "${local.name}-codedeploy-group"
  service_role_arn      = aws_iam_role.codedeploy_role.arn

  autoscaling_groups = var.asg_list

  auto_rollback_configuration {
    enabled = var.deployment_group.auto_rollback
    events  = ["DEPLOYMENT_FAILURE"]
  }

  deployment_style {
    deployment_option = var.deployment_group.with_traffic_control ? "WITH_TRAFFIC_CONTROL" : "WITHOUT_TRAFFIC_CONTROL"
    deployment_type   = var.deployment_group.blue_green ? "BLUE_GREEN" : "IN_PLACE"
  }

  deployment_config_name = var.deployment_group.deployment_config_name

  dynamic "load_balancer_info" {
    for_each = var.asg_loadbalancer_target_name == null ? [] : [var.asg_loadbalancer_target_name]
    content {
      target_group_info {
        name = var.asg_loadbalancer_target_name
      }
    }
  }
}