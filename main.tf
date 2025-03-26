locals {
  # Use the passed OIDC provider ARN if provided; otherwise, use the one created below.
  oidc_provider_arn = var.oidc_provider_arn != null ? var.oidc_provider_arn : aws_iam_openid_connect_provider.github[0].arn

  # Convert list to map keyed by repo for easier lookup.
  repos = { for entry in var.github_repo_policies : entry.repo => entry }
}

# Conditionally create the OIDC provider only if one is not provided.
resource "aws_iam_openid_connect_provider" "github" {
  count = var.oidc_provider_arn == null ? 1 : 0

  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

resource "aws_iam_role" "github_oidc_roles" {
  for_each = local.repos

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
}

# Attach inline policy if defined.
resource "aws_iam_role_policy" "github_inline_policy" {
  for_each = { for repo, entry in local.repos : repo => entry if lookup(entry, "policy", null) != null }

  name   = "${replace(each.key, "/", "-")}-github-oidc-inline-policy"
  role   = aws_iam_role.github_oidc_roles[each.key].name
  policy = each.value.policy
}

# Attach managed policies if defined.
resource "aws_iam_role_policy_attachment" "github_managed_policy" {
  for_each = {
    for item in flatten([
      for entry in var.github_repo_policies : [
        for policy in lookup(entry, "policy_arns", []) : {
          repo       = entry.repo,
          policy_arn = policy
        }
      ]
    ]) : "${item.repo}-${replace(item.policy_arn, "/", "-")}" => item
  }

  role       = aws_iam_role.github_oidc_roles[each.value.repo].name
  policy_arn = each.value.policy_arn
}
