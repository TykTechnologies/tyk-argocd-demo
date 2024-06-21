{{- define "replaceApiTargetUrl" -}}
{{- $apidef := .apidef -}}
{{- $targetUrl := .targetUrl -}}
{{- $result := regexReplaceAll "<<AUTO REPLACE TARGETURL>>" $apidef $targetUrl -}}
{{- printf "%s" $result -}}
{{- end -}}

{{- define "replaceApiListenPath" -}}
{{- $apidef := .apidef -}}
{{- $listenPath := .listenPath -}}
{{- $result := regexReplaceAll "<<AUTO REPLACE LISTENPATH>>" $apidef $listenPath -}}
{{- printf "%s" $result -}}
{{- end -}}

{{- define "getServiceUrl" -}}
{{- $serviceName := .serviceName -}}
{{- $namespace := .namespace -}}
{{- $port := .port -}}
{{- printf "http://%s.%s.svc.cluster.local:%s" $serviceName $namespace $port -}}
{{- end -}}