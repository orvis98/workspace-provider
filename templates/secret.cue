package templates

import (
    corev1 "k8s.io/api/core/v1"
)

#ServiceAccountSecret: corev1.#Secret & {
    #config: #Config
    apiVersion: "v1"
    kind: "Secret"
    metadata: #config.metadata
    metadata: annotations: "kubernetes.io/service-account.name": #config.metadata.name
    type: "kubernetes.io/service-account-token"
}

#OIDCSecret: corev1.#Secret & {
    #config: #Config
    apiVersion: "v1"
    kind: "Secret"
    metadata: {
        name: "\(#config.metadata.name)-oidc"
        namespace: #config.metadata.namespace
        labels: #config.metadata.labels
        annotations: #config.metadata.annotations
    }
    stringData: "client-secret": #config.oidc.clientSecret
}
