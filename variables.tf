variable "github_repo_policies" {
  description = "List of objects defining the GitHub repo and its associated policies. Each object must have a `repo` key. Optionally, specify an inline policy with `policy` (a JSON string) and/or a list of managed policy ARNs with `policy_arns`."
  type = list(object({
    repo        = string
    policy      = optional(string)
    policy_arns = optional(list(string))
  }))
  default = []
}

variable "oidc_provider_arn" {
  description = "Optional ARN for an existing OIDC provider. If provided, the module uses this provider instead of creating one."
  type        = string
  default     = null
}
