{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "acme-service.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "acme-service.fullname" -}}
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

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "acme-service.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "acme-service.labels" -}}
helm.sh/chart: {{ include "acme-service.chart" . }}
{{ include "acme-service.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "acme-service.selectorLabels" -}}
app.kubernetes.io/name: {{ include "acme-service.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Istio Tracing labels
*/}}
{{- define "acme-service.tracingLabels" -}}
app: {{ .Release.Name }}
version: {{ .Values.image.tag | replace (printf "%s-" .Values.environment) "" }}
{{- end -}}

{{/*
Deployment Pod Annotations
*/}}
{{- define "acme-service.deploymentPodAnnotations" -}}
{{- if .Values.istio.rewriteAppHTTPProbers -}}
sidecar.istio.io/rewriteAppHTTPProbers: {{ toYaml .Values.istio.rewriteAppHTTPProbers }}
{{- end }}
{{- if or .Values.prometheus.uwsgiExporter.enable .Values.prometheus.scraper.enable }}
prometheus.io/scrape: "true"
{{- end }}
{{- if .Values.prometheus.scraper.enable }}
prometheus.io/path: {{ .Values.prometheus.scraper.endpoint | quote }}
prometheus.io/port: {{ default ((index .Values.ports 0).containerPort) .Values.prometheus.scraper.metricsPort | quote }}
{{- end }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "acme-service.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (.Release.Name) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the base domain for use for ingress routing from external to the cluster
e.g core.staging.acme.example
*/}}
{{- define "acme-service.ingressBaseDomain" -}}
{{- if .Values.ingress.domainOverride -}}
{{- .Values.ingress.domainOverride -}}
{{- else -}}
{{- printf "%s.%s.%s" .Values.ingress.prefix .Values.environment .Values.ingress.baseDomain -}}
{{- end -}}
{{- end -}}

{{/*
Create full domain for ingress routing virtual services
e.g. my-service.core.staging.acme.example
*/}}
{{- define "acme-service.ingressDomain" -}}
{{- printf "%s.%s" .Release.Name (include "acme-service.ingressBaseDomain" .) -}}
{{- end -}}

{{/*
Create Kubernetes Service domain name
e.g. my-service.namespace.svc.cluster.local
*/}}
{{- define "acme-service.k8sServiceDomain" -}}
{{- printf "%s.%s.svc.cluster.local" .Release.Name .Release.Namespace -}}
{{- end -}}

{{/*
Create URLs based on values from sharedConfiguration
*/}}
{{- define "acme-service.configMapURL" -}}
{{- printf "%s%s%s%s" ( default "" .Values.protocol) .Domain (default "" .Port) (default "" .Values.urlSuffix) -}}
{{- end -}}
