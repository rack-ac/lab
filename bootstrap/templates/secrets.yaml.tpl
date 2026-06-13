---
apiVersion: v1
kind: Namespace
metadata:
  name: external-secrets
---
apiVersion: v1
kind: Namespace
metadata:
  name: flux-system
---
apiVersion: v1
kind: Namespace
metadata:
  name: network
---
apiVersion: v1
kind: Namespace
metadata:
  name: observability
---
apiVersion: v1
kind: Secret
metadata:
  name: onepassword-connect-credentials-secret
  namespace: external-secrets
data:
  1password-credentials.json: op://kubernetes/1password-{{ ENV.CLUSTER }}/OP_SESSION_JSON
---
apiVersion: v1
kind: Secret
metadata:
  name: onepassword-connect-vault-secret
  namespace: external-secrets
stringData:
  OP_CONNECT_TOKEN: op://kubernetes/1password-{{ ENV.CLUSTER }}/OP_CONNECT_TOKEN
---
apiVersion: v1
kind: Secret
metadata:
  name: flux-webhook
  namespace: flux-system
stringData:
  token: op://kubernetes/flux/FLUX_GITHUB_WEBHOOK_SECRET
