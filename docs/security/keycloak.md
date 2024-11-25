### Keycloak

You can expose Keycloak to your localhost using the following command:
```
kubectl port-forward svc/keycloak-service --namespace tyk 7000 &
```

You can access the Keycloak instance in your browser at [localhost:7000](http://localhost:7000).
You can get the Keycloak admin username and password by running the following commands:
```
kubectl get secrets -n tyk keycloak-initial-admin -o jsonpath="{.data.username}" | base64 -d
kubectl get secrets -n tyk keycloak-initial-admin -o jsonpath="{.data.password}" | base64 -d
```
