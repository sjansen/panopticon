# Upgrade Checklist

- `docker-compose.localdev.yml`
  - [`https://hub.docker.com/r/amazon/dynamodb-local`](https://hub.docker.com/r/amazon/dynamodb-local)
- `docker/app/Dockerfile`
  - [`https://hub.docker.com/_/golang`](https://hub.docker.com/_/golang)
- `docker/go/Dockerfile`
  - [`https://hub.docker.com/_/golang`](https://hub.docker.com/_/golang)
  - [`https://github.com/golangci/golangci-lint/releases`](https://github.com/golangci/golangci-lint/releases)
- `templates/base.html`
  - Alpine.js: [`https://cdnjs.com/libraries/alpinejs`](https://cdnjs.com/libraries/alpinejs)
  - Font Awesome [`https://cdnjs.com/libraries/font-awesome`](https://cdnjs.com/libraries/font-awesome)
  - Tailwind CSS [`https://cdnjs.com/libraries/tailwindcss`](https://cdnjs.com/libraries/tailwindcss)
- `terraform/env/terragrunt.hcl`
  - [`https://registry.terraform.io/providers/hashicorp/aws/latest/docs`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
  - [`https://formulae.brew.sh/formula/terragrunt`](https://formulae.brew.sh/formula/terragrunt)
