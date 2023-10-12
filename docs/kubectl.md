# 🧂 `kubectl` – The Chef’s Knife of Kubernetes

In the world of Kubernetes, **you are the chef**, and your most important tool is the **knife** — `kubectl`. It lets you slice, dice, inspect, and serve everything in your cluster. Whether you're deploying apps, troubleshooting issues, or peeking inside your containers, `kubectl` is the way to get it done.

This guide gives you a quick overview of the most useful `kubectl` commands to help you become a confident Kubernetes chef 🍳.

You can always find what you are looking for in the [kubectl command docs](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands) 

Check out the official documentation here:  
👉 https://kubernetes.io/docs/reference/kubectl

---

## 🔧 Basic CRUD Operations

### `kubectl apply`
Apply or update a resource using a YAML manifest.

```bash
kubectl apply -f config/
kubectl apply -f config/my-deployment.yaml
```

Think of this as your “cooking instructions” — you're telling Kubernetes what recipe to follow.

---

### `kubectl delete`
Remove a resource from the cluster.

```bash
kubectl delete -f config/my-deployment.yaml
kubectl delete pod my-pod-name
```

Sometimes, a dish doesn’t work out — don’t be afraid to toss it and start over.

---

### `kubectl get`
List resources in your cluster.

```bash
kubectl get pods
kubectl get pods some-pod-name-xxss-zz
kubectl get deployments
kubectl get deployment some-app
kubectl get services
kubectl get services some-service
```

Add `-o wide` for more detail:

```bash
kubectl get pods -o wide
```

Or you can watch every event with the `-w` flag
```bash
kubectl get pods -w 
```

---

### `kubectl describe`
View detailed information about a specific resource.

```bash
kubectl describe pod my-pod-name
kubectl describe service wordpress
```

This is like reading the label on an ingredient — you’ll see events, labels, image info, and more.

---

### `kubectl logs`
See the logs from a container (useful for debugging).

```bash
kubectl logs my-pod-name
```

If your pod has multiple containers:

```bash
kubectl logs my-pod-name -c container-name
```

---

### `kubectl exec`
Run a command inside a container (like SSH for containers or docker exec).

```bash
kubectl exec -it my-pod-name -- /bin/bash
```

Useful when you need to poke around and inspect a running container directly.

---

### `kubectl port-forward`
Access a service or pod locally by forwarding a port.

```bash
kubectl port-forward service/wordpress 8080:80
```

Visit `http://localhost:8080` to reach your app.

You can also port-foward directly to a pod

```bash
kubectl port-forward pod/wordpress-xxzzsss 8080:8000
```
---

## There's More!

`kubectl` is incredibly powerful — more than can fit in one README. It supports:

- Label and annotation management
- Resource editing (`kubectl edit`)
- Live diffing (`kubectl diff`)
- Kustomize support (`kubectl apply -k`)
- And much more!

Check out the official documentation here:  
👉 https://kubernetes.io/docs/reference/kubectl/
