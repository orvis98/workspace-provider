package templates

import (
    resourcegraphdefintionv1 "kro.run/resourcegraphdefinition/v1alpha1"
)

#ResourceGraphDefinition: {
    #config: #Config
    apiVersion: resourcegraphdefintionv1.#ResourceGraphDefinition.apiVersion
    kind: resourcegraphdefintionv1.#ResourceGraphDefinition.kind
    metadata: #config.metadata
    spec: {
        schema: {
            apiVersion: #config.resource.version
            kind: #config.resource.kind
            spec: {
                image: "string | default=\"lscr.io/linuxserver/code-server:latest\""
                allowedUsers: "[]string"
            }
            status: {
                conditions: "${deployment.status.conditions}"
                availableReplicas: "${deployment.status.availableReplicas}"
                parents: "${httpRoute.status.parents}"
            }
        }
        resources: [
            {
                id: "deployment"
                template: {
                    apiVersion: "apps/v1"
                    kind: "Deployment"
                    metadata: {
                        name: "${schema.metadata.name}"
                        namespace: "${schema.metadata.namespace}"
                    }
                    spec: {
                        replicas: 1
                        selector: matchLabels: {
                            "kro.run/definition": #config.metadata.name
                            "kcp.io/name": "${schema.metadata.name}"
                        }
                        template: {
                            metadata: labels: selector.matchLabels
                            spec: containers: [
                                {
                                    name: "workspace"
                                    image: "${schema.spec.image}"
                                    ports: [
                                        {
                                            containerPort: 8443
                                            protocol: "TCP"
                                        }
                                    ]
                                    env: [
                                        {
                                            name: "PUID"
                                            value: "1000"
                                        },
                                        {
                                            name: "PGID"
                                            value: "1000"
                                        },
                                        {
                                            name: "TZ"
                                            value: "Etc/UTC"
                                        }
                                    ]
                                }
                            ]
                        }
                    }
                }
            },
            {
                id: "service"
                template: {
                    apiVersion: "v1"
                    kind: "Service"
                    metadata: {
                        name: "${deployment.metadata.name}"
                        namespace: "${deployment.metadata.namespace}"
                    }
                    spec: {
                        selector: "${deployment.spec.selector.matchLabels}"
                        ports: [
                            {
                                name: "http"
                                protocol: "TCP"
                                port: 80
                                targetPort: 8443
                            }
                        ]
                    }
                }
            },
            {
                id: "httpRoute"
                template: {
                    apiVersion: "gateway.networking.k8s.io/v1"
                    kind: "HTTPRoute"
                    metadata: {
                        name: "${deployment.metadata.name}"
                        namespace: "${deployment.metadata.namespace}"
                    }
                    spec: {
                        parentRefs: [
                            {
                                name: #config.metadata.name
                                sectionName: "https"
                            }
                        ]
                        hostnames: [#config.domain]
                        rules: [
                            {
                                backendRefs: [
                                    {
                                        group: ""
                                        kind: "Service"
                                        name: "${service.metadata.name}"
                                        port: 80
                                        weight: 1
                                    }
                                ]
                                matches: [
                                    {
                                        path: {
                                            type: "PathPrefix"
                                            value: "/${schema.metadata.name}/"
                                        }
                                    }
                                ]
                                filters: [
                                    {
                                        type: "URLRewrite"
                                        urlRewrite: path: {
                                            type: "ReplacePrefixMatch"
                                            replacePrefixMatch: "/"
                                        }
                                    }
                                ]
                            }
                        ]
                    }
                }
            },
            {
                id: "securityPolicy"
                template: {
                    apiVersion: "gateway.envoyproxy.io/v1alpha1"
                    kind: "SecurityPolicy"
                    metadata: {
                        name: "${deployment.metadata.name}"
                        namespace: "${deployment.metadata.namespace}"
                    }
                    spec: {
                        targetRefs: [
                            {
                                group: "gateway.networking.k8s.io"
                                kind: "HTTPRoute"
                                name: "${httpRoute.metadata.name}"
                            }
                        ]
                        oidc: {
                            provider: issuer: #config.oidc.issuer
                            clientID: #config.oidc.clientID
                            clientSecret: name: "\(#config.metadata.name)-oidc"
                            redirectURL: "https://\(#config.domain)/${schema.metadata.name}/oauth2/callback"
                            logoutPath: "/logout"
                            forwardAccessToken: true // forward token for authz
                            refreshToken: true
                            scopes: #config.oidc.scopes
                            cookieDomain: #config.domain
                        }
                        jwt: {
                            optional: true // allow login
                            providers: [
                                {
                                    name: "default"
                                    issuer: #config.oidc.issuer
                                    remoteJWKS: uri: #config.oidc.jwksURI
                                }
                            ]
                        }
                        authorization: {
                            defaultAction: "Deny"
                            rules: [
                                {
                                    name: "allow"
                                    action: "Allow"
                                    principal: jwt: {
                                        provider: "default"
                                        scopes: #config.oidc.scopes
                                        claims: [
                                            {
                                                name: #config.oidc.usernameClaim
                                                valueType: "String"
                                                values: "${schema.spec.allowedUsers}"
                                            }
                                        ]
                                    }
                                }
                            ]
                        }
                    }
                }
            }
        ]
    }
}
