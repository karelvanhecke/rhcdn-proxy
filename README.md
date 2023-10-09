# RHCDN Proxy

## Description

RHCDN Proxy acts as a caching proxy between your Red Hat Enterprise Linux system and the Red Hat Content Delivery Network.

It handles the client certificate authentication required to access the CDN. All you need to provide is a Red Hat organization ID and an activation key.

## Deployment on Kubernetes using Flux

The following is an example of how to deploy the RHCDN Proxy on Kubernetes using Flux.
This basic configuration will distribute the cache entries over 2 RHCDN Proxy replicas using consistent hashing on the ingress.

```yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: rhcdn-proxy
  labels:
    pod-security.kubernetes.io/enforce: baseline # Restricted is not supported
    pod-security.kubernetes.io/warn: baseline
    pod-security.kubernetes.io/audit: baseline
---
apiVersion: source.toolkit.fluxcd.io/v1beta2
kind: OCIRepository
metadata:
  name: rhcdn-proxy
  namespace: rhcdn-proxy
spec:
  interval: 24h
  provider: generic
  ref:
    tag: v0.2.1
  url: oci://ghcr.io/karelvanhecke/manifests/rhcdn-proxy
  verify:
    provider: cosign
---
# This secret is required for rhcdn-proxy to function
apiVersion: v1
kind: Secret
metadata:
    name: rhcdn-proxy
    namespace: rhcdn-proxy
data:
    activationkey: <activation_key> # https://access.redhat.com/articles/1378093
    org: <red_hat_organization_id>
---
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: rhcdn-proxy
  namespace: rhcdn-proxy
spec:
  interval: 1h0m0s
  timeout: 5m
  retryInterval: 1m
  path: ./
  prune: true
  wait: true
  sourceRef:
    kind: OCIRepository
    name: rhcdn-proxy
  patches:
  - patch: |-
      - op: replace
        path: /spec/replicas
        value: 2
    target:
      kind: Deployment
      name: rhcdn-proxy
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: rhcdn-proxy
  namespace: rhcdn-proxy
  annotations:
    # https://www.nginx.com/blog/shared-caches-nginx-plus-cache-clusters-part-1/#Sharding-Your-Cache
    nginx.ingress.kubernetes.io/upstream-hash-by: "$scheme$proxy_host$request_uri" # kubernetes/ingress-nginx
spec:
  ingressClassName: nginx
  rules:
  - host: rhcdn-proxy.example.org
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: rhcdn-proxy
            port:
              number: 80
```
