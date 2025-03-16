package templates

import (
    publishedresourcev1 "syncagent.kcp.io/publishedresource/v1alpha1"
)

#PublishedResource: publishedresourcev1.#PublishedResource & {
    #config: #Config
    metadata: #config.metadata & {
        labels: active: "true"
    }
    spec: {
        resource: {
            apiGroup: #config.resource.apiGroup
            version: #config.resource.version
            kind: #config.resource.kind
        }
        naming: name: #config.resource.naming
    }
}
