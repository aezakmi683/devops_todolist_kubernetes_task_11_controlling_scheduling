# INSTRUCTION.md

## Prerequisites
Install Docker Desktop, kind, kubectl, and Helm. Run all commands from the repository root.

## 1. Create or verify the kind cluster
```powershell
kind create cluster --config .\cluster.yml
kubectl get nodes
```
If the cluster already exists, skip cluster creation.

## 2. Inspect node labels and taints
```powershell
kubectl get nodes --show-labels
kubectl get nodes -o custom-columns="NAME:.metadata.name,LABELS:.metadata.labels,TAINTS:.spec.taints"
```

Taint nodes carrying the `app=mysql` label:
```powershell
kubectl get nodes -l app=mysql
kubectl get nodes -l app=mysql -o name | ForEach-Object {
  kubectl taint $_ app=mysql:NoSchedule --overwrite
}
```
If no nodes have that label, label the intended MySQL worker node first, for example:
```powershell
kubectl label node <NODE_NAME> app=mysql --overwrite
kubectl taint node <NODE_NAME> app=mysql:NoSchedule --overwrite
```

## 3. Build chart dependencies and deploy
```powershell
helm dependency update .\helm-chart\todoapp
helm lint .\helm-chart\todoapp
helm template todoapp .\helm-chart\todoapp
helm upgrade --install todoapp .\helm-chart\todoapp --namespace todoapp --create-namespace --wait --timeout 10m
```

## 4. Validate the resources
```powershell
kubectl get all,cm,secret,ing -A
kubectl get pods -A -o wide
kubectl get statefulset -n mysql
kubectl get deployment -n todoapp
kubectl get hpa -n todoapp
kubectl get pvc -A
```

## 5. Generate the required inventory
```powershell
kubectl get all,cm,secret,ing -A > output.log
```
Review `output.log` before committing. Do not put real credentials or decoded Secret values in the log.

## 6. Validate chart values
Change configuration in `helm-chart/todoapp/values.yaml` and `helm-chart/todoapp/charts/mysql/values.yaml`, then run `helm upgrade --install` again to verify the chart uses the configured values.
