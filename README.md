# CS1660 WordPress Deployment on Local Kubernetes Cluster using KinD

In this assignment, you will deploy a WordPress application on a local Kubernetes cluster using KinD (Kubernetes in Docker). KinD is a tool for running local Kubernetes clusters using Docker container nodes.

## Prerequisites

Before you begin, make sure you have the following prerequisites set up on your system:

1. [Docker](https://www.docker.com/get-started) installed.
2. [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) installed.
3. [KinD](https://kind.sigs.k8s.io/docs/user/quick-start/) (Kubernetes in Docker) installed.

## Getting Started

You will need to create a Kubernetes cluster using KinD. The cluster configuration is defined in the `kind-config.yaml` file. You can create the cluster by running the following command:


Follow these steps to deploy WordPress on your local Kubernetes cluster:

### Step 1: Create a KinD Cluster

Create a KinD cluster by running the following command:

```bash
kind create cluster --name cs1660 --config kind-cluster.yaml

# set you kubectl context
kubectl config set-context kind-cs1660


# verify you can talk to the new cluster
kubectl get namespace
```

### Step 2: Install Nginx Ingress Controller 
Install the Nginx Ingress Controller and set up an Ingress by running the following command:

We need the [ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) controller to route traffic to our wordpress service.  The ingress controller is a pod that runs in the cluster and watches for ingress resources.  When it sees an ingress resource, it will configure the nginx reverse proxy to route traffic to the appropriate service.
```bash
# install the nginx ingress controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# install the ingress resource
kubectl apply -f ./config/ingress.yaml
```

### Step 3: Create a Namespace Database Password Secret:
Run the following command to create a namespace for the WordPress application:

```bash
kubectl create namespace wordpress

# verify the namespace was created
kubectl get namespaces
```

To secure the MySQL database, create a secret to store the database password:

```bash
kubectl create secret generic mysql-pass --from-literal=password=YOUR_PASSWORD --namespace wordpress

# verify the secret was created
kubectl get secrets --namespace wordpress
```

Replace `YOUR_PASSWORD` with your desired MySQL root password.

### Step 3: Deploy MySQL for WordPress

Your task is to update the Kubernetes manifests for deploying a MySQL database for the WordPress application. Ensure that your MySQL deployment meets the following criteria:

- Run the MySQL deployment in the `wordpress` namespace.
  - Hint: Use the `namespace` field in the manifest.
- Set the `MYSQL_ROOT_PASSWORD` root password and `MYSQL_PASSWORD` securely from the same **Kubernetes Secret** you created in step 3.
  - Hint: Use the `valueFrom` [field](https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/#define-container-environment-variables-using-secret-data) in the `env` section of the deployment.
- Define appropriate resource requests and limits.
  - please request `250Mi` memory and `200m` CPU
- Create a PersistentVolumeClaim named `mysql-pv-claim` that is 5Gi, in `ReadWriteOnce` mode.
  - Hint: create a `persistentvolumeclaims` [object](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#persistentvolumeclaims).
- Mount the PersistentVolumeClaim to the `/var/lib/mysql` directory in the MySQL container on the deployment object like [this](https://akomljen.com/kubernetes-persistent-volumes-with-deployment-and-statefulset/).
  - Hint: Use the `volumeMounts` [field](https://kubernetes.io/docs/tasks/configure-pod-container/configure-volume-storage/#create-a-pod-that-uses-a-persistentvolumeclaim) in the deployment.
- Create matchSelector labels `app: wordpress` and `tier: mysql` for the MySQL deployment.
  - Hint: Use the `matchLabels` [field](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors) in the deployment.
- Create pod template labels `app: wordpress` and `tier: mysql` for the MySQL deployment.
  - Hint: Use the `labels` [field](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors) in the deployment.

Verify that the MySQL deployment is running by running the following command:

```bash
# all the pods should be `Healthy` status
kubectl get pods -n wordpress

# use the describe command to see events for troubleshooting
kubectl describe pod <pod-name> -n wordpress
```

### Step 4: Deploy WordPress

Your task is to create the Kubernetes manifests for deploying the WordPress application. Ensure that your WordPress deployment meets the following criteria:

- Run the `Wordpress` deployment in the `wordpress` namespace.
  - Hint: Use the `namespace` field in the manifest.
- Define appropriate resource requests and limits.
  - please request `200Mi` memory and `100m` CPU
- Create a PersistentVolumeClaim named `wp-pv-claim` that is 5Gi, in `ReadWriteOnce` mode.
  - Hint: create a `persistentvolumeclaims` [object](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#persistentvolumeclaims).
- Mount the PersistentVolumeClaim to the `/var/www/html` directory in the Wordpress container on the deployment object like [this](https://akomljen.com/kubernetes-persistent-volumes-with-deployment-and-statefulset/).
  - Hint: Use the `volumeMounts` [field](https://kubernetes.io/docs/tasks/configure-pod-container/configure-volume-storage/#create-a-pod-that-uses-a-persistentvolumeclaim) in the deployment.
- Create matchSelector labels `app: wordpress` and `tier: frontend` for the MySQL deployment.
  - Hint: Use the `matchLabels` [field](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors) in the deployment.
- Create pod template labels `app: wordpress` and `tier: frontend` for the MySQL deployment.
  - Hint: Use the `labels` [field](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors) in the deployment.

Verify that the WordPress deployment is running by running the following command:

```bash
# all the pods should be `Healthy` status
kubectl get pods -n wordpress

# use the describe command to see events for troubleshooting
kubectl describe pod <pod-name> -n wordpress
```

### Step 5: Access the WordPress Application

Now, open your web browser and go to [http://localhost:80](http://localhost:80) to access your WordPress site. 

Or you can port-forwarding to a local port to the wordpress service:

```bash
kubectl port-forward service/wordpress -n wp 8080:80

# now you can access the wordpress site at http://localhost:8080 in you browser
```

## Submission
Please push up all of your changes to the main branch of your project, and submit the link to your GitHub repository in Canvas.

## Cleanup

To clean up the resources and delete the KinD cluster, run the following command:

```bash
kind delete cluster --name wp-cluster
```

This will remove the KinD cluster and all associated resources.

## Conclusion

You have successfully completed the assignment to deploy a WordPress site on a local Kubernetes cluster using KinD. This assignment has provided hands-on experience with Kubernetes and containerization, which are essential skills for cloud computing and software engineering professionals.
