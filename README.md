# tfmodule-aws-api-gateway
AWS API Gateway 리소스를 구성 합니다. 

## Modules

### tfmodule-aws-api-gateway
RESTFul 메서드 및 서비스 통합을 위한 API 리소스를 생성 합니다.

```
```

### domain
API Gateway 애플리케이션의 Endpoint 는 REGIONAL, EDGE, PRIVATE 을 대상으로 구성할 수 있으며, REGIONAL, EDGE 는 public 도메인에 연결 할 수 있습니다.  
- `REGIONAL` 은 Region 내의 Client 를 위한 Endpoint 로 Region ACM 인증서가 필요
- `EDGE` 는 글로벌과 연결되는 Client 를 위한 Endpoint 로 CloudFront 와 연결되므로 반드시 'us-east-1' 리전에 구성된 ACM 인증서가 필요     

```hcl

```

- [api-gateway-api-endpoint-types](https://docs.aws.amazon.com/ko_kr/apigateway/latest/developerguide/api-gateway-api-endpoint-types.html)

<br>

### resource
API 리소스를 구성 합니다. RESTFul 리소스는 Hierarchy 구조를 가지므로, 상위 리소스를 지정하기 위한 `rest_api_id` 및 `resource_id` 속성을 정의 하여야 합니다.

```hcl

```

<br>

### method
API 리소스 주소를 대상으로 HTTP Method 및 Integration (통합) 방식을 정의 합니다. 

통합 대상의 리소스를 지정하기 위한 `rest_api_id` 및 `resource_id` 속성을 정의 하여야 합니다.

```hcl

```

<br>

### stage
API Gateway 리소스를 Stage 런타임 환경으로 배포 합니다. 

```hcl

```

<br>

## Input
|     |     |     |     |     |
|-----|-----|-----|-----|-----|
|     |     |     |     |     |
|     |     |     |     |     |
|     |     |     |     |     |
|     |     |     |     |     |
|     |     |     |     |     |
|     |     |     |     |     |

<br>

## Output
|     |     |     |     |     |
|-----|-----|-----|-----|-----|
|     |     |     |     |     |
|     |     |     |     |     |
|     |     |     |     |     |
|     |     |     |     |     |
|     |     |     |     |     |
|     |     |     |     |     |


<br>



## Example

- [simple](./examples/simple/HELP.md) 예제는 API Gateway 의 요청을 HTTP 프로토콜 통합하여 Target URI 에 통합 합니다. 
- [proxy-vpclink](./examples/proxy-vpclink/HELP.md) 예제는 API Gateway 의 모든 요청을 VPC Link 연결을 통해 Network Load Balancer 으로 통합 합니다. 

<br>


## References

  


