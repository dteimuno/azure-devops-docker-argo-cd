az login
#Update kubeconfig with eks
az aks get-credentials --resource-group dtmgroup --name akscluster --overwrite-existing
#verify nodes
kubectl get nodes
