### Podinfo Helm release
resource "helm_release" "ingress-nginx" {
  name             = var.ingress-name
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.10.1"
  namespace        = var.ingress-name
  create_namespace = "true"
  values = [
     yamlencode(
       {
         controller = {
           ingressClassResource = {
             name            = var.ingress-name
             controllerValue = "k8s.io/${var.ingress-name}"
           }
           ingressClass = var.ingress-name
           autoscaling = {
             enabled                           = true
             targetCPUUtilizationPercentage    = 80
             targetMemoryUtilizationPercentage = 80
             minReplicas                       = 3
           }
           allowSnippetAnnotations = true
           config = {
             "proxy-body-size" = "10000m"
             "ssl-redirect"    = "false"
             "use-forwarded-headers" = "true"
             "compute-full-forwarded-for" = "true"
           }

           service = {
             enableHttp = false
             enableHttps = true
             externalTrafficPolicy = "Local"

             annotations = merge(
               {
                 "service.beta.kubernetes.io/aws-load-balancer-type"                              = "nlb"
                 "service.beta.kubernetes.io/aws-load-balancer-healthcheck-protocol"              = "tcp"
               },
               var.internal ?
               {
                 "service.beta.kubernetes.io/aws-load-balancer-scheme"   = "internal"
                 "service.beta.kubernetes.io/aws-load-balancer-internal" = "true"
               }:
               {
                 "service.beta.kubernetes.io/aws-load-balancer-scheme"   = "internet-facing"
                 "service.beta.kubernetes.io/aws-load-balancer-internal" = "false"
               },
               length(var.target-node-labels) > 0 ?
               {
                 "service.beta.kubernetes.io/aws-load-balancer-target-node-labels" = var.target-node-labels
               }:
               {}
             )
           }
           nodeSelector = var.nodeSelector
           tolerations = var.tolerations
           admissionWebhooks = {
             enabled = true
             patch = {
               tolerations = var.tolerations
             }
           }
         }
       }
    )
  ]
}
