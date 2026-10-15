#!/usr/bin/env bash
set -euo pipefail

# Run from the repository root. Requires Docker, kind, kubectl, and Helm.
if ! kind get clusters | grep -qx 'task11'; then
  kind create cluster --name task11 --config cluster.yml
fi

kubectl config use-context kind-task11

kubectl cluster-info
kubectl get nodes --show-labels
kubectl get nodes -o custom-columns=NAME:.metadata.name,LABELS:.metadata.labels,TAINTS:.spec.taints

# Taint every node labelled app=mysql. Nodes must already have this label.
while IFS= read -r node; do
  [ -n "$node" ] || continue
  kubectl taint nodes "$node" app=mysql:NoSchedule --overwrite
done < <(kubectl get nodes -l app=mysql -o name | sed 's#node/##')

helm dependency update ./helm-chart/todoapp
helm upgrade --install todoapp ./helm-chart/todoapp \
  --namespace todoapp \
  --create-namespace \
  --wait \
  --timeout 10m

kubectl get all,cm,secret,ing -A > output.log
echo "Deployment complete. Resource inventory saved to output.log"
