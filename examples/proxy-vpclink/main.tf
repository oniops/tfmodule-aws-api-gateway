data "aws_api_gateway_vpc_link" "this" {
  name = "sea-as1p-openapi"
}

locals {
  context_info = {
    project     = "otcmp"
    region      = "ap-southeast-1"
    environment = "Development"
    department  = "OpsNow"
    owner       = "seonbo.shim@bespinglobal.com"
    customer    = "OPSNOW-CMP"
    domain      = "opsnow.asia"
    pri_domain  = "backend.opsnow.com"
  }
}

module "ctx" {
  source  = "../context/"
  context = local.context_info
}


locals {
  api_name         = "banana"
  stage_name       = "dev"
  nlb_endpoint_uri = "http://sea-as1p-openapi-nlb-09b425d015fe958e.elb.ap-southeast-1.amazonaws.com:9010"
}

# ROOT
module "api" {
  source   = "../../"
  context  = module.ctx.context
  api_name = local.api_name
}

# /api-v2
module "api_v2" {
  source     = "../../resource/"
  parent_ids = module.api.ids
  path_part  = "api-v2"
}

# /api-v2/{proxy+}
module "api_v2_proxy" {
  source     = "../../resource/"
  parent_ids = module.api_v2.ids
  path_part  = "{proxy+}"
}

module "api_v2_proxy_any" {
  source             = "../../method/"
  parent_ids         = module.api_v2_proxy.ids
  type               = "HTTP_PROXY"
  http_method        = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = data.aws_api_gateway_vpc_link.this.id
  uri                = format("%s/error", local.nlb_endpoint_uri)
  request_parameters = {
    "method.request.path.proxy" = true
  }
  request_parameters_integration = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}


# /docs
module "docs" {
  source     = "../../resource/"
  parent_ids = module.api.ids
  path_part  = "docs"
}

# /docs/{proxy+}
module "docs_proxy" {
  source     = "../../resource/"
  parent_ids = module.docs.ids
  path_part  = "{proxy+}"
}

module "docs_proxy_any" {
  source             = "../../method/"
  parent_ids         = module.docs_proxy.ids
  http_method        = "ANY"
  type               = "HTTP_PROXY"
  connection_type    = "VPC_LINK"
  connection_id      = data.aws_api_gateway_vpc_link.this.id
  uri                = format("%s/error", local.nlb_endpoint_uri)
  request_parameters = {
    "method.request.path.proxy" = true
  }
  request_parameters_integration = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

# deploy to stage
module "deploy_stage" {
  source      = "../../stage/"
  context     = module.ctx.context
  name        = local.stage_name
  api_name    = local.api_name
  description = format("%s proxy application", module.ctx.project)
  rest_api_id = module.api.rest_api_id

  enable_access_logs = true
  method_settings    = [
    {
      method_path = "*/*"
      settings    = {
        logging_level   = "ERROR"
        metrics_enabled = true
      }
    },
    {
      method_path = "route/api-v2/{proxy+}/POST"
      settings    = {
        logging_level   = "INFO"
        metrics_enabled = true
      }
    },
  ]

  depends_on = [module.api]
}
