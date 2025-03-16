package templates

import (
	runtime "k8s.io/apimachinery/pkg/runtime"
	timoniv1 "timoni.sh/core/v1alpha1"
	"net"
)

// Config defines the schema and defaults for the Instance values.
#Config: {
	// Timoni runtime version info
	moduleVersion!: string
	kubeVersion!:   string

	// Enforce minimum Kubernetes version
	clusterVersion: timoniv1.#SemVer & {#Version: kubeVersion, #Minimum: "1.32.0"}

	// Metadata (common to all resources)
	metadata: timoniv1.#Metadata & {#Version: moduleVersion}
	metadata: annotations: timoniv1.#Annotations

	// Domain to publish the workspaces on
	domain: net.FQDN

	// Options for the managed Gateway
	gateway: {
		className: string | *"envoy"
		controllerNamespace: string | *"envoy-gateway-system"
		annotations: timoniv1.#Annotations | *{"cert-manager.io/cluster-issuer": "organization"}
	}

	// Options for the managed ResourceGraphDefinition
	resource: {
		create: bool | *true
		apiGroup: string | *"kro.run"
		version: string | *"v1alpha1"
		kind: string | *"Workspace"
		naming: string | *"$remoteClusterName-$remoteNamespace-$remoteName"
	}

	// Options for the managed SecurityPolicies
	oidc: {
		issuer: string
		jwksURI: string
		clientID: string
		clientSecret: string
		scopes: [...string] | *["openid", "profile"]
		usernameClaim: string | *"preferred_username"
	}
}

// Instance takes the config values and outputs the Kubernetes objects.
#Instance: {
	config: #Config

	objects: [ID=_]: runtime.#Object

	objects: {
		ciliumNetworkPolicy: #CiliumNetworkPolicy & {#config: config}
		gateway: #Gateway & {#config: config}
		httpRoute: #HTTPRoute & {#config: config}
		serviceAccount: #ServiceAccount & {#config: config}
		serviceAccountSecret: #ServiceAccountSecret & {#config: config}
		oidcSecret: #OIDCSecret & {#config: config}
		role: #Role & {#config: config}
		roleBinding: #RoleBinding & {#config: config}
		resourceGraphDefinition: #ResourceGraphDefinition & {#config: config}
		publishedResource: #PublishedResource & {#config: config}
	}
}
