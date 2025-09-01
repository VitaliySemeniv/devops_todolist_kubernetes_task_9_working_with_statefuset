# Validation

## Namespaces
kubectl get ns mysql
kubectl get ns todo

## Headless Service
kubectl -n mysql get svc mysql -o jsonpath='{.spec.clusterIP}'; echo   # має бути порожньо
kubectl -n mysql get svc mysql -o yaml | grep 'clusterIP: None'

## StatefulSet 3/3 Ready
kubectl -n mysql rollout status sts/mysql
kubectl -n mysql get sts mysql -o jsonpath='{.status.readyReplicas}'; echo  # 3

## PVC
kubectl -n mysql get pvc

## init.sql змонтований
kubectl -n mysql exec mysql-0 -- ls /docker-entrypoint-initdb.d

## Проби / ресурси
kubectl -n mysql get pod mysql-0 -o yaml | grep -A4 readinessProbe
kubectl -n mysql get pod mysql-0 -o yaml | grep -A4 livenessProbe
kubectl -n mysql get sts mysql -o yaml | grep -A6 'resources:'

## DNS pod
kubectl -n mysql exec -it mysql-0 -- getent hosts mysql-0.mysql

## App
kubectl -n todo describe deploy todo-app | egrep 'DB_NAME|DB_USER|DB_HOST'
kubectl -n todo port-forward svc/todo-svc 8080:80 &
sleep 2
curl -sf http://localhost:8080/health
