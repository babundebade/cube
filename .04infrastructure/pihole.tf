resource "kubernetes_namespace" "pihole_namespace" {
  metadata {
    name = "pihole"
  }
}

resource "kubernetes_labels" "label_pihole_namespace" {
  api_version = "v1"
  kind        = "Namespace"
  metadata {
    name = kubernetes_namespace.pihole_namespace.metadata[0].name
  }

  labels = {
    "pod-security.kubernetes.io/enforce" = "privileged"
  }
}

resource "kubernetes_persistent_volume_claim_v1" "pihole_pvc" {
  metadata {
    name      = "pihole-pvc"
    namespace = kubernetes_namespace.pihole_namespace.metadata[0].name
  }
  spec {
    storage_class_name = var.storage_class_name
    access_modes       = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "2Gi"
      }
    }
  }
  lifecycle {
    prevent_destroy = true
  }
}



# locals {
#   settings = {
#     pihole = {
#       "image.tag"                           = "latest"
#       "dnsHostPort.enabled"                 = "false"
#       "serviceDns.mixedService"             = "true"
#       "serviceDns.loadBalancerIP"           = var.dns_IPv4
#       "serviceDns.type"                     = "LoadBalancer"
#       "serviceDhcp.enabled"                 = "false"
#       "persistentVolumeClaim.enabled"       = "true"
#       "persistentVolumeClaim.existingClaim" = kubernetes_persistent_volume_claim_v1.pihole_pvc.metadata[0].name
#       "adminPassword"                       = "admin"
#       "extraEnvVars.TZ"                     = "Europe/Berlin"
#       "DNS1"                                = "84.200.69.80"
#       "DNS2"                                = "89.233.43.71"

#     }
#   }

#   annotations = {
#     "serviceDns.annotations" = {
#       "metallb.universe.tf/address-pool" = "pihole-pool"
#       "metallb.universe.tf/allow-shared-ip" = "pihole-pool"
#     }
#     "dnsmasq.customDnsEntries" = [
#       "address=/${var.tld_domain}/${var.ip_pool_start}",
#       "address=/ha.darioludwig.space/192.168.1.131"
#     ]
#     "adlists" = [
#       "https://raw.githubusercontent.com/PolishFiltersTeam/KADhosts/master/KADhosts.txt",
#       "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Spam/hosts",
#       "https://v.firebog.net/hosts/static/w3kbl.txt",
#       "https://raw.githubusercontent.com/matomo-org/referrer-spam-blacklist/master/spammers.txt",
#       "https://someonewhocares.org/hosts/zero/hosts",
#       "https://raw.githubusercontent.com/VeleSila/yhosts/master/hosts",
#       "https://v.firebog.net/hosts/neohostsbasic.txt",
#       "https://adaway.org/hosts.txt",
#       "https://v.firebog.net/hosts/AdguardDNS.txt",
#       "https://v.firebog.net/hosts/Admiral.txt",
#       "https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt",
#       "https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt",
#       "https://v.firebog.net/hosts/Easylist.txt",
#       "https://raw.githubusercontent.com/bigdargon/hostsVN/master/hosts",
#       "https://v.firebog.net/hosts/Easyprivacy.txt",
#       "https://v.firebog.net/hosts/Prigent-Ads.txt",
#       "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.2o7Net/hosts",
#       "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt",
#       "https://hostfiles.frogeye.fr/firstparty-trackers-hosts.txt",
#       "https://www.github.developerdan.com/hosts/lists/ads-and-tracking-extended.txt",
#       "https://raw.githubusercontent.com/Perflyst/PiHoleBlocklist/master/android-tracking.txt",
#       "https://raw.githubusercontent.com/Perflyst/PiHoleBlocklist/master/SmartTV.txt",
#       "https://raw.githubusercontent.com/Perflyst/PiHoleBlocklist/master/AmazonFireTV.txt",
#       "https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-blocklist.txt",
#       "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareHosts.txt",
#       "https://osint.digitalside.it/Threat-Intel/lists/latestdomains.txt",
#       "https://s3.amazonaws.com/lists.disconnect.me/simple_malvertising.txt",
#       "https://v.firebog.net/hosts/Prigent-Crypto.txt",
#       "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Risk/hosts",
#       "https://bitbucket.org/ethanr/dns-blacklists/raw/8575c9f96e5b4a1308f2f12394abd86d0927a4a0/bad_lists/Mandiant_APT1_Report_Appendix_D.txt",
#       "https://phishing.army/download/phishing_army_blocklist_extended.txt",
#       "https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-malware.txt",
#       "https://v.firebog.net/hosts/RPiList-Malware.txt",
#       "https://v.firebog.net/hosts/RPiList-Phishing.txt",
#       "https://v.firebog.net/hosts/Prigent-Malware.txt",
#       "https://zerodot1.gitlab.io/CoinBlockerLists/hosts_browser"
#       # ... continue adding adlists here if needed ...
#     ]
#     "whitelist" = [
#       "https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/whitelist.txt",
#       "(\\.|^)zeit\\.de$",
#       "(\\.|^)tagesschau\\.de$",
#       "spotify.com"
#       # ... continue adding whitelists here if needed ...
#     ]
#     blacklist = [
#       "cloud.mikrotik.com"
#     ]
#   }
# }


resource "helm_release" "pihole" {
  name       = "pihole"
  namespace  = kubernetes_namespace.pihole_namespace.metadata[0].name
  repository = "https://mojo2600.github.io/pihole-kubernetes/"
  chart      = "pihole" #mojo2600/pihole
  version    = var.version_pihole

  values = [templatefile("${path.module}/services/pihole/values-pihole.yaml", {
    PIHOLE_DNS_IP = var.dns_IPv4
    PIHOLE_WEB_IP = var.ip_pool_start
    PIHOLE_CNAME  = var.tld_domain
  })]

  # dynamic "set" {
  #   for_each = local.settings.pihole
  #   content {
  #     name  = set.key
  #     value = set.value
  #   }
  # }
  # dynamic "set_list" {
  #   for_each = local.annotations
  #   content {
  #     name  = set_list.key
  #     value = set_list.value
  #   }
  # }
  depends_on = [kubernetes_labels.label_pihole_namespace, kubernetes_manifest.l2advertisement_metallb]
}

resource "kubernetes_ingress_v1" "pihole_ingress" {
  metadata {
    name      = "pihole-ingress"
    namespace = kubernetes_namespace.pihole_namespace.metadata[0].name
    annotations = {
      "cert-manager.io/cluster-issuer" = var.cert_issuer_name
      #"nginx.ingress.kubernetes.io/backend-protocol" = "HTTPS"
    }
  }

  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = [var.tld_domain]
      secret_name = var.pihole_secret_name
    }
    rule {
      host = var.tld_domain
      http {
        path {
          path     = "/admin"
          backend {
            service {
              name = "pihole-web"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
    rule {
      host = var.tld_domain
      http {
        path {
          path     = "/admin"
          backend {
            service {
              name = "pihole-web"
              port {
                number = 443
              }
            }
          }
        }
      }
    }
  }
  depends_on = [helm_release.ingress_nginx]
}
