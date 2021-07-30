resource "volterra_origin_pool" "bu12app" {
  name                   = "bu12app"
  namespace              = var.namespace
  endpoint_selection     = "DISTRIBUTED"
  loadbalancer_algorithm = "LB_OVERRIDE"
  port                   = 80
  no_tls                 = true

  origin_servers {
    private_ip {
      ip = module.webserver["bu12"].privateIp
      site_locator {
        site {
          tenant    = var.volterraTenant
          namespace = "system"
          name      = volterra_azure_vnet_site.bu12.name
        }
      }
      inside_network = true
    }

    labels = {
      "bu" = "bu12"
    }
  }
}

resource "volterra_http_loadbalancer" "bu12app" {
  name                            = "bu12app"
  namespace                       = var.namespace
  no_challenge                    = true
  domains                         = ["bu12app.shared.acme.com"]
  random                          = true
  disable_rate_limit              = true
  service_policies_from_namespace = true
  disable_waf                     = true

  advertise_custom {
    advertise_where {
      port = 80
      site {
        network = "SITE_NETWORK_INSIDE"
        site {
          tenant    = var.volterraTenant
          namespace = "system"
          name      = volterra_azure_vnet_site.bu11.name
        }
      }
    }
    advertise_where {
      port = 80
      site {
        network = "SITE_NETWORK_INSIDE"
        site {
          tenant    = var.volterraTenant
          namespace = "system"
          name      = volterra_azure_vnet_site.bu12.name
        }
      }
    }
    advertise_where {
      port = 80
      site {
        network = "SITE_NETWORK_INSIDE"
        site {
          tenant    = var.volterraTenant
          namespace = "system"
          name      = volterra_azure_vnet_site.bu13.name
        }
      }
    }
  }

  default_route_pools {
    pool {
      name = volterra_origin_pool.bu12app.name
    }
  }

  http {
    dns_volterra_managed = false
  }
}
