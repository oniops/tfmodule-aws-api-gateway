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
| [aws_api_gateway_deployment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_deployment) | resource |
| [aws_api_gateway_method_settings.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_settings) | resource |
| [aws_api_gateway_stage.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_stage) | resource |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_wafv2_web_acl_association.waf](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_association) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_access_log_format"></a> [access\_log\_format](#input\_access\_log\_format) | Formatting and values recorded in the logs. see - https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-logging.html | `string` | `"{\"requestId\":\"$context.requestId\", \"extendedRequestId\":\"$context.extendedRequestId\", \"ip\": \"$context.identity.sourceIp\", \"caller\":\"$context.identity.caller\", \"user\":\"$context.identity.user\", \"requestTime\":\"$context.requestTime\", \"httpMethod\":\"$context.httpMethod\", \"resourcePath\":\"$context.resourcePath\", \"status\":\"$context.status\", \"protocol\":\"$context.protocol\", \"responseLength\":\"$context.responseLength\"}"` | no |
| <a name="input_api_name"></a> [api\_name](#input\_api\_name) | The name of the API Gateway, used to build the access-log CloudWatch log group name '/apigateway/{name\_prefix}-{api\_name}-api'. If set to null, var.name is used instead. | `string` | n/a | yes |
| <a name="input_cache_cluster_enabled"></a> [cache\_cluster\_enabled](#input\_cache\_cluster\_enabled) | Whether a cache cluster is enabled for the stage | `bool` | `false` | no |
| <a name="input_cache_cluster_size"></a> [cache\_cluster\_size](#input\_cache\_cluster\_size) | Size of the cache cluster for the stage, if enabled. Allowed values include 0.5, 1.6, 6.1, 13.5, 28.4, 58.2, 118 and 237. | `string` | `null` | no |
| <a name="input_canary_deployment"></a> [canary\_deployment](#input\_canary\_deployment) | Flag to decide whether canary deployment exist. | `bool` | `false` | no |
| <a name="input_canary_traffic_percentage"></a> [canary\_traffic\_percentage](#input\_canary\_traffic\_percentage) | Percent 0.0 - 100.0 of traffic to divert to the canary deployment. | `number` | `10` | no |
| <a name="input_canary_variables"></a> [canary\_variables](#input\_canary\_variables) | (Optional) Map of overridden stage variables (including new variables) for the canary deployment. | `map(string)` | `{}` | no |
| <a name="input_context"></a> [context](#input\_context) | Provides standardized naming policy and attribute information for data source reference to define cloud resources for a Project. | `any` | n/a | yes |
| <a name="input_create"></a> [create](#input\_create) | If true, creates the deployment, stage, method settings, log group, and WAF association. | `bool` | `true` | no |
| <a name="input_deployment_description"></a> [deployment\_description](#input\_deployment\_description) | The description of the deployment (aws\_api\_gateway\_deployment). | `string` | `null` | no |
| <a name="input_deployment_id"></a> [deployment\_id](#input\_deployment\_id) | ID of the deployment that the canary points to. | `string` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | The description of the stage. | `string` | `null` | no |
| <a name="input_documentation_version"></a> [documentation\_version](#input\_documentation\_version) | The version of API Specification. aws\_api\_gateway\_documentation\_version.<resource\_id>.version | `string` | `null` | no |
| <a name="input_enable_access_logs"></a> [enable\_access\_logs](#input\_enable\_access\_logs) | If true, creates a CloudWatch log group and enables access logging on the stage. | `bool` | `false` | no |
| <a name="input_method_settings"></a> [method\_settings](#input\_method\_settings) | List of method settings applied to the stage (aws\_api\_gateway\_method\_settings). Each entry consists of a<br/>'method\_path' (e.g., "*/*" for all methods) and a 'settings' map. Note that logging\_level and metrics require<br/>the account-level CloudWatch role to be configured (see 'create\_api\_account' of the root module).<br/><br/>Ex)<br/>  method\_settings    = [<br/>    {<br/>      method\_path = "*/*"<br/>      settings    = {<br/>        logging\_level                              = "INFO"<br/>        metrics\_enabled                            = true<br/>        data\_trace\_enabled                         = true<br/>        caching\_enabled                            = true<br/>        cache\_data\_encrypted                       = true<br/>        require\_authorization\_for\_cache\_control    = true<br/>        cache\_ttl\_in\_seconds                       = 300<br/>        throttling\_burst\_limit                     = -1<br/>        throttling\_rate\_limit                      = -1<br/>        unauthorized\_cache\_control\_header\_strategy = "SUCCEED\_WITH\_RESPONSE\_HEADER"<br/>      }<br/>    },<br/>  ]<br/><br/>  # logging\_level is one of OFF, ERROR, INFO<br/>  # unauthorized\_cache\_control\_header\_strategy is one of FAIL\_WITH\_403, SUCCEED\_WITH\_RESPONSE\_HEADER, SUCCEED\_WITHOUT\_RESPONSE\_HEADER | <pre>list(object({<br/>    method_path = string<br/>    settings    = map(any)<br/>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the stage (e.g., dev, stg, prod). Used as the stage\_name and the Name tag. | `string` | n/a | yes |
| <a name="input_redeployment"></a> [redeployment](#input\_redeployment) | Arbitrary string used as the redeployment trigger. The API is redeployed whenever the SHA1 hash of this value changes.<br/>Typically pass the jsonencode-d contents of the files that define the API, so that any change to them triggers redeployment.<br/><br/>Ex)<br/>  redeployment = jsonencode([<br/>    file("main.tf"),<br/>    file("apigw\_user.tf"),<br/>    file("apigw\_dept.tf"),<br/>  ]) | `string` | `""` | no |
| <a name="input_rest_api_id"></a> [rest\_api\_id](#input\_rest\_api\_id) | The ID of the REST API to deploy to this stage. | `string` | n/a | yes |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | Retention period (in days) of the access-log CloudWatch log group. | `number` | `90` | no |
| <a name="input_use_stage_cache"></a> [use\_stage\_cache](#input\_use\_stage\_cache) | Whether the canary deployment uses the stage cache. | `bool` | `false` | no |
| <a name="input_web_acl_arn"></a> [web\_acl\_arn](#input\_web\_acl\_arn) | ARN of the WebAcl(WAF-v2) associated with the Stage. | `string` | `null` | no |
| <a name="input_xray_tracing_enabled"></a> [xray\_tracing\_enabled](#input\_xray\_tracing\_enabled) | Whether active tracing with X-ray is enabled. Defaults to false. | `bool` | `false` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | The ARN of the CloudWatch log group for stage access logs. Returns an empty string when enable\_access\_logs is false. |
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name) | The name of the CloudWatch log group for stage access logs. Returns an empty string when enable\_access\_logs is false. |
| <a name="output_name"></a> [name](#output\_name) | The name of the deployed stage. |
<!-- END_TF_DOCS -->