# Getting Started with Minikube

[Minikube](https://minikube.sigs.k8s.io/) is a tool that makes it easy to run a local Kubernetes cluster on your machine. It is especially useful for learning, testing, and developing Kubernetes applications in a self-contained environment.

This guide provides a quick overview of what Minikube is and how to use it effectively during your assignments.

---

## 💡 What is Minikube?

Minikube runs a single-node Kubernetes cluster inside a virtual machine or container on your local computer. It includes everything you need to deploy applications and simulate how they would run in a full Kubernetes environment.

---

## Basic Commands

### Start Minikube

Start a local cluster:

```bash
 minikube start
```

> This will create and configure a Kubernetes cluster and set your `kubectl` context to point to it.

---

### Deploy Your App

Once started, you can use `kubectl` to interact with the cluster:

```bash
kubectl apply -f config/
```

---

### Check Cluster Status

```bash
minikube status
```

---

### Access Services

You can expose services running in Minikube using:

```bash
minikube service <service-name>
```

This will open the service in your browser or show the local URL.

---

### Stop the Cluster

Stop the running cluster without deleting it:

```bash
minikube stop
```

This keeps your cluster and workloads, but powers everything down.

---

### Delete the Cluster

Completely remove the Minikube cluster:

```bash
minikube delete
```

This deletes all workloads, configurations, and the VM/container hosting the cluster.

---

## Notes

- Minikube supports multiple drivers (Docker, VirtualBox, etc.). We recommend using the **Docker driver**:

  ```bash
  minikube start --driver=docker
  ```

- If your `kubectl` commands don’t seem to work, make sure your context is set:

  ```bash
  kubectl config use-context minikube
  ```
  
- You can get your minikube's local IP with 

    ```bash
    minikube ip
    ```
  