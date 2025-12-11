{{/*
Common labels
*/}}
{{- define "eduhub.labels" -}}
app: {{ .Values.serviceName }}
{{- end }}

{{/*
Selector labels (for matching pods)
*/}}
{{- define "eduhub.selectorLabels" -}}
app: {{ .Values.serviceName }}
{{- end }}