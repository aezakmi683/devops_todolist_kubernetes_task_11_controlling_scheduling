\# Task 11: Controlling Scheduling in Kubernetes



\## Overview



This task demonstrates Kubernetes scheduling using node labels, taints, tolerations, node affinity, and pod anti-affinity.



The cluster runs a MySQL StatefulSet and a ToDo application Deployment. MySQL pods are scheduled only on nodes labeled `app=mysql`. The ToDo application prefers nodes labeled `app=todoapp`.



\## Prerequisites



\* Docker

\* Kind

\* kubectl

\* Git Bash or WSL to execute `bootstrap.sh`



\## 1. Create the Kind cluster



From the project root, create the cluster using the provided configuration:



```bash

kind create cluster --name task11 --config cluster.yml

```



Set the current context:



```bash

kubectl config use-context kind-task11

```



Check the cluster nodes and labels:



```bash

kubectl get nodes --show-labels

kubectl get nodes -L app

```



The cluster configuration defines nodes labeled `app=mysql` and `app=todoapp`.



\## 2. Configure MySQL node taints



Apply the `NoSchedule` taint to nodes labeled `app=mysql`:



```bash

kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite

```



Verify the taints:



```bash

kubectl describe nodes

```



MySQL pods tolerate this taint and use required node affinity to select nodes labeled `app=mysql`.



\## 3. Deploy the resources



Run the bootstrap script from the project root:



```bash

bash ./bootstrap.sh

```



The script applies the MySQL and ToDo application resources and configures the MySQL node taints.



\## 4. Verify the MySQL StatefulSet



Check the StatefulSet and pods:



```bash

kubectl get statefulset -n mysql

kubectl get pods -n mysql -o wide

```



Expected result: two MySQL replicas are ready and running on separate nodes labeled `app=mysql`.



Inspect the scheduling configuration:



```bash

kubectl get statefulset mysql -n mysql -o yaml

```



Verify that the pod template contains:



\* A toleration for `app=mysql:NoSchedule`.

\* Required node affinity for `app=mysql`.

\* Required pod anti-affinity using `kubernetes.io/hostname`.



\## 5. Verify the ToDo application Deployment



Check the Deployment and pods:



```bash

kubectl get deployment -n todoapp

kubectl get pods -n todoapp -o wide

```



Expected result: two application replicas are ready and running on separate nodes.



Inspect the scheduling configuration:



```bash

kubectl get deployment todoapp -n todoapp -o yaml

```



Verify that the pod template contains:



\* Preferred node affinity for `app=todoapp` using `preferredDuringSchedulingIgnoredDuringExecution`.

\* Required pod anti-affinity using `kubernetes.io/hostname`.



\## 6. Verify node labels and taints



```bash

kubectl get nodes -L app

kubectl get nodes -o custom-columns="NODE:.metadata.name,TAINTS:.spec.taints"

```



Confirm that MySQL pods run on nodes labeled `app=mysql` and application pods prefer nodes labeled `app=todoapp`.



\## 7. Check resource health



```bash

kubectl get pods -A

kubectl get pvc -A

kubectl get events -A --sort-by=.lastTimestamp

```



All expected pods should be running and ready, and required PersistentVolumeClaims should be bound.



\## 8. Cleanup



To remove the test cluster after validation:



```bash

kind delete cluster --name task11

```



\*\*Note:\*\* Cleanup deletes the cluster and its workloads. Do not run this command while you still need the cluster for testing.



