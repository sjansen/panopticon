output "app-fn-name" {
  value = module.app.fn-names["app"]
}

output "app-repo-arn" {
  value = module.bootstrap.repo-arns["app"]
}

output "app-repo-url" {
  value = module.bootstrap.repo-urls["app"]
}

output "docker-registry" {
  value = module.bootstrap.docker-registry
}

output "media-bucket" {
  value = module.app.media-bucket
}

output "ssm-prefix" {
  value = "/${module.bootstrap.ssm-prefix}/"
}
