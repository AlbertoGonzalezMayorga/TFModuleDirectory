# AWS Elastic Beanstalk Terraform Module

Modulo generico para crear una aplicacion y entorno Elastic Beanstalk. La carpeta conserva el nombre `ebs` por compatibilidad historica, pero el modulo gestiona Elastic Beanstalk, no EBS volumes.

## Que Crea

- `aws_elastic_beanstalk_application`
- `aws_elastic_beanstalk_environment`

## Ejemplo Minimo

```hcl
module "elastic_beanstalk" {
  source = "./modules/AWS/Compute/ebs"

  application_name   = "platform-api"
  environment_name   = "platform-api-dev"
  solution_stack_name = "64bit Amazon Linux 2023 v4.5.0 running Docker"

  settings = [
    {
      namespace = "aws:autoscaling:launchconfiguration"
      name      = "InstanceType"
      value     = "t3.micro"
    },
    {
      namespace = "aws:elasticbeanstalk:environment"
      name      = "EnvironmentType"
      value     = "SingleInstance"
    }
  ]
}
```

## App Version Lifecycle

```hcl
appversion_lifecycle = {
  service_role          = "arn:aws:iam::123456789012:role/elasticbeanstalk-service-role"
  max_count             = 50
  delete_source_from_s3 = true
}
```

## Inputs Principales

- `application_name`, `application_description`.
- `environment_name`.
- `solution_stack_name` o `platform_arn`.
- `tier`: normalmente `WebServer`.
- `settings`: lista flexible de settings de Elastic Beanstalk.
- `appversion_lifecycle`: lifecycle opcional de versiones.
- `tags`.

## Outputs

- `application`: `arn`, `name`.
- `environment`: `arn`, `endpoint`, `id`, `name`.

## Notas

El modulo no crea roles IAM, ALB, subnets ni security groups.
