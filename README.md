# aws-github-oidc-roles

A Terraform module to create IAM roles for GitHub Actions using OpenID Connect (OIDC). This allows GitHub workflows to assume AWS roles securely.

## Usage

~~~hcl
module "github_oidc_roles" {
  source = "github.com/cloudkeep-terraform-modules/aws-github-oidc-roles"

  github_repos = {
    "cloudkeep/my-repo" = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Action = [
            "s3:PutObject",
            "s3:GetObject"
          ],
          Resource = "arn:aws:s3:::my-bucket/*"
        }
      ]
    })
  }

  # Optionally, pass an existing OIDC provider ARN. If omitted, the module creates one.
  # oidc_provider_arn = "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
}
~~~

## Inputs

| Name              | Description                                                                       | Type         | Required |
|-------------------|-----------------------------------------------------------------------------------|--------------|----------|
| github_repos      | Map of GitHub repos (`org/repo`) to IAM policy JSON strings.                      | `map(string)`| yes      |
| oidc_provider_arn | Optional ARN of an existing OIDC provider. If not provided, a new one is created.   | `string`     | no       |

## Outputs

| Name              | Description                             |
|-------------------|-----------------------------------------|
| role_arns         | Map of repo names to IAM role ARNs      |
| oidc_provider_arn | The ARN of the OIDC provider used       |

## Notes

- If you do not provide an OIDC provider ARN, this module creates one using the URL `https://token.actions.githubusercontent.com`.
- Be cautious if you already have an OIDC provider in your account, as creating a duplicate may not be desired.
