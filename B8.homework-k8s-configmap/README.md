Create config map command

kubectl create configmap configmap-command --from-literal=DATABASE_USER=user --from-literal=DATABASE_PASSWORD=password --from-literal=TYPE=command -n test

Create config map from file

kubectl create configmap configmap-json --from-file=configmap.json -n test
