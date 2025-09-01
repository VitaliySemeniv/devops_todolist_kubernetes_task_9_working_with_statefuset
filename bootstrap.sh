#!/usr/bin/env bash
set -euo pipefail

# 1) Кластер
kind create cluster --config .infrastructure/cluster.yml || true

# 2) Namespace-и
kubectl apply -f .infrastructure/namespace.yml

# 3) MySQL: secrets + configmap + headless svc + statefulset
kubectl apply -f .infrastructure/secret.yml           # створить і mysql-auth, і app-db
kubectl apply -f .infrastructure/configMap.yml
kubectl apply -f .infrastructure/headless-svc.yml
kubectl apply -f .infrastructure/statefulset.yml
kubectl -n mysql rollout status statefulset/mysql --timeout=180s

# 4) App: deployment + service
kubectl apply -f .infrastructure/deployment.yml
kubectl apply -f .infrastructure/nodeport.yml
kubectl -n todo rollout status deployment/todo-app --timeout=180s

# 5) Вивід статусу
kubectl -n mysql get sts,po,svc,pvc
kubectl -n todo  get deploy,po,svc
echo "Open http://localhost:30080"
