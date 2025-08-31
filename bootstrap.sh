#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="todo-k8s"

echo "[1/6] Create kind cluster"
kind create cluster --config cluster.yml || true

echo "[2/6] Deploy MySQL namespace, secrets, config, svc, statefulset"
kubectl apply -f k8s/mysql/namespace.yaml
kubectl apply -f k8s/mysql/secret.yaml
kubectl apply -f k8s/mysql/init-sql-configmap.yaml
kubectl apply -f k8s/mysql/headless-svc.yaml
kubectl apply -f k8s/mysql/statefulSet.yml

echo "[3/6] Wait for mysql-0 ready"
kubectl -n mysql rollout status statefulset/mysql --timeout=180s

echo "[4/6] Deploy ToDo app namespace + secrets + deployment + svc"
kubectl apply -f k8s/app/namespace.yaml || true
kubectl apply -f k8s/app/db-secret.yaml
kubectl apply -f k8s/app/deployment.yaml
kubectl apply -f k8s/app/service.yaml

echo "[5/6] Wait for todo-app ready"
kubectl -n todo rollout status deployment/todo-app --timeout=180s

echo "[6/6] Show endpoints"
echo "MySQL pods:"
kubectl -n mysql get pods -o wide
echo "App service:"
kubectl -n todo get svc todo-svc

echo "Open http://localhost:30080 (NodePort) or:"
echo "kubectl -n todo port-forward svc/todo-svc 8080:80"
