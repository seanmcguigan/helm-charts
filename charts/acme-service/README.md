# acme-service

A Helm chart for creating a standardised acme k8s service deployment.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additionalContainers | object | `{}` | Allow passing entire container definitions to append to the main deployment. Useful for proxy containers etc. |
| affinity.podAntiAffinity | object | `{"requiredDuringSchedulingIgnoredDuringExecution":[{"labelSelector":{"matchExpressions":[{"key":"app","operator":"In","values":["prometheus"]}]},"topologyKey":"kubernetes.io/hostname"}]}` | Pod anti-affinity rules. By default, acme-service pods have a hard anti-affinity for prometheus since it can be quite resource intensive. Set this to `{}` to overwrite this default. |
| clusterConfigMap | string | `nil` | The configmap for the cluster. Used to add cluster env vars to each acme-service deployment. Defaults to `<environment>->clusterVersion>` if not set. |
| clusterVersion | string | `"v1"` | The cluster version the application is being deployed into (e.g. v1). |
| command | list | `[]` | The command for the container to run in array format. |
| createK8sService | bool | `true` | When true, a K8s service is create and pods ports configured. Otherwise it simply creates a deployment, useful for defining Queue workers |
| deployment.annotations | object | `{"reloader.stakater.com/auto":"true"}` | Annotations to add to the deployment. We add an annotation for https://github.com/stakater/Reloader by default. |
| environment | string | `"staging"` | The environment the application is being deployed into (e.g. staging or production). |
| flux.enable | bool | `false` | Whether or not to enable fluxv2 components ImageRepository and ImagePolicy. |
| flux.imagePolicy.filterTags | object | `{"extract":"$bn","patternSuffix":"-[a-fA-F0-9]+-(?P<bn>.*)"}` | Specify a filter on the image tags before they are considered by the policy rule. |
| flux.imagePolicy.filterTags.extract | string | `"$bn"` | Field used to extract a value from the matching tags which is supplied to the policy rule instead of the original tags. |
| flux.imagePolicy.filterTags.patternSuffix | string | `"-[a-fA-F0-9]+-(?P<bn>.*)"` | Only tags that match the pattern are considered by the policy rule. The filterTags.pattern is comprised of "^{{ $.Values.environment }}{{ .patternSuffix }}" . if updating the patternSuffix, be sure to update the extract value as required. |
| flux.imagePolicy.policy.numerical.order | string | `"asc"` | Numerical policy chooses the last tag when all the tags are sorted numerically (in either ascending or descending order). |
| flux.imageRepository.interval | string | `"1m0s"` | The length of time to wait between scans of the image repository. |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"nginx"` |  |
| image.tag | string | `"latest"` |  |
| ingress.baseDomain | string | `"acme.example"` | The base ingress domain. Becomes RELEASE-NAME.<prefix>.<environment>.<baseDomain> |
| ingress.domainOverride | string | `nil` | Overwrites the full base domain to use for external ingress hosts. e.g. RELEASE-NAME.<ingressDomainOverrideValue> |
| ingress.prefix | string | `"core"` | A prefix to apply to the ingress address. Becomes RELEASE-NAME.<prefix>.<environment>.<baseDomain> |
| initContainers | list | `[]` | any init containers to add to the deployment |
| istio.crossRegionIgnoreURIPatterns | list | `[]` |  |
| istio.crossRegionRedirectVerbs[0] | string | `"DELETE"` |  |
| istio.crossRegionRedirectVerbs[1] | string | `"PATCH"` |  |
| istio.crossRegionRedirectVerbs[2] | string | `"POST"` |  |
| istio.crossRegionRedirectVerbs[3] | string | `"PUT"` |  |
| istio.crossRegionWriteTimeout | string | `"30s"` | When enableCrossRegionWrites is true, this value sets the response timeout for the cross region WRITE requests to the external cluster. Without specifying this, the istio default would be 15s. |
| istio.defaultGateway | string | `"default-gateway"` | The domain for the default ISTIO Gateway. |
| istio.enable | bool | `true` | Whether or not to include istio components like VirtualService and ServiceEntry. |
| istio.enableCrossRegionWrites | bool | `false` | When true, rewrite rules are added to VirtualServices to direct WRITE requests to the external cluster |
| istio.rewriteAppHTTPProbers | string | `"true"` | Whether or not to rewrite HTTP liveness and readiness probes to be sent to the pilot agent first. This must be true when mTLS is enabled. |
| istio.routing.crossRegionSubset | string | `"eu"` | The DestinationRule subset to use for forwarding cross region requests to |
| istio.routing.defaultSubset | string | `nil` | The DestinationRule subset to use for local requests (eu|ap) |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` | Additional annotations to add to the pod template. Merged with chart-managed annotations (Istio, Prometheus). |
| ports | list | `[{"containerPort":5000,"name":"app","protocol":"TCP","protocolName":"http"}]` | A list of port configurations. HTTP ports should always be the first element in the list |
| prometheus.scraper.enable | bool | `false` | Adds annotations to the deployment to allow for prometheus to scrape metrics from it |
| prometheus.scraper.endpoint | string | `"/metrics"` | Specifies the URL which prometheus should pull from |
| prometheus.scraper.metricsPort | string | `nil` | Specifies a different port to scrape metrics from. If blank, the service's main port will be used |
| prometheus.serviceMonitor.enable | bool | `false` | Creates a ServiceMonitor resource for use with custom metrics |
| prometheus.serviceMonitor.portName | string | `"app"` | Sets which port on which the ServiceMonitor extracts metrics |
| prometheus.uwsgiExporter.enable | bool | `false` | Adds an additional container into the deployment which exports uWSGI stats if true |
| prometheus.uwsgiExporter.image | string | `"123456789012.dkr.ecr.eu-west-1.amazonaws.com/acme/uwsgi-exporter:v1.0.0"` | The image containing the exporter |
| prometheus.uwsgiExporter.statsEndpoint | string | `"http://localhost:9191"` | The endpoint from which the export retrieves metrics from. This is defined by the uwsgi configuration of the service |
| resources.limits.memory | string | `"120Mi"` |  |
| resources.requests.cpu | string | `"100m"` |  |
| resources.requests.memory | string | `"120Mi"` |  |
| scaling.cpuAvgUtilisation | string | `nil` |  |
| scaling.maxReplicas | int | `8` |  |
| scaling.memoryAvgUtilisation | string | `nil` |  |
| scaling.metrics | list | `[]` |  |
| scaling.minReplicas | int | `2` | The minimum number of instances for the applications Horizontal Pod Autoscaling definition. |
| secretPathPrefix | string | `nil` | Defaults to `/acme-services/clusterVersion/releaseName/environment` if not set. If you want to load the secrets from a custom prefix that differs from the release name, set it here. E.g. A release named `myapp-backend` could load secrets from `/acme-services/v1/myapp/staging` instead of the default `/acme-services/v1/myapp-backend/staging`. |
| secrets | list | `[]` | Here you can pass through a list of secret names that will be loaded from AWS SSM param store as environment variables. The path in param store must be as follows: `<secretPathPrefix>/MY_ENV_VAR`. For example, passing `[DATABASE_URL]` for a release named `myapp` in `staging` environment using the default secretPathPrefix of `/acme-services/clusterVersion/releaseName/environment` would look for a secret in `/acme-services/v2/myapp/staging/DATABASE_URL` and set the value of this as the environment variable `DATABASE_URL` in the container. |
| secretsAdditional | list | `[]` | If you have secrets under a different path, or if you want to map the secret to a different name, you can use secretsAdditional in the format [{key: /my/other/ssm/path/FOO, name: BAR }] |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `nil` | A name for the service account. If not set, will use the release name instead. |
| serviceAccount.roleArn | string | `nil` | An IAM role arn to add as an annotation to the created service account for pod based IAM permissions. |
| sharedConfiguration.external.protocol | string | `"https://"` | The protocal to set for the external url property. |
| sharedConfiguration.external.urlSuffix | string | `nil` | Appends a path suffix for the external url property. Used if API versioning is in place (for example). |
| sharedConfiguration.internal.protocol | string | `"http://"` | The protocal to set for the internal url property. |
| sharedConfiguration.internal.urlSuffix | string | `nil` | Appends a path suffix for the internal url property. Used if API versioning is in place (for example). |
| tolerations | list | `[]` |  |
| volumeMounts | list | `[]` | Specifies the mount location (and options) for the service's container from the volumes list |
| volumes | list | `[]` | Specifies any volumes to make available to the Pod |

## Generating updated README
This readme has been generated using https://github.com/norwoodj/helm-docs. See `README.md.gotmpl` for the template used.
