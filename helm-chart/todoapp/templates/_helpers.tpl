{{- define "todoapp.fullname" -}}
{{- printf "%s-%s" .Chart.Name .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- define "todoapp.namespace" -}}
{{- .Values.namespace -}}
{{- end -}}
