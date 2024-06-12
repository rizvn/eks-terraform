variable "ingress-name" {
  description = "ingress name"
  type = string
}

variable "internal" {
  type = bool
  default = true
}

variable "target-node-labels" {
  type = string
  default = "role=ingress-only"
  description = "target node labels e.g. role=ingress-only"
}

variable "ingress-node-role" {
  type = string
  default = "ingress-only"
  description = "target node labels e.g. role=ingress-only"
}


variable "tolerations" {
    description = "Tolerations for the ingress controller"
    type = list(object({
        key      = string
        operator = string
        value    = string
        effect   = string
    }))
    default = [
      {
        key      = "role"
        operator = "Equal"
        value    = "ingress-only"
        effect   = "NoSchedule"
      },
      {
        key      = "role"
        operator = "Equal"
        value    = "ingress-only"
        effect   = "NoExecute"
      }
    ]
}


variable "nodeSelector" {
    description = "Node selector for the ingress controller, match nodes with the specified label"
    type = map(string)
    default = {
        "role" = "ingress-only"
    }
}