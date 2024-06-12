# Tyk K8S API Platform Teams Demo
This repository will help you get started with Tyk deployment in Kubernetes and allow 
you to leverage OSS tools such as Prometheus, Jaeger for monitoring and Keycloak for
managing API authentication and authorization in k8s using OAuth2.0

## Requirements
1. [minikube](https://minikube.sigs.k8s.io/docs/start/)
2. [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
3. [helm](https://helm.sh/docs/intro/install/)

## Installation

### Minikube & Helm Repositories

Start Minikube
```
minikube start
minikube addons enable ingress
```

### ArgoCD

Install ArgoCD on Minikube

```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

You can expose ArgoCD UI using the following command:
```
kubectl port-forward svc/argocd-server --namespace argocd 8443:443 &
```

You can access the ArgoCD instance in your browser at [localhost:8443](http://localhost:8443):
```
Username: admin
```

You can get the ArgoCD admin password by running the following command:
```
kubectl get secrets -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### Observability Tools

Install observability tools using ArgoCD Application CRDs

```
kubectl apply -f apps/observability
```

### Tyk

Choose between single cluster all-in-one deployment model or distributed deployment model.

#### Tyk (Single cluster all-in-one deployment)

Make sure you have the Tyk Dashboard license key ready and replace "<REPLACE_WITH_DASH_LICENSE>" with it in the command below.

Create secret with Tyk credentials:
```
kubectl create namespace tyk
```

```
kubectl create secret generic tyk-conf --namespace=tyk \
   --from-literal=APISecret=CHANGEME \
   --from-literal=AdminSecret=12345 \
   --from-literal=DashLicense=<REPLACE_WITH_DASH_LICENSE>
```

Install Tyk using ArgoCD Application CRDs

```
kubectl apply -f apps/tyk.yaml
```

You can expose the Tyk Dashboard and Gateway to your localhost using the following command:

```
kubectl port-forward svc/gateway-svc-tyk-gateway --namespace tyk 8080 &
```

```
kubectl port-forward svc/dashboard-svc-tyk-gateway-tyk-dashboard --namespace tyk 3000 &
```

You can check the state of the Tyk gateway using the following `curl` command:
```
curl localhost:8080/hello
```

You can access Tyk Dashboard here:
```
http://localhost:3000
```

Default admin login is "default@example.com" / "topsecretpassword". It can be changed in the ArgoCD app manifest.

#### Tyk (Distributed deployment)

Make sure you have the Tyk Dashboard and MDCB license keys ready and replace "<REPLACE_WITH_DASH_LICENSE>" and "<REPLACE_WITH_MDCB_LICENSE>" with your actual keys in the command below.

First, install Tyk control plane.

Create secret with Tyk credentials:
```
kubectl create namespace tyk-cp
```

```
kubectl create secret generic tyk-cp-conf --namespace=tyk-cp \
   --from-literal=APISecret=CHANGEME \
   --from-literal=AdminSecret=12345 \
   --from-literal=DashLicense=<REPLACE_WITH_DASH_LICENSE> \
   --from-literal=MDCBLicense=<REPLACE_WITH_MDCB_LICENSE>
```

Install Tyk using ArgoCD Application CRDs

```
kubectl apply -f apps/tyk-control-plane.yaml
```

You can expose the Tyk Dashboard to your localhost using the following command:

```
kubectl port-forward svc/dashboard-svc-tyk-cp-tyk-dashboard --namespace tyk-cp 3001:3000 &
```

You can access Tyk Dashboard here:
```
http://localhost:3001
```

Default admin login is "default@example.com" / "topsecretpassword". It can be changed in the ArgoCD app manifest.

Next, install the Tyk data plane.

Create secret with remote control plane credentials:
```
kubectl create namespace tyk-dp
```

```
kubectl create secret generic tyk-dp-conf --namespace=tyk-dp \
   --from-literal=APISecret=CHANGEME \
   --from-literal=AdminSecret=12345 \
   --from-literal=groupID=mygroup \
   --from-literal=orgId=$(kubectl get secret tyk-operator-conf --namespace=tyk-cp -o jsonpath='{.data.TYK_ORG}' | base64 -d) \
   --from-literal=userApiKey=$(kubectl get secret tyk-operator-conf --namespace=tyk-cp -o jsonpath='{.data.TYK_AUTH}' | base64 -d)
```

Install Tyk using ArgoCD Application CRDs

```
kubectl apply -f apps/tyk-data-plane.yaml
```

You can expose the Data Plane Tyk Gateway to your localhost using the following command:

```
kubectl port-forward svc/gateway-svc-tyk-dp-tyk-gateway --namespace tyk-dp 8081:8080 &
```

You can check the state of the Tyk gateway using the following `curl` command:
```
curl localhost:8081/hello
```

### Tyk Operator

Install Tyk Operator using ArgoCD Application CRDs

```
kubectl apply -f apps/tyk-operator.yaml
```

### Deploy HttpBin service and expose it through the Tyk Gateway

Install Tyk Operator using ArgoCD Application CRDs
```
kubectl apply -f apps/httpbin.yaml
```

You can access the httpbin api using the following curl command:
```
curl localhost:8080/httpbin/get
```

### Keycloak

Install Keycloak using ArgoCD Application CRDs

```
kubectl apply -f apps/keycloak.yaml
```

You can expose Keycloak to your localhost using the following command:
```
kubectl port-forward svc/keycloak-service --namespace tyk 7000 &
```

You can access the Keycloak instance in your browser at [localhost:7000](http://localhost:7000):
```
Username: default@example.com
Password: topsecretpassword
```

### Expose HttpBin through the Tyk Gateway and manage AuthN and AuthZ using OAuth2.0

There are three user profiles available; you can generate a JWT associated 
with each profile using the following curl commands. The JWT can be passed to
the gateway under the `Authorization` header:

- Developer user, gives access to `/xml` endpoint:
```
curl -L --insecure -s -X POST 'http://localhost:7000/realms/keycloak-oauth/protocol/openid-connect/token' \
   -H 'Content-Type: application/x-www-form-urlencoded' \
   --data-urlencode 'client_id=keycloak-oauth' \
   --data-urlencode 'grant_type=password' \
   --data-urlencode 'client_secret=NoTgoLZpbrr5QvbNDIRIvmZOhe9wI0r0' \
   --data-urlencode 'scope=openid' \
   --data-urlencode 'username=developer@example.com' \
   --data-urlencode 'password=topsecretpassword' | jq -r '.access_token'
```

- Admin user, gives access to all endpoints:
```
curl -L --insecure -s -X POST 'http://localhost:7000/realms/keycloak-oauth/protocol/openid-connect/token' \
   -H 'Content-Type: application/x-www-form-urlencoded' \
   --data-urlencode 'client_id=keycloak-oauth' \
   --data-urlencode 'grant_type=password' \
   --data-urlencode 'client_secret=NoTgoLZpbrr5QvbNDIRIvmZOhe9wI0r0' \
   --data-urlencode 'scope=openid' \
   --data-urlencode 'username=admin@example.com' \
   --data-urlencode 'password=topsecretpassword' | jq -r '.access_token'
```

- Random user, does not give access even if it can generate a valid Keycloak JWT:
```
curl -L --insecure -s -X POST 'http://localhost:7000/realms/keycloak-oauth/protocol/openid-connect/token' \
   -H 'Content-Type: application/x-www-form-urlencoded' \
   --data-urlencode 'client_id=keycloak-oauth' \
   --data-urlencode 'grant_type=password' \
   --data-urlencode 'client_secret=NoTgoLZpbrr5QvbNDIRIvmZOhe9wI0r0' \
   --data-urlencode 'scope=openid' \
   --data-urlencode 'username=random@example.com' \
   --data-urlencode 'password=topsecretpassword' | jq -r '.access_token'
```

You can access the httpbin Keycloak managed api using the following curl command:
```
curl -L --insecure -s -X POST 'http://localhost:8080/httpbin-jwt/get' \
   -H 'Authorization: $JWT'
```