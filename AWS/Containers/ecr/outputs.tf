output "repositories" {
  description = "Created ECR repositories keyed by repository name."
  value = {
    for name, repository in aws_ecr_repository.this : name => {
      arn            = repository.arn
      id             = repository.id
      name           = repository.name
      registry_id    = repository.registry_id
      repository_url = repository.repository_url
      tags_all       = repository.tags_all
    }
  }
}
