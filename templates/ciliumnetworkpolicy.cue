package templates

import (
    ciliumnetworkpolicyv2 "cilium.io/ciliumnetworkpolicy/v2"
)

#CiliumNetworkPolicy: ciliumnetworkpolicyv2.#CiliumNetworkPolicy & {
    #config: #Config
    metadata: #config.metadata
    spec: {
        endpointSelector: matchLabels: "kro.run/definition": #config.metadata.name
        ingress: [
            {
                fromEndpoints: [{}]
            },
            {
                fromEndpoints: [
                    {
                        matchLabels: {
                            "gateway.envoyproxy.io/owning-gateway-namespace": #config.metadata.namespace
                            "io.kubernetes.pod.namespace": #config.gateway.controllerNamespace
                        }
                    }
                ]
                toPorts: [
                    {
                        ports: [
                            {port: "80"},
                            {port: "8443"},
                        ]
                    }
                ]
            }
        ]
        egress: [
            {
                toEndpoints: [{}]
            },
            {
                toEndpoints: [
                    {
                        matchLabels: {
                            "io.kubernetes.pod.namespace": "kube-system"
                            "k8s-app": "kube-dns"
                        }
                    }
                ]
                toPorts: [
                    {
                        ports: [
                            {
                                port: "53"
                                protocol: "UDP"
                            }
                        ]
                        rules: dns: [
                            {
                                matchPattern: "*"
                            }
                        ]
                    }
                ]
            },
            {
                toEntities: ["world"]
                toPorts: [
                    {
                        ports: [
                            {port: "22"}
                        ]
                    },
                    {
                        ports: [
                            {port: "80"}
                        ]
                    },
                    {
                        ports: [
                            {port: "443"}
                        ]
                    },
                ]
            }
        ]
    }
}
