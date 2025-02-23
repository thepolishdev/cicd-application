#!/bin/bash

eval $(minikube docker-env)
VERSION=$(./gradlew properties -q | grep "version:" | awk '{print $2}')
./gradlew clean build
docker build --build-arg VERSION=$VERSION -t cicd-application:$VERSION .

# Export VERSION for envsubst
export VERSION

# Apply Kubernetes configurations with version substitution
envsubst < kubernetes/deployment.yaml | kubectl apply -f -
kubectl apply -f kubernetes/service.yaml

echo "Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=60s deployment/cicd-application

# Get the service URL
echo "Application URL:"
minikube service cicd-application --url

# Show pod status
echo -e "\nPod status:"
kubectl get pods -l app=cicd-application 