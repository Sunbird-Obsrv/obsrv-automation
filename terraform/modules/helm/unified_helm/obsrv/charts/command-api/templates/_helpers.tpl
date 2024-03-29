{{/* vim: set filetype=mustache: */}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "command-service.rbacRules" }}
{{/*
RBAC rules used to create the cluster role based on the scope
*/}}
rules:
  - apiGroups:
      - ""
      - "batch"
      - "extensions"
      - "apps"
    resources:
      - "*"
    verbs:
      - "*"
{{- if .Values.rbac.nodesRule.create }}
  - apiGroups:
    - ""
    resources:
      - nodes
    verbs:
      - list
{{- end }}
{{- end }}