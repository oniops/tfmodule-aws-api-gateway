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
| [aws_api_gateway_resource.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_create"></a> [create](#input\_create) | If true, creates the API Gateway resource. | `bool` | `true` | no |
| <a name="input_parent_ids"></a> [parent\_ids](#input\_parent\_ids) | IDs of the parent - 'rest\_api\_id' of the REST API and 'resource\_id' of the parent resource. Pass the 'ids' output of the root module (for a top-level path) or of an upper resource module to chain the path hierarchy. | <pre>object({<br/>    resource_id = string<br/>    rest_api_id = string<br/>  })</pre> | n/a | yes |
| <a name="input_path_part"></a> [path\_part](#input\_path\_part) | Last path segment of this API resource (e.g., 'v1', 'users'). Use greedy path syntax like '{proxy+}' to define a proxy resource. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_ids"></a> [ids](#output\_ids) | Object containing rest\_api\_id and this resource's resource\_id. Pass this as 'parent\_ids' to child resource modules or method modules to chain the API hierarchy. |
| <a name="output_path"></a> [path](#output\_path) | The complete path of this API resource including all parent paths (e.g., '/v1/users'). Returns an empty string if the resource is not created. |
| <a name="output_path_part"></a> [path\_part](#output\_path\_part) | The last path segment of this API resource. Returns an empty string if the resource is not created. |
| <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id) | The ID of the created API resource. Returns an empty string if the resource is not created. |
| <a name="output_rest_api_id"></a> [rest\_api\_id](#output\_rest\_api\_id) | The ID of the REST API this resource belongs to. Returns an empty string if the resource is not created. |
<!-- END_TF_DOCS -->