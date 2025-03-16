package templates

import (
	gatewayv1 "gateway.networking.k8s.io/gateway/v1"
)

#Gateway: gatewayv1.#Gateway & {
	#config: #Config
	metadata: #config.metadata & {
		annotations: #config.gateway.annotations
	}
	spec: {
		gatewayClassName: #config.gateway.className
		listeners: [
			{
				name:     "http"
				protocol: "HTTP"
				port:     80
				hostname: #config.domain
				allowedRoutes: namespaces: from: "Same"
			},
			{
				name:     "https"
				protocol: "HTTPS"
				port:     443
				hostname: #config.domain
				tls: {
					mode: "Terminate"
					certificateRefs: [{kind: "Secret", name: "\(#config.metadata.name)-tls"}]
				}
				allowedRoutes: namespaces: from: "Same"
			}
		]
	}
}
