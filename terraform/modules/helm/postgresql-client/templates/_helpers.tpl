{{- define "service.labels.standard" -}}
choerodon.io/release: {{ .Release.Name | quote }}
choerodon.io/infra: {{ .Chart.Name | quote }}
{{- end -}}

{{- define "pg.host" -}}
{{- printf "%v" .Values.env.PG_HOST -}}
{{- end -}}
{{- define "pg.port" -}}
{{- printf "%v" .Values.env.PG_PORT -}}
{{- end -}}
{{- define "pg.user" -}}
{{- printf "%v" .Values.env.PG_USER -}}
{{- end -}}
{{- define "pg.pass" -}}
{{- printf "%v" .Values.env.PG_PASS -}}
{{- end -}}
{{- define "pg.dbname" -}}
{{- printf "%v" .Values.env.PG_DBNAME -}}
{{- end -}}