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
| [aws_api_gateway_resource.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_create"></a> [create](#input\_create) | for aws\_api\_gateway\_method | `bool` | `true` | no |
| <a name="input_parent_ids"></a> [parent\_ids](#input\_parent\_ids) | The Resource ID and API Instance ID of the REST API | <pre>object({<br/>    resource_id = string<br/>    rest_api_id = string<br/>  })</pre> | n/a | yes |
| <a name="input_path_part"></a> [path\_part](#input\_path\_part) | Last path segment of this API resource. (v1, users). Define proxy path like `{proxy+}` | `string` | n/a | yes |
| <a name="input_resource_id"></a> [resource\_id](#input\_resource\_id) | The Resource ID of the REST API | `string` | `null` | no |
| <a name="input_rest_api_id"></a> [rest\_api\_id](#input\_rest\_api\_id) | The Resource Instance ID of the REST API | `string` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_ids"></a> [ids](#output\_ids) | n/a |
| <a name="output_path"></a> [path](#output\_path) | n/a |
| <a name="output_path_part"></a> [path\_part](#output\_path\_part) | n/a |
| <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id) | n/a |
| <a name="output_rest_api_id"></a> [rest\_api\_id](#output\_rest\_api\_id) | n/a |
<!-- END_TF_DOCS -->