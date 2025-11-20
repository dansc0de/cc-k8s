# troubleshooting guide

## testing locally

### initial setup

```bash
# start minikube cluster
minikube start

# verify cluster is running
minikube status
kubectl cluster-info
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
- no storage class available (minikube provides one by default)
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

---

## iterative development workflow

1. **make changes** to manifest files
2. **apply changes**: `kubectl apply -f manifests/`
3. **check status**: `kubectl get pods -w`
4. **debug if needed**: `kubectl logs` and `kubectl describe`
5. **run validation**: `./check.sh`
6. **repeat** until all checks pass

---

## general debugging workflow

1. **check resource exists**: `kubectl get <resource-type>`
2. **check resource details**: `kubectl describe <resource-type> <name>`
3. **check logs**: `kubectl logs <pod-name>`
4. **check events**: `kubectl get events --sort-by='.lastTimestamp'`
5. **verify labels match**: ensure service selectors match deployment pod labels
6. **test connectivity**: use `kubectl exec` to test connections from inside pods
