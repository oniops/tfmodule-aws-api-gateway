# resource

REST API 의 URL 경로(리소스) 한 단계를 생성하는 서브모듈 입니다.

API Gateway REST API 는 `/v1/users/{id}` 처럼 경로를 트리 구조로 관리하며, 각 세그먼트가 하나의 리소스(`aws_api_gateway_resource`) 입니다.
이 모듈은 상위 리소스 아래에 `path_part` 세그먼트 하나를 추가하고, 그 아래에 자식 경로나 메서드를 붙일 수 있도록 `ids` 를 출력 합니다.

- 상위는 `parent_ids` 로 지정 합니다. 최상위 경로는 루트 모듈의 `ids`(루트 `/` 리소스), 그 아래 경로는 상위 `resource` 모듈의 `ids` 를 전달 합니다.
- 경로 변수는 `{id}`, 하위 경로 전체를 받는 greedy 경로는 `{proxy+}` 형식으로 정의 합니다.

## Resources 역할

| 리소스 | 역할 |
| --- | --- |
| `aws_api_gateway_resource` | REST API 경로 트리에 세그먼트 하나를 추가 합니다. 메서드는 이 리소스에 연결 됩니다 |

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