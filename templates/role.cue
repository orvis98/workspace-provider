package templates

import (
	rbacv1 "k8s.io/api/rbac/v1"
)

#Role: rbacv1.#Role & {
	#config: #Config
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "Role"
	metadata: #config.metadata
	rules: [
		{
			apiGroups: ["kro.run"]
			resources: ["workspaces"]
  			verbs: ["create", "delete", "deletecollection", "get", "list", "patch", "update", "watch"]
		}
	]
}
