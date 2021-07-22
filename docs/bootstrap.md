# Bootstrapping

1. `pushd terraform/env/staging`
1. Create `terraform.tfvars`
1. `terragrunt init -upgrade`
1. `terragrunt apply -target=module.bootstrap`
1. `popd`
1. Note `ssm-prefix` value.
1. My Security Credentials > CloudFront key pairs > Create New Key Pair
1. Systems Mananager > Parameter Store > fill in values under `ssm-prefix`.
  - `CLOUDFRONT_KEY_ID`
  - `CLOUDFRONT_PRIVATE_KEY`
1. Create X.509 certificate and private key
1. Systems Mananager > Parameter Store > fill in values under `ssm-prefix`.
  - `SAML_CERTIFICATE`
  - `SAML_PRIVATE_KEY`
1. Add SP to IdP
  - e.g. docs/okta.md
1. Systems Mananager > Parameter Store > fill in values under `ssm-prefix`.
  - `SAML_METADATA_URL`
1. `make login`
1. `scripts/staging-docker-push`
1. `pushd terraform/env/staging`
1. `terragrunt apply`
1. `popd`
