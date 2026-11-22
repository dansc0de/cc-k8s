# troubleshooting guide

## testing locally

### initial setup

```bash
# make sure docker is running
docker info

# create a kind cluster
kind create cluster --name wordpress --config kind.yaml

# verify cluster is running
kind get clusters
kubectl cluster-info --context kind-wordpress
```

### deploy your manifests

```bash
# apply all manifests from the manifests directory
kubectl apply -f manifests/

# wait for deployments to be ready
kubectl wait --for=condition=available --timeout=120s deployment/wordpress
kubectl wait --for=condition=available --timeout=120s deployment/wordpress-mysql
```

### run validation script

```bash
# run the check script to validate your setup
./check.sh
```

the check script validates:
- deployments and services exist
- pvcs are created
- configmaps have correct keys
- secret has correct keys
- wordpress responds with http 200

### manual testing

```bash
# port-forward to access wordpress locally
kubectl port-forward svc/wordpress 8080:80

# in another terminal or browser, visit:
# http://localhost:8080
```

you should see the wordpress setup page if everything is configured correctly.

---

## common errors and solutions

### kind cluster won't create

**symptoms:**
- `kind create cluster` fails or hangs
- `Cannot connect to the Docker daemon`

**debug steps:**
```bash
# is docker running?
docker info

# see leftover clusters/containers
kind get clusters
docker ps -a

# clean up and retry
kind delete cluster --name wordpress
kind create cluster --name wordpress --config kind.yaml

# export logs for inspection
kind export logs --name wordpress ./kind-logs
```

**common causes:**
- docker not running, or your user lacks permission to use it
- a cluster with the same name already exists
- not enough cpu/memory/disk allocated to docker

---

### kubectl talks to the wrong cluster

**symptoms:**
- `kubectl get nodes` shows nothing from kind, or connection refused

**fix:**
```bash
kubectl config get-contexts
kubectl config use-context kind-wordpress
```

---

### pods not starting

**symptoms:**
- `kubectl get pods` shows status: `Pending`, `CrashLoopBackOff`, or `ImagePullBackOff`

**debug steps:**
```bash
# check pod details
kubectl describe pod <pod-name>

# check pod logs
kubectl logs <pod-name>

# check events
kubectl get events --sort-by='.lastTimestamp'
```

**common causes:**
- missing or incorrect selector labels in deployment
- pvc not bound to a pv
- image name misspelled or unavailable
- insufficient resources in cluster

---

### connection refused errors

**symptoms:**
- wordpress logs show "error establishing database connection"
- mysql connection timeouts

**debug steps:**
```bash
# verify mysql service exists and has correct selector
kubectl get svc wordpress-mysql -o yaml

# check if service endpoints are populated
kubectl get endpoints wordpress-mysql

# verify mysql pod is running
kubectl get pods -l tier=mysql
```

**common causes:**
- service selector labels don't match deployment pod labels
- mysql pod not ready yet (check with `kubectl get pods`)
- incorrect `WORDPRESS_DB_HOST` value in configmap (should be `wordpress-mysql`)

---

### environment variables not set

**symptoms:**
- pods crash immediately after starting
- logs show missing environment variables

**debug steps:**
```bash
# check environment variables inside running container
kubectl exec deployment/wordpress -- env | grep WORDPRESS
kubectl exec deployment/wordpress-mysql -- env | grep MYSQL
```

**common causes:**
- configmap or secret not referenced correctly in deployment
- wrong key names in `configMapKeyRef` or `secretKeyRef`
- configmap or secret doesn't exist (check with `kubectl get configmap` and `kubectl get secret`)

---

### persistent volume issues

**symptoms:**
- pvc status shows `Pending`
- data not persisting between pod restarts

**debug steps:**
```bash
# check pvc status
kubectl get pvc

# check pvc details
kubectl describe pvc <pvc-name>
```

**common causes:**
- no storage class available (kind provides a `standard` one by default; check with `kubectl get storageclass`)
- pvc name in deployment doesn't match the actual pvc name
- volume not mounted at correct path in container spec

---

### port-forward not working

**symptoms:**
- `kubectl port-forward` command hangs or fails
- cannot access wordpress at localhost:8080

**debug steps:**
```bash
# check if service exists
kubectl get svc wordpress

# verify service has endpoints
kubectl get endpoints wordpress

# try port-forwarding directly to pod
kubectl get pods -l tier=frontend
kubectl port-forward pod/<pod-name> 8080:80
```

**common causes:**
- service selector doesn't match pod labels
- pods not in ready state
- firewall blocking local port 8080

---

### check.sh validation failures

**symptoms:**
- automated check script fails

**debug steps:**
```bash
# run check.sh to see which validation fails
./check.sh

# verify all required resources exist
kubectl get deployments
kubectl get services
kubectl get pvc
kubectl get configmap
kubectl get secret
```

**common causes:**
- resource names don't match expected names exactly
- configmap or secret missing required keys
- wordpress not returning http 200 (usually means pods not ready or connection issues)

