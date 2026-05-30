# Terraform Module Directory

This repository is a curated directory of reusable Terraform modules for cloud infrastructure.

It is intended to be used as a source of standardized, reviewable, and discoverable Terraform building blocks. Modules are grouped by cloud provider and infrastructure domain, and each module is registered in `catalog.json` so it can be consumed, indexed, or presented by external tooling.

This repository is not intended to be a live environment repository. It should not contain environment-specific Terraform stacks, state files, backend configuration, secrets, `.tfvars` files, or deployment-specific plans. Modules should stay generic, reusable, and safe to compose from downstream infrastructure repositories.

## Repository Structure

```text
.
├── AWS/
│   ├── Compute/
│   ├── Containers/
│   ├── Database/
│   ├── Helm/
│   ├── IAM/
│   ├── Networking/
│   ├── Secrets/
│   └── Storage/
├── Azure/
│   ├── Compute/
│   ├── Containers/
│   ├── Database/
│   ├── Helm/
│   ├── IAM/
│   ├── Monitoring/
│   ├── Networking/
│   ├── Secrets/
│   └── Storage/
├── catalog.json
└── .github/workflows/terraform-ci.yml
```

Each module lives in its own directory, for example:

```text
AWS/Storage/s3
Azure/Networking/vnet
```

A module directory should normally contain:

```text
main.tf
variables.tf
outputs.tf
locals.tf              # optional
versions.tf            # AWS modules
requirements.tf        # Azure modules
README.md
```

## Module Catalog

`catalog.json` is the repository index.

Every module that is meant to be consumed must be listed in the catalog with:

- a stable module `id`
- a human-readable `name`
- a clear `description`
- one or more `versions`
- a `sourcePath` pointing to the module directory
- a `terraformVersion` matching the module's Terraform `required_version`
- input and output metadata

Example:

```json
{
  "version": "v1.0.0",
  "sourcePath": "AWS/Storage/s3",
  "terraformVersion": ">= 1.5.0",
  "releaseDate": "2026-05-22"
}
```

The catalog is treated as part of the module contract. When a module is added, moved, renamed, or changes its Terraform compatibility, `catalog.json` must be updated in the same pull request.

## Terraform Version Policy

Every module must declare its supported Terraform CLI version using `required_version`.

Example:

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.44.0"
    }
  }
}
```

If a module uses Terraform language features that require a newer version, the module must declare that newer minimum version.

For example, variable validation blocks that reference variables other than the variable being validated require Terraform `>= 1.9.0`.

The module's `required_version` and the matching `terraformVersion` field in `catalog.json` must stay aligned.

## CI Checks

Pull requests are validated by `.github/workflows/terraform-ci.yml`.

The workflow is change-aware. It uses `git diff` against the pull request target branch and only validates Terraform module directories that were changed by the pull request.

For each changed module, CI checks:

- the module declares `terraform.required_version`
- the module exists in `catalog.json`
- the catalog entry has `terraformVersion`
- the catalog `terraformVersion` matches the module `required_version`
- Terraform formatting passes
- TFLint passes
- `terraform init -backend=false` succeeds
- `terraform validate` succeeds

Terraform is installed per module using the version constraint declared by that module.

This keeps pull request validation fast while still enforcing the repository contract.

## How To Contribute

Contributions should add a new module, improve an existing module, or update catalog metadata for existing modules.

### Adding A New Module

1. Create a module directory under the correct provider and category.

   Example:

   ```text
   AWS/Networking/example_module
   Azure/Storage/example_module
   ```

2. Add the standard Terraform files:

   ```text
   main.tf
   variables.tf
   outputs.tf
   versions.tf or requirements.tf
   README.md
   ```

3. Declare the module's Terraform CLI compatibility with `required_version`.

4. Pin or constrain all required providers in the module's Terraform block.

5. Keep the module reusable.

   Do not include environment-specific values, state configuration, secrets, credentials, local backend settings, or `.tfvars` files.

6. Add the module to `catalog.json`.

   The catalog entry must include the module's `sourcePath` and matching `terraformVersion`.

7. Open a pull request.

   CI will validate only the changed module directories.

### Updating An Existing Module

When changing an existing module:

1. Keep changes scoped to the module being updated.
2. Update the module README if behavior, inputs, outputs, or examples changed.
3. Update `catalog.json` if inputs, outputs, description, source path, release metadata, or Terraform compatibility changed.
4. Bump `terraformVersion` in `catalog.json` if `required_version` changes.
5. Let CI validate the changed module.

### Pull Request Expectations

A pull request should explain:

- what module was added or changed
- why the change is needed
- whether the module interface changed
- whether `catalog.json` was updated
- any compatibility considerations

Before requesting review, make sure the relevant module passes:

```bash
terraform fmt -check -diff <module-directory>
terraform -chdir=<module-directory> init -backend=false
terraform -chdir=<module-directory> validate
```

If TFLint is available locally, also run:

```bash
cd <module-directory>
tflint --init
tflint --minimum-failure-severity=warning
```

## What Should Not Be Committed

Do not commit:

- `.terraform/`
- Terraform state files
- plan files
- `.tfvars` files
- secrets or credentials
- local override files
- environment-specific backend configuration
- generated cache directories

The `.gitignore` file already excludes the most common Terraform local artifacts.

## Compatibility Notes

Some modules require Terraform `>= 1.9.0` because they use cross-variable validation blocks.

Modules with simpler validation rules may use a lower minimum version, such as `>= 1.5.0`.

Always choose the lowest Terraform version that correctly supports the module's language features, and keep that value reflected in both the module and `catalog.json`.
