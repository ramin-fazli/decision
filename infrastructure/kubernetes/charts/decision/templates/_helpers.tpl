{{/*
Expand the name of the chart.
*/}}
{{- define "decision.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "decision.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "decision.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "decision.labels" -}}
helm.sh/chart: {{ include "decision.chart" . }}
{{ include "decision.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "decision.selectorLabels" -}}
app.kubernetes.io/name: {{ include "decision.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Component labels
*/}}
{{- define "decision.componentLabels" -}}
{{ include "decision.labels" . }}
app.kubernetes.io/component: {{ .component }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "decision.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "decision.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Generate image name
*/}}
{{- define "decision.image" -}}
{{- $registry := .Values.global.imageRegistry | default .Values.image.registry -}}
{{- $repository := .repository -}}
{{- $tag := .tag | default .Chart.AppVersion -}}
{{- if $registry }}
{{- printf "%s/%s:%s" $registry $repository $tag }}
{{- else }}
{{- printf "%s:%s" $repository $tag }}
{{- end }}
{{- end }}

{{/*
Generate database connection string
*/}}
{{- define "decision.databaseUrl" -}}
{{- $host := .Values.externalServices.database.host -}}
{{- $port := .Values.externalServices.database.port -}}
{{- $database := .Values.externalServices.database.name -}}
{{- $username := .Values.externalServices.database.username -}}
{{- printf "postgresql://%s:$(DATABASE_PASSWORD)@%s:%v/%s" $username $host $port $database }}
{{- end }}

{{/*
Generate Redis connection string
*/}}
{{- define "decision.redisUrl" -}}
{{- $host := .Values.externalServices.redis.host -}}
{{- $port := .Values.externalServices.redis.port -}}
{{- if .Values.externalServices.redis.passwordSecret.name }}
{{- printf "redis://:$(REDIS_PASSWORD)@%s:%v/0" $host $port }}
{{- else }}
{{- printf "redis://%s:%v/0" $host $port }}
{{- end }}
{{- end }}

{{/*
Generate MinIO/S3 endpoint
*/}}
{{- define "decision.objectStorageUrl" -}}
{{- $endpoint := .Values.externalServices.objectStorage.endpoint -}}
{{- $bucket := .Values.externalServices.objectStorage.bucket -}}
{{- printf "%s/%s" $endpoint $bucket }}
{{- end }}

{{/*
Common environment variables
*/}}
{{- define "decision.commonEnv" -}}
- name: ENVIRONMENT
  value: {{ .Values.environment | quote }}
- name: DATABASE_URL
  value: {{ include "decision.databaseUrl" . | quote }}
- name: REDIS_URL
  value: {{ include "decision.redisUrl" . | quote }}
- name: MINIO_ENDPOINT
  value: {{ .Values.externalServices.objectStorage.endpoint | quote }}
- name: MINIO_BUCKET
  value: {{ .Values.externalServices.objectStorage.bucket | quote }}
{{- if .Values.externalServices.database.passwordSecret.name }}
- name: DATABASE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalServices.database.passwordSecret.name }}
      key: {{ .Values.externalServices.database.passwordSecret.key }}
{{- end }}
{{- if .Values.externalServices.redis.passwordSecret.name }}
- name: REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalServices.redis.passwordSecret.name }}
      key: {{ .Values.externalServices.redis.passwordSecret.key }}
{{- end }}
{{- if .Values.externalServices.objectStorage.accessKeySecret.name }}
- name: MINIO_ACCESS_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalServices.objectStorage.accessKeySecret.name }}
      key: {{ .Values.externalServices.objectStorage.accessKeySecret.key }}
- name: MINIO_SECRET_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalServices.objectStorage.secretKeySecret.name }}
      key: {{ .Values.externalServices.objectStorage.secretKeySecret.key }}
{{- end }}
{{- end }}

{{/*
Resource limits and requests
*/}}
{{- define "decision.resources" -}}
{{- if .resources }}
resources:
  {{- if .resources.limits }}
  limits:
    {{- if .resources.limits.cpu }}
    cpu: {{ .resources.limits.cpu }}
    {{- end }}
    {{- if .resources.limits.memory }}
    memory: {{ .resources.limits.memory }}
    {{- end }}
    {{- if .resources.limits.gpu }}
    nvidia.com/gpu: {{ .resources.limits.gpu }}
    {{- end }}
  {{- end }}
  {{- if .resources.requests }}
  requests:
    {{- if .resources.requests.cpu }}
    cpu: {{ .resources.requests.cpu }}
    {{- end }}
    {{- if .resources.requests.memory }}
    memory: {{ .resources.requests.memory }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end }}

{{/*
Security Context
*/}}
{{- define "decision.securityContext" -}}
securityContext:
  {{- toYaml .Values.securityContext | nindent 2 }}
{{- end }}

{{/*
Pod Security Context
*/}}
{{- define "decision.podSecurityContext" -}}
securityContext:
  {{- toYaml .Values.podSecurityContext | nindent 2 }}
{{- end }}

{{/*
Node Selection
*/}}
{{- define "decision.nodeSelection" -}}
{{- if .nodeSelector }}
nodeSelector:
  {{- toYaml .nodeSelector | nindent 2 }}
{{- end }}
{{- if .tolerations }}
tolerations:
  {{- toYaml .tolerations | nindent 2 }}
{{- end }}
{{- if .affinity }}
affinity:
  {{- toYaml .affinity | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Health Checks
*/}}
{{- define "decision.healthChecks" -}}
{{- if .livenessProbe }}
livenessProbe:
  {{- toYaml .livenessProbe | nindent 2 }}
{{- end }}
{{- if .readinessProbe }}
readinessProbe:
  {{- toYaml .readinessProbe | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Volume Mounts
*/}}
{{- define "decision.volumeMounts" -}}
{{- if .volumeMounts }}
volumeMounts:
  {{- toYaml .volumeMounts | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Volumes
*/}}
{{- define "decision.volumes" -}}
{{- if .volumes }}
volumes:
  {{- toYaml .volumes | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Image Pull Secrets
*/}}
{{- define "decision.imagePullSecrets" -}}
{{- $pullSecrets := list }}
{{- if .Values.global.imagePullSecrets }}
{{- $pullSecrets = .Values.global.imagePullSecrets }}
{{- end }}
{{- if .Values.image.pullSecrets }}
{{- $pullSecrets = concat $pullSecrets .Values.image.pullSecrets }}
{{- end }}
{{- if $pullSecrets }}
imagePullSecrets:
  {{- range $pullSecrets }}
  - name: {{ . }}
  {{- end }}
{{- end }}
{{- end }}

{{/*
Monitoring labels
*/}}
{{- define "decision.monitoringLabels" -}}
{{- if .Values.monitoring.enabled }}
monitoring: enabled
prometheus.io/scrape: "true"
prometheus.io/port: "8000"
prometheus.io/path: "/metrics"
{{- end }}
{{- end }}

{{/*
Istio labels
*/}}
{{- define "decision.istioLabels" -}}
{{- if .Values.serviceMesh.istio.enabled }}
version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- end }}

{{/*
Generate storage class name
*/}}
{{- define "decision.storageClass" -}}
{{- if .Values.global.storageClass }}
{{- .Values.global.storageClass }}
{{- else if .storageClass }}
{{- .storageClass }}
{{- end }}
{{- end }}
