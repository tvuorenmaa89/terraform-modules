apiVersion: v1
kind: Namespace
metadata:
  name: azure-metrics
  labels:
    name              = "azure-metrics"
    xkf.xenit.io/kind = "platform"
---
apiVersion: source.toolkit.fluxcd.io/v1beta2
kind: HelmRepository
metadata:
  name: azure-metrics
  namespace: azure-metrics
spec:
  interval: 1m0s
  url: "https://webdevops.github.io/helm-charts/"
---
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: azure-metrics
  namespace: azure-metrics
spec:
  chart:
    spec:
      chart: azure-metrics-exporter
      sourceRef:
        kind: HelmRepository
        name: azure-metrics
      version: v1.2.1
  interval: 1m0s
  values:
    fullnameOverride: "ezure-metrics-exporter"
    image:
      tag: "24.2.0"
    resources:
      requests:
        cpu: 15m
        memory: 25Mi
    podLabels:
      azure.workload.identity/use: "true"
    serviceAccount:
      # name must correlate with azurerm_federated_identity_credential.azure_metrics.subject
      name: azure-metrics-exporter
      labels:
        azure.workload.identity/use: "true"
    netpol:
      enabled: false
---
apiVersion: aadpodidentity.k8s.io/v1
kind: AzureIdentity
metadata:
  name: azure-metrics
  namespace: azure-metrics
spec:
  type: 0
  resourceID: ${resource_id}
  clientID: ${client_id}
---
apiVersion: aadpodidentity.k8s.io/v1
kind: AzureIdentityBinding
metadata:
  name: azure-metrics
  namespace: azure-metrics
spec:
  azureIdentity: azure-metrics
  selector: azure-metrics
---
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  labels:
    app.kubernetes.io/name: azure-metrics
    app.kubernetes.io/instance: azure-metrics
    xkf.xenit.io/monitoring: platform
  name: azure-metrics-exporter
spec:
  podMetricsEndpoints:
  - interval: 60s
    port: http
    path: /metrics
  selector:
    matchLabels:
      app.kubernetes.io/name: azure-metrics
      app.kubernetes.io/instance: azure-metrics-exporter
%{ if podmonitor_loadbalancer }
---
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  labels:
    app.kubernetes.io/name: azure-metrics
    app.kubernetes.io/instance: azure-metrics
    xkf.xenit.io/monitoring: platform
  name: azure-metrics-exporter-loadbalancers
spec:
  podMetricsEndpoints:
  - interval: 60s
    port: http
    path: /probe/metrics/list
    params:
      name: ["azure-metric"]
      subscription:
        - ${subscription_id}
      template:
        - '{name}_{metric}_{aggregation}_{unit}'
      resourceType:
        - Microsoft.Network/loadBalancers
      aggregation:
        - average
        - total
      metric:
        - SnatConnectionCount
        - AllocatedSnatPorts
        - UsedSnatPorts
  selector:
    matchLabels:
      app.kubernetes.io/name: azure-metrics
      app.kubernetes.io/instance: azure-metrics-exporter
%{ endif }
%{ if podmonitor_kubernetes }
---
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  labels:
    app.kubernetes.io/name: azure-metrics
    app.kubernetes.io/instance: azure-metrics
    xkf.xenit.io/monitoring: platform
  name: azure-metrics-exporter-kubernetes
spec:
  podMetricsEndpoints:
  - interval: 60s
    port: http
    path: /probe/metrics/list
    params:
      name: ["azure-metric"]
      subscription:
        - ${subscription_id}
      template:
        - '{metric}'
      resourceType:
        - Microsoft.ContainerService/managedClusters
      aggregation:
        - average
        - total
      metric:
        - cluster_autoscaler_cluster_safe_to_autoscale
        - cluster_autoscaler_scale_down_in_cooldown
        - cluster_autoscaler_unneeded_nodes_count
        - cluster_autoscaler_unschedulable_pods_count
  selector:
    matchLabels:
      app.kubernetes.io/name: azure-metrics
      app.kubernetes.io/instance: azure-metrics-exporter
%{ endif }
