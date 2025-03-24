output "role_arns" {
  description = "Map of GitHub repos to IAM role ARNs"
  value = {
    for repo, role in aws_iam_role.github_oidc_roles :
    repo => role.arn
  }
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC provider used by the roles"
  value       = local.oidc_provider_arn
}
