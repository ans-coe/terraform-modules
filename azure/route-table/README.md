# Terraform (Module) - Azure - Route Table

#### Table of Contents

- [Terraform (Module) - Azure - NAME](#terraform-module---azure---name)
      - [Table of Contents](#table-of-contents)
  - [Usage](#usage)
  - [Requirements](#requirements)
  - [Inputs](#inputs)
  - [Outputs](#outputs)
  - [Resources](#resources)
  - [Modules](#modules)

## Usage

This module creates a route table, routes and associates any subnet ids provided.

There is the option to create a "default route" which routes all IPs (0.0.0.0/32)to a specified default_route_ip.  If no IP is specified, no route is created.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |

## Inputs

No inputs.

## Outputs

No outputs.

## Resources

No resources.

## Modules

No modules.
<!-- END_TF_DOCS -->
_______________
| Classified  |
| :---------: |
|   PUBLIC    |