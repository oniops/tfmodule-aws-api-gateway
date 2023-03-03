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
  api_name = "apple"
}

module "ctx" {
  source  = "../context/"
  context = local.context_info
}

# ROOT
module "api" {
  source   = "../../"
  context  = module.ctx.context
  api_name = local.api_name
}

# /users
module "users" {
  source     = "../../resource/"
  parent_ids = module.api.ids
  path_part  = "users"
}

# /users_OPTIONS
module "users_options" {
  source      = "../../method/"
  parent_ids  = module.users.ids
  http_method = "OPTIONS"
  type        = "MOCK"
}

# /users_GET_with_querystring
module "users_get" {
  source             = "../../method/"
  parent_ids         = module.users.ids
  http_method        = "GET"
  type               = "HTTP"
  connection_type    = "INTERNET"
  uri                = "http://api.something.private:8080/users"
  request_parameters = {
    "method.request.querystring.name"  = false
    "method.request.querystring.email" = false
  }
  request_parameters_integration = {
    "integration.request.header.Content-Type" = "'application/json'"
    "integration.request.querystring.name"    = "method.request.querystring.name"
    "integration.request.querystring.email"   = "method.request.querystring.email"
  }
}

# /users_POST
module "users_post" {
  source          = "../../method/"
  parent_ids      = module.users.ids
  http_method     = "POST"
  type            = "HTTP"
  connection_type = "INTERNET"
  uri             = "http://api.something.private:8080/users"
}

# /users/{id}
module "users_id" {
  source     = "../../resource/"
  parent_ids = module.users.ids
  path_part  = "{id}"
}

# /users/{id} GET
module "users_id_get" {
  source             = "../../method/"
  parent_ids         = module.users_id.ids
  http_method        = "GET"
  type               = "HTTP"
  connection_type    = "INTERNET"
  uri                = "http://api.something.private:8080/users/{id}"
  request_parameters = {
    "method.request.path.id" = true
  }
  request_parameters_integration = {
    "integration.request.header.Content-Type" = "'application/json'"
    "integration.request.path.id"             = "method.request.path.id"
  }
}

# /users/{id} PUT
module "users_id_put" {
  source             = "../../method/"
  parent_ids         = module.users_id.ids
  http_method        = "PUT"
  type               = "HTTP"
  connection_type    = "INTERNET"
  uri                = "http://api.something.private:8080/users/{id}"
  request_parameters = {
    "method.request.path.id" = true
  }
  request_parameters_integration = {
    "integration.request.header.Content-Type" = "'application/json'"
    "integration.request.path.id"             = "method.request.path.id"
  }
}

# /users/{id} DELETE
module "users_id_del" {
  source             = "../../method/"
  parent_ids         = module.users_id.ids
  http_method        = "DELETE"
  type               = "HTTP"
  connection_type    = "INTERNET"
  uri                = "http://api.something.private:8080/users/{id}"
  request_parameters = {
    "method.request.path.id" = true
  }
  request_parameters_integration = {
    "integration.request.header.Content-Type" = "'application/json'"
    "integration.request.path.id"             = "method.request.path.id"
  }
}

# deploy to stage
module "deploy_stage" {
  source             = "../../stage/"
  name               = "v1"
  context            = module.ctx.context
  rest_api_id        = module.api.rest_api_id
  api_name           = local.api_name
  description        = "user application"
  enable_access_logs = true
  method_settings    = [
    {
      method_path = "users/POST"
      settings    = {
        logging_level   = "INFO"
        metrics_enabled = true
      }
    },
    {
      method_path = "users/{id}/GET"
      settings    = {
        logging_level   = "ERROR"
        metrics_enabled = true
      }
    },
    {
      method_path = "users/{id}/PUT"
      settings    = {
        logging_level   = "INFO"
        metrics_enabled = true
      }
    },
    {
      method_path = "users/{id}/DELETE"
      settings    = {
        logging_level   = "INFO"
        metrics_enabled = true
      }
    },
    {
      method_path = "*/*"
      settings    = {
        logging_level   = "OFF"
        metrics_enabled = true
      }
    },
  ]
  depends_on = [module.api]
}

