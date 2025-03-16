package templates

import (
	httproutev1 "gateway.networking.k8s.io/httproute/v1"
)

#HTTPRoute: httproutev1.#HTTPRoute & {
	#config: #Config
	metadata: {
		name:         "\(#config.metadata.name)-https-redirect"
		namespace:    #config.metadata.namespace
		labels:       #config.metadata.labels
		annotations?: #config.metadata.annotations
	}
	spec: {
		parentRefs: [
			{
				name:        #config.metadata.name
				namespace:   #config.metadata.namespace
				sectionName: "http"
			},
		]
		hostnames: [#config.domain]
		rules: [{
			filters: [{
				type: "RequestRedirect"
				requestRedirect: {
					scheme:     "https"
					statusCode: 301
				}
			}]
		}]
	}
}
