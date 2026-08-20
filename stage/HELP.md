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
| [aws_api_gateway_deployment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_deployment) | resource |
| [aws_api_gateway_method_settings.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_settings) | resource |
| [aws_api_gateway_stage.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_stage) | resource |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_wafv2_web_acl_association.waf](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_association) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_access_log_format"></a> [access\_log\_format](#input\_access\_log\_format) | Formatting and values recorded in the logs. see - https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-logging.html | `string` | `"{\"requestId\":\"$context.requestId\", \"extendedRequestId\":\"$context.extendedRequestId\", \"ip\": \"$context.identity.sourceIp\", \"caller\":\"$context.identity.caller\", \"user\":\"$context.identity.user\", \"requestTime\":\"$context.requestTime\", \"httpMethod\":\"$context.httpMethod\", \"resourcePath\":\"$context.resourcePath\", \"status\":\"$context.status\", \"protocol\":\"$context.protocol\", \"responseLength\":\"$context.responseLength\"}"` | no |
| <a name="input_access_log_level"></a> [access\_log\_level](#input\_access\_log\_level) | access logging level. Valid access\_log\_level is one of OFF, INFO or ERROR. | `string` | `"OFF"` | no |
| <a name="input_api_name"></a> [api\_name](#input\_api\_name) | The name of API Gateway | `string` | n/a | yes |
| <a name="input_cache_cluster_enabled"></a> [cache\_cluster\_enabled](#input\_cache\_cluster\_enabled) | Whether a cache cluster is enabled for the stage | `bool` | `false` | no |
| <a name="input_cache_cluster_size"></a> [cache\_cluster\_size](#input\_cache\_cluster\_size) | Size of the cache cluster for the stage, if enabled. Allowed values include 0.5, 1.6, 6.1, 13.5, 28.4, 58.2, 118 and 237. | `string` | `null` | no |
| <a name="input_canary_deployment"></a> [canary\_deployment](#input\_canary\_deployment) | Flag to decide whether canary deployment exist. | `bool` | `false` | no |
| <a name="input_canary_traffic_percentage"></a> [canary\_traffic\_percentage](#input\_canary\_traffic\_percentage) | Percent 0.0 - 100.0 of traffic to divert to the canary deployment. | `number` | `10` | no |
| <a name="input_canary_variables"></a> [canary\_variables](#input\_canary\_variables) | (Optional) Map of overridden stage variables (including new variables) for the canary deployment. | `map(string)` | `{}` | no |
| <a name="input_context"></a> [context](#input\_context) | Provides standardized naming policy and attribute information for data source reference to define cloud resources for a Project. | `any` | n/a | yes |
| <a name="input_create"></a> [create](#input\_create) | n/a | `bool` | `true` | no |
| <a name="input_deployment_description"></a> [deployment\_description](#input\_deployment\_description) | The deployment description of stage | `string` | `null` | no |
| <a name="input_deployment_id"></a> [deployment\_id](#input\_deployment\_id) | ID of the deployment that the canary points to. | `string` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | The description of stage | `string` | `null` | no |
| <a name="input_documentation_version"></a> [documentation\_version](#input\_documentation\_version) | The version of API Specification. aws\_api\_gateway\_documentation\_version.<resource\_id>.version | `string` | `null` | no |
| <a name="input_enable_access_logs"></a> [enable\_access\_logs](#input\_enable\_access\_logs) | Enabled access logs for Stage | `bool` | `false` | no |
| <a name="input_logging_level"></a> [logging\_level](#input\_logging\_level) | Type of authorization used for the method (NONE, CUSTOM, AWS\_IAM, COGNITO\_USER\_POOLS) | `string` | `"OFF"` | no |
| <a name="input_method_settings"></a> [method\_settings](#input\_method\_settings) | Ex)<br/>  method\_settings    = [<br/>    {<br/>      method\_path = "*/*"<br/>      settings    = {<br/>        logging\_level                              = "INFO"<br/>        metrics\_enabled                            = true<br/>        data\_trace\_enabled                         = true<br/>        caching\_enabled                            = true<br/>        cache\_data\_encrypted                       = true<br/>        require\_authorization\_for\_cache\_control    = true<br/>        cache\_ttl\_in\_seconds                       = 300<br/>        throttling\_burst\_limit                     = -1<br/>        throttling\_rate\_limit                      = -1<br/>        unauthorized\_cache\_control\_header\_strategy = "SUCCEED\_WITH\_RESPONSE\_HEADER"<br/>      }<br/>    },<br/>  ]<br/><br/>  # logging\_level is one of OFF, ERROR, INFO<br/>  # unauthorized\_cache\_control\_header\_strategy is one of FAIL\_WITH\_403, SUCCEED\_WITH\_RESPONSE\_HEADER, SUCCEED\_WITHOUT\_RESPONSE\_HEADER | <pre>list(object({<br/>    method_path = string<br/>    settings = map(any)<br/>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of stage | `string` | n/a | yes |
| <a name="input_redeployment"></a> [redeployment](#input\_redeployment) | This will only trigger redeployment if anything changed in listed files."<br/><br/>Ex)<br/>  redeployment = jsonencode([<br/>    file("main.tf"),<br/>    file("apigw\_user.tf"),<br/>    file("apigw\_dept.tf"),<br/>  ]) | `string` | `""` | no |
| <a name="input_rest_api_id"></a> [rest\_api\_id](#input\_rest\_api\_id) | The Resource Instance ID of the REST API | `string` | n/a | yes |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | cloudwatch log group retention\_in\_days | `number` | `90` | no |
| <a name="input_settings"></a> [settings](#input\_settings) | http method settings for api | <pre>set(object(<br/>    {<br/>      cache_data_encrypted                       = bool<br/>      cache_ttl_in_seconds                       = number<br/>      caching_enabled                            = bool<br/>      data_trace_enabled                         = bool<br/>      logging_level                              = string<br/>      metrics_enabled                            = bool<br/>      require_authorization_for_cache_control    = bool<br/>      throttling_burst_limit                     = number<br/>      throttling_rate_limit                      = number<br/>      unauthorized_cache_control_header_strategy = string<br/>    }<br/>  ))</pre> | `[]` | no |
| <a name="input_use_stage_cache"></a> [use\_stage\_cache](#input\_use\_stage\_cache) | Whether the canary deployment uses the stage cache. | `bool` | `false` | no |
| <a name="input_web_acl_arn"></a> [web\_acl\_arn](#input\_web\_acl\_arn) | ARN of the WebAcl(WAF-v2) associated with the Stage. | `string` | `null` | no |
| <a name="input_xray_tracing_enabled"></a> [xray\_tracing\_enabled](#input\_xray\_tracing\_enabled) | Whether active tracing with X-ray is enabled. Defaults to false. | `bool` | `false` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | n/a |
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
<!-- END_TF_DOCS -->