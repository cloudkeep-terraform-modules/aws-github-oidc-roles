locals {
  # Use the passed OIDC provider ARN if provided; otherwise, use the one created below.
  oidc_provider_arn = var.oidc_provider_arn != null ? var.oidc_provider_arn : aws_iam_openid_connect_provider.github[0].arn
}

# Conditionally create the OIDC provider only if one is not provided.
resource "aws_iam_openid_connect_provider" "github" {
  count = var.oidc_provider_arn == null ? 1 : 0

  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

resource "aws_iam_role" "github_oidc_roles" {
  for_each = var.github_repos

  name = "github-oidc-role-${replace(each.key, "/", "-")}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = local.oidc_provider_arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${each.key}:*"
          }
        }
      }
    ]
  })

  inline_policy {
    name   = "custom"
    policy = each.value
  }
}
