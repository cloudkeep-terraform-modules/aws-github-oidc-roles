# aws-github-oidc-roles

A Terraform module to create IAM roles for GitHub Actions using OpenID Connect (OIDC). This module allows you to assign either an inline policy or a set of managed policy ARNs (or both) to a GitHub repository.

## Usage

```hcl
module "github_oidc_roles" {
  source = "github.com/cloudkeep-terraform-modules/aws-github-oidc-roles?ref=v1.0.0"

  github_repo_policies = [
    {
      repo        = "cloudkeep/my-repo"
      policy      = jsonencode({
        Version   = "2012-10-17",
        Statement = [
          {
            Effect   = "Allow",
            Action   = [
              "s3:PutObject",
              "s3:GetObject"
            ],
            Resource = "arn:aws:s3:::my-bucket/*"
          }
        ]
      })
      policy_arns = [
        "arn:aws:iam::123456789012:policy/AdministratorAccess"
      ]
    },
    {
      repo        = "cloudkeep/another-repo"
      policy_arns = [
        "arn:aws:iam::123456789012:policy/ReadOnlyAccess"
      ]
    }
  ]

  # Optionally, pass an existing OIDC provider ARN. If omitted, the module creates one.
  # oidc_provider_arn = "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
}
```

## Inputs

| Name                 | Description                                                                                                                                              | Type                                                                                                             | Required |
|----------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------|----------|
| github_repo_policies | A list of objects defining the GitHub repository and its associated policies. Each object must contain a `repo` (in `org/repo` format), and may include an optional inline `policy` (JSON string) and/or a list of managed `policy_arns`. | `list(object({ repo = string, policy = optional(string), policy_arns = optional(list(string)) }))` | yes      |
| oidc_provider_arn    | Optional ARN of an existing OIDC provider. If not provided, the module creates one using the GitHub Actions OIDC endpoint.                                  | `string`                                                                                                         | no       |

## Outputs

| Name              | Description                              |
|-------------------|------------------------------------------|
| role_arns         | Map of GitHub repos to IAM role ARNs     |
| oidc_provider_arn | The ARN of the OIDC provider used        |

## Notes

- The module creates an IAM role per GitHub repository defined. The role name is derived from the repository name by replacing any forward slashes (`/`) with hyphens (`-`).
- Either an inline policy or managed policy ARNs (or both) can be provided for each repository.
- If an existing OIDC provider ARN is not provided, the module will automatically create one using `https://token.actions.githubusercontent.com` as the provider URL.
