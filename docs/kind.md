# Getting Started with kind (Kubernetes in Docker)

[kind](https://kind.sigs.k8s.io/) runs a local Kubernetes cluster using Docker containers as "nodes". It is lightweight, fast to create and destroy, and is the same tool many projects use to test Kubernetes in CI.

This guide gives a quick overview of what kind is and how to use it during this assignment.

---

## 💡 What is kind?

kind (**K**ubernetes **in** **D**ocker) starts a Docker container that runs a full Kubernetes control plane (and workloads). There is no VM involved, so **Docker must be installed and running** before you create a cluster.

---

## Install

Install kind by following the official guide for your operating system (Windows, macOS, and Linux are all covered):

👉 https://kind.sigs.k8s.io/docs/user/quick-start/#installation

On Windows, you will also need [Docker Desktop](https://docs.docker.com/desktop/setup/install/windows-install/) running. Verify the install with `kind version`.

---

## Basic Commands

### Create a Cluster

This repo includes a [`kind.yaml`](../kind.yaml) config that creates a 3-node cluster (1 control-plane + 2 workers) running Kubernetes v1.37. Run this from the root of the repo:

```bash
kind create cluster --name wordpress --config kind.yaml
```

> This creates the cluster and sets your `kubectl` context to `kind-wordpress`. It takes a minute or two since three containers are started.

Confirm all three nodes are `Ready`:

```bash
kubectl get nodes
```

You should see one `control-plane` node and two worker nodes. To see which nodes your WordPress pods land on, run `kubectl get pods -o wide`.

---

### Deploy Your App

Once the cluster is up, use `kubectl` to interact with it:

```bash
kubectl apply -f manifests/
```

---

### Check Cluster Status

```bash
kind get clusters
kubectl cluster-info --context kind-wordpress
kubectl get nodes
```

You can also see the "node" as a regular Docker container:

```bash
docker ps
```

---

### Access Services

kind does not expose services on your host automatically. Use port-forwarding:

```bash
kubectl port-forward svc/wordpress 8080:80
```

Then open [http://localhost:8080](http://localhost:8080).

---

### Delete the Cluster

Completely remove the cluster and everything in it:

```bash
kind delete cluster --name wordpress
```

kind has no stop/start command. Deleting removes all workloads and data, so you will need to re-apply your manifests after creating a new cluster. (Restarting Docker or your machine normally keeps the cluster.)

---

## Notes

- If your `kubectl` commands don't seem to work, make sure your context is set:

  ```bash
  kubectl config use-context kind-wordpress
  ```

- kind includes a default `standard` StorageClass (local-path provisioner), so your PVCs will bind without extra setup. Note that PVCs only bind once a pod using them is scheduled.

- The kind node runs inside a Docker container, so its IP isn't reachable from your host. This assignment doesn't set up an ingress, so use `kubectl port-forward` to reach WordPress. It forwards a port on your machine (`8080`) to the `wordpress` service inside the cluster (port `80`):

  ```bash
  kubectl port-forward svc/wordpress 8080:80
  ```

  Leave the command running, then open [http://localhost:8080](http://localhost:8080). Press `Ctrl+C` to stop forwarding.
