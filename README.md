# workspace-provider

A [timoni.sh](http://timoni.sh) module for serving workspace resources in Kubernetes clusters.

## Prerequisites

* [kro](https://kro.run/) installed in the cluster
* [envoy-gateway](https://gateway.envoyproxy.io/) installed in the cluster
* [cert-manager](https://cert-manager.io/) and a ClusterIssuer that can be consumed by the Gateway
* The [PublishedResource](https://raw.githubusercontent.com/kcp-dev/api-syncagent/refs/heads/main/deploy/crd/kcp.io/syncagent.kcp.io_publishedresources.yaml) CustomResourceDefinition installed in the cluster
* An OIDC client
