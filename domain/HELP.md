# domain

REST API 를 기본 `*.execute-api.amazonaws.com` 주소 대신 조직의 커스텀 도메인(예: `api.mycompany.com`)으로 노출하는 서브모듈 입니다.

커스텀 도메인은 TLS 인증서를 가진 API Gateway 도메인 이름 리소스와, 그 도메인으로 트래픽을 보내는 DNS 레코드로 구성 됩니다.
이 모듈은 인증서 조회, 도메인 이름 생성, Route53 alias 레코드 연결을 처리 합니다. 어떤 API 의 어떤 스테이지를 이 도메인에 매핑할지는 소비자가 `aws_apigatewayv2_api_mapping` 등으로 별도 정의 합니다.

- 도메인 이름은 `<public_domain_prefix>.<domain>` 으로 조합되며, `domain` 미지정 시 `context.domain` 을 사용 합니다.
- `endpoint_type` 에 따라 `REGIONAL`(리전 내 엔드포인트, 같은 리전의 ACM 인증서) 또는 `EDGE`(CloudFront 경유 글로벌 엔드포인트, `us-east-1` ACM 인증서) 중 하나만 생성 합니다.
- ACM 인증서는 기본 도메인 이름으로 발급 완료 상태의 최신 인증서를 조회하므로, 서브도메인을 포함하는(와일드카드 등) 인증서가 있어야 합니다.
- `exists_public_hosting_zone = true`(기본값) 이면 public Route53 호스팅 존을 조회해 A(alias) 레코드를 생성 합니다. DNS 를 외부에서 관리하면 `false` 로 두고 `gateway_domain_name` 출력을 사용 합니다.

## Resources 역할

| 리소스 | 역할 |
| --- | --- |
| `aws_api_gateway_domain_name` (`regional` / `edge`) | 인증서가 연결된 API Gateway 커스텀 도메인 입니다. `endpoint_type` 에 맞는 하나만 생성 됩니다 |
| `aws_route53_record` (`regional` / `edge`) | 커스텀 도메인을 API Gateway 의 대상 도메인(REGIONAL 도메인 또는 CloudFront 도메인)으로 보내는 A alias 레코드 입니다 |
| `data.aws_acm_certificate` | 기본 도메인 이름으로 발급 완료(ISSUED) 상태의 최신 인증서를 조회 합니다 |
| `data.aws_route53_zone` | alias 레코드를 생성할 public 호스팅 존을 조회 합니다 |

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