<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_api_gateway_domain_name.edge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_domain_name) | resource |
| [aws_api_gateway_domain_name.regional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_domain_name) | resource |
| [aws_route53_record.edge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.regional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_acm_certificate.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/acm_certificate) | data source |
| [aws_route53_zone.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_context"></a> [context](#input\_context) | Provides standardized naming policy and attribute information for data source reference to define cloud resources for a Project. | `any` | n/a | yes |
| <a name="input_domain"></a> [domain](#input\_domain) | n/a | `string` | `null` | no |
| <a name="input_endpoint_type"></a> [endpoint\_type](#input\_endpoint\_type) | List of endpoint types. This resource currently only supports managing a single value. Valid values: EDGE or REGIONAL | `string` | `"REGIONAL"` | no |
| <a name="input_exists_public_hosting_zone"></a> [exists\_public\_hosting\_zone](#input\_exists\_public\_hosting\_zone) | n/a | `bool` | `true` | no |
| <a name="input_public_domain_prefix"></a> [public\_domain\_prefix](#input\_public\_domain\_prefix) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_domain_name"></a> [domain\_name](#output\_domain\_name) | n/a |
| <a name="output_gateway_domain_name"></a> [gateway\_domain\_name](#output\_gateway\_domain\_name) | n/a |
<!-- END_TF_DOCS -->