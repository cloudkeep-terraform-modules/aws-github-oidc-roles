variable "github_repos" {
  description = "Map of GitHub repos to policy JSON strings. Example: { \"org/repo\" = jsonencode({ ... }) }"
  type        = map(string)
}

variable "oidc_provider_arn" {
  description = "Optional ARN for an existing OIDC provider. If provided, the module uses this provider instead of creating one."
  type        = string
  default     = null
}
