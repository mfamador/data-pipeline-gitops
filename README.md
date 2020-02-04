# Auto Scalable Data Pipeline
A GitOps repository for an auto-scalable data pipeline

## Create a local Kubernetes cluster

### Create a multi-node k3s cluster with k3d

Install k3d
```
brew install k3d
```

Create a k8s cluster with 6 worker nodes and expose 8080 for Traefik ingress controller
```
k3d create --publish 8080:80 --workers 8
export KUBECONFIG="$(k3d get-kubeconfig --name='k3s-default')"
```

If you need to add additional nodes:
```
k3d add-node
```

## Install Helm

```
kubectl create serviceaccount -n kube-system tiller

kubectl create clusterrolebinding tiller-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:tiller

helm init --service-account tiller --tiller-namespace kube-system

helm list
```

## Install Flux

Add the fluxcd helm repository:

```
helm repo add fluxcd https://charts.fluxcd.io
```

### Install the HelmRelease CRD

```
kubectl apply -f https://raw.githubusercontent.com/fluxcd/helm-operator/master/deploy/flux-helm-release-crd.yaml
```

### Install Flux
```
export TILLER_NAMESPACE=kube-system

export FLUX_FORWARD_NAMESPACE=flux

helm install --name flux \
--set rbac.create=true \
--set git.url=git@github.com:mfamador/data-pipeline-gitops.git \
--set git.branch=master \
--set git.path=releases \
--namespace flux fluxcd/flux 

fluxctl identity --k8s-fwd-ns flux
```

### Create a deploy key in the github gitops repository with write permissions

    Settings -> Deploy keys -> Add deploy key -> check write permission checkbox

### Install Flux Helm Operator
```
helm install --name helm-operator \
--set git.ssh.secretName=flux-git-deploy \
--set workers=4 \
--namespace flux fluxcd/helm-operator 
```

### Updating only a few parameters

If we need to change just a few parameters:

```
helm upgrade --reuse-values flux \
--set git.path="releases/development\,releases/common/" \
--set git.branch=master \
fluxcd/flux

helm upgrade --reuse-values helm-operator \
--set workers=4 \
fluxcd/helm-operator 
```

### Monitor cluster

A really useful tools to monitor our workloads running on k8s
```
brew install derailed/k9s/k9s
brew install kubectx (installs both kubectx and kubens)
```

### Test

```
curl -H "host:echo.domain.com" http://localhost:8080/
```

or if you added echo.domain.com to /etc/hosts
```
curl http://echo.domain.com:8080
```

## Monitoring

### Prometheus

```
kubectl port-forward svc/prometheus-operator-prometheus -n monitoring 9090:9090
```

```
open http://localhost:9090
```

or using the ingress if you added prometheus.domain.com to /etc/hosts
```
open http://prometheus.domain.com:8080
```

### Grafana

Username `admin` and password is store in a secret base64 encoded
```
kubectl get secret prometheus-operator-grafana -o yaml -n monitoring

echo <ADMIN-PASSWORD> | base64 --decode
```

```
kubectl port-forward svc/prometheus-operator-grafana -n monitoring 8880:80
```

```
open http://localhost:8880
```
or using the ingress if you added grafana.domain.com to /etc/hosts
```
open http://grafana.domain.com:8080
```

## Logging

### Elasticsearch

```
kubectl port-forward svc/elasticsearch-master -n logging 9200:9200
```

```
> curl http://localhost:9200
{
  "name" : "elasticsearch-master-0",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "_na_",
  "version" : {
    "number" : "7.5.2",
    "build_flavor" : "default",
    "build_type" : "docker",
    "build_hash" : "8bec50e1e0ad29dad5653712cf3bb580cd1afcdf",
    "build_date" : "2020-01-15T12:11:52.313576Z",
    "build_snapshot" : false,
    "lucene_version" : "8.3.0",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}

> curl localhost:9200/_cat/indices/
green open foo-far-2020.02.01

```

or using the ingress if you added elasticsearch.domain.com to /etc/hosts
```
curl http://elasticsearch.domain.com:8080
```

### Kibana

```
kubectl port-forward svc/kibana-kibana -n logging 8088:5601
```

```
open http://localhost:8088
```

or using the ingress if you added kibana.domain.com to /etc/hosts
```
open http://kibana.domain.com:8080
```

Create some index patterns on Kibana. Logs should be already showing up.


## Message Broker

### Kafka

### Metrics

    Kafka Minion
      

## Data Pipeline

### HTTP Ingestor
    
    HTTP -> Kafka

### Kafka to Storage

    Kafka -> Storage
    

## Custom metrics

### Consumer group offset lag


## Autoscale Kafka to Storage



