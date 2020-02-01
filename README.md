# Auto Scalable Data Pipeline
A GitOps repository for an auto-scalable data pipeline

## Create a local Kubernetes cluster

### Create a multi-node k3s cluster with k3d

Install k3d
```
brea install k3d
```

Create a k8s cluster with 2 node and expose 8080 for Traefik ingress controller
```
k3d create --publish 8080:80 --workers 2
export KUBECONFIG="$(k3d get-kubeconfig --name='k3s-default')"
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
--set git.url=git@github.com:mfamador/data-pipeline-gitops.git \
--set git.path=releases \
--set git.branch=master \
fluxcd/flux

helm upgrade --reuse-values helm-operator \
--set workers=4 \
fluxcd/helm-operator 
```

### Monitor cluster

A really nice tools to monitor our workloads running on k8s
```
brew install derailed/k9s/k9s
```

### Test

```
curl -H "host:echo.domain.com" http://localhost:8080/
```
