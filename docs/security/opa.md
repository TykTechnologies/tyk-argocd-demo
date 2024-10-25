### OPA

Adds an OPA rule to the dashboard API to enforce Keycloak JWT Authentication on OAS API "keycloak"

```
patch_request[x] {
   request_permission[_] == "apis"
   request_intent == "write"
   input.request.body["x-tyk-api-gateway"].info.name == "keycloak"
   payload := {
      "components": {
         "securitySchemes": {
            "jwtAuth": {
               "type": "http",
               "scheme": "bearer",
               "bearerFormat": "JWT"
            }
         } 
      },
      "security": [
         {
            "jwtAuth": []
         }
      ],
      "x-tyk-api-gateway": {
         "server": {
            "authentication": {
               "enabled": true,
               "securitySchemes": {
                  "jwtAuth": {
                     "header": {
                        "enabled": true,
                        "name": "Authorization"   
                     },
                     "identityBaseField": "sub",
                     "policyFieldName": "pol",
                     "enabled": true,
                     "defaultPolicies": [ "dHlrL25vLW9w" ], 
                     "scopes": { 
                        "claimName": "group", 
                        "scopeToPolicyMapping": [ { 
                           "scope": "admins", 
                           "policyId": "dHlrL2tleWNsb2FrLWFkbWlucw" }, { 
                           "scope": "developers", 
                           "policyId": "dHlrL2tleWNsb2FrLWRldmVsb3BlcnM" 
                        } ] 
                     }, 
                     "signingMethod": "rsa", 
                     "source": "http://keycloak-service.tyk.svc:7000/realms/keycloak-oauth/protocol/openid-connect/certs"
                  }
               }
            } 
         }
      }
   }
}
```