## Prometheus and Grafana

To install Prometheus and Grafana on your cluster using Terraform and Helm, follow the instructions in the article [here](https://medium.com/@CloudTopG/how-to-install-prometheus-and-grafana-on-your-cluster-using-terraform-and-helm-f74c3dff3c).

1. Edit the Prometheus Grafana service:
```bash
   kubectl edit svc prometheus-grafana -n prometheus
```
2. Edit the Prometheus service: **Note the dns record:9090** 

```bash
kubectl edit svc prometheus-kube-prometheus-prometheus -n prometheus
```
3. Scroll down to the point where you see type: ClusterIP and change it to:

 ```bash
 LoadBalancer
 ```

## ArgoCD

1. Edit the ArgoCD server service:

 ```bash
 kubectl edit svc/argocd-server -n argocd
 ```
2. Change the service type to LoadBalancer.

3. Retrieve the initial admin password:

 ```bash
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d; echo
 ```
4. Patch the ArgoCD server service to change its type:

 ```bash
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
 ```

5. to use the argocd-rollout
 ```bash
k get svc -n argo-rollouts
 ```

use the url with the port 3100