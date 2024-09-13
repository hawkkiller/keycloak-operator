{{/* templates/_helpers.tpl */}}

{{- define "keycloak-operator.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "keycloak-operator.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name (include "keycloak-operator.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "keycloak-operator.labels" -}}
{{- $labels := dict }}
{{- $_ := set $labels "app.kubernetes.io/name" (include "keycloak-operator.name" .) }}
{{- $_ := set $labels "app.kubernetes.io/instance" .Release.Name }}
{{- range $key, $value := .Values.labels }}
{{- $_ := set $labels $key $value }}
{{- end }}
{{- toYaml $labels | nindent 4 }}
{{- end -}}

{{- define "keycloak-operator.annotations" -}}
{{- $annotations := dict }}
{{- range $key, $value := .Values.annotations }}
{{- $_ := set $annotations $key $value }}
{{- end }}
{{- toYaml $annotations | nindent 4 }}
{{- end -}}