<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.61.0 |

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
| <a name="input_domain"></a> [domain](#input\_domain) | Base public domain name used to look up the ACM certificate and the Route53 hosted zone (e.g., 'mycompany.com'). Defaults to context.domain when not set. | `string` | `null` | no |
| <a name="input_endpoint_type"></a> [endpoint\_type](#input\_endpoint\_type) | Endpoint type of the custom domain name. Valid values: REGIONAL or EDGE. EDGE is served through CloudFront and therefore requires an ACM certificate issued in the us-east-1 region. | `string` | `"REGIONAL"` | no |
| <a name="input_exists_public_hosting_zone"></a> [exists\_public\_hosting\_zone](#input\_exists\_public\_hosting\_zone) | If true, looks up the public Route53 hosted zone of the domain and creates an alias A record pointing to the API Gateway domain name. Set to false when the DNS record is managed outside this module. | `bool` | `true` | no |
| <a name="input_public_domain_prefix"></a> [public\_domain\_prefix](#input\_public\_domain\_prefix) | Host prefix of the custom domain name. The full domain name is built as '{public\_domain\_prefix}.{domain}' (e.g., 'api' becomes api.mycompany.com). | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_domain_name"></a> [domain\_name](#output\_domain\_name) | The custom domain name of the API Gateway, built as '{public\_domain\_prefix}.{domain}'. |
| <a name="output_gateway_domain_name"></a> [gateway\_domain\_name](#output\_gateway\_domain\_name) | The AWS-side target domain name of the API Gateway custom domain, used as the DNS alias target. Returns the regional domain name for REGIONAL and the CloudFront domain name for EDGE. Returns an empty string if the domain is not created. |
<!-- END_TF_DOCS -->