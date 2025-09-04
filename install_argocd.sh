#!/bin/bash

# Step 1: Install Argo CD
echo "Installing Argo CD..."

# Create a namespace for Argo CD
kubectl create namespace argocd

# Install Argo CD in the argocd namespace
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Step 2: Wait for all Argo CD components to be up and running
echo "Waiting for Argo CD components to be ready..."
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=600s

# Step 3: Get the initial admin password
echo "Retrieving the Argo CD initial admin password..."
ARGOCD_INITIAL_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "Argo CD initial admin password: $ARGOCD_INITIAL_PASSWORD"

# Step 4: Access the Argo CD server
echo "Exposing Argo CD server via NodePort..."
kubectl -n argocd patch svc argocd-server -p '{"spec": {"type": "NodePort"}}'

# Retrieve the Argo CD server URL
ARGOCD_SERVER=$(kubectl -n argocd get svc argocd-server -o jsonpath='{.spec.clusterIP}')
ARGOCD_PORT=$(kubectl -n argocd get svc argocd-server -o jsonpath='{.spec.ports[0].nodePort}')
echo "You can access the Argo CD server at http://$ARGOCD_SERVER:$ARGOCD_PORT"

# Step 5: Login to Argo CD CLI (Optional)
echo "Installing Argo CD CLI..."
sudo curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo chmod +x /usr/local/bin/argocd

echo "Logging into Argo CD CLI..."
argocd login $ARGOCD_SERVER:$ARGOCD_PORT --username admin --password $ARGOCD_INITIAL_PASSWORD --insecure

echo "Argo CD installation and setup complete!"
