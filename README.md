# WordPress Deployment on Local Kubernetes Cluster using KinD

In this assignment, you will deploy a WordPress application on a local Kubernetes cluster using KinD (Kubernetes in Docker). KinD is a tool for running local Kubernetes clusters using Docker container nodes.

**PLEASE READ** - all changes must be included in manifest files in the config directory. Otherwise I cannot properly grade your submission.

## Prerequisites

Before you begin, make sure you have the following prerequisites set up on your system:

1. [Docker](https://www.docker.com/get-started) installed.
2. [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) installed.
3. [KinD](https://kind.sigs.k8s.io/docs/user/quick-start/) (Kubernetes in Docker) installed.

## Rubric

| **Criteria**                    | **Description**                                                                                      | **Points** |
|---------------------------------|-----------------------------------------------------------------------------------------------------|------------|
| **namespace.yaml**              | A properly configured `namespace.yaml` file that defines the `wordpress` namespace for the project. | 1          |
| **MySQL Deployment**            | A functional MySQL deployment with:                                                                 | 5          |
|                                 | - Resource requests: `64Mi` memory, `200m` CPU.                                                     |            |
|                                 | - PersistentVolumeClaim `mysql-pv-claim` (100Mi, `ReadWriteOnce`), mounted to `/var/lib/mysql`.      |            |
|                                 | - Proper matchSelector and pod template labels: `app: wordpress`, `tier: mysql`.                   |            |
| **WordPress Deployment**        | A functional WordPress deployment with:                                                             | 5          |
|                                 | - Resource requests: `200Mi` memory, `100m` CPU.                                                    |            |
|                                 | - PersistentVolumeClaim `wp-pv-claim` (1Gi, `ReadWriteOnce`), mounted to `/var/www/html`.           |            |
|                                 | - Proper matchSelector and pod template labels: `app: wordpress`, `tier: frontend`.                |            |
| **Overall Functionality**       | Successfully accessing the WordPress installation page via Ingress or port-forwarding.              | 2          |

**Total Points:** 13


## Getting Started

You will need to create a Kubernetes cluster using KinD. The cluster configuration is defined in the `kind-config.yaml` file. You can create the cluster by running the following command:


Follow these steps to create your local Kubernetes cluster and install nginx Ingress Controller:

### Step 1: Create a KinD Cluster

Create a KinD cluster by running the following command:

```bash
kind create cluster --name cloud --config kind-cluster.yaml

# set you kubectl context
kubectl config set-context cloud


# verify you can talk to the new cluster
kubectl get namespace
```
### Step 2: Create `Wordpress` Namespace
Create a namespace called `wordpress` in the cluster. The file should be named `namespace.yaml` and located in the `config` directory.

### Step 3: Install Nginx Ingress Controller 
Install the Nginx Ingress Controller and set up an Ingress by running the following command:

We need the [ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) controller to route traffic to our `wordpress` service.  The ingress controller is a deployment that runs in the cluster and watches for ingress resources.  When it sees an ingress resource, it will configure the nginx reverse proxy to route traffic to the appropriate service that matches the label selector of the workload.

```bash
# install the nginx ingress controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# install the ingress resource
kubectl apply -f ./config/ingress.yaml

# verify the ingress controller is running
kubectl get pods -n ingress-nginx
NAME                                        READY   STATUS      RESTARTS   AGE
ingress-nginx-admission-create-jgsmf        0/1     Completed   0          8m2s
ingress-nginx-admission-patch-fd4wg         0/1     Completed   1          8m2s
ingress-nginx-controller-7c94d9d5c5-dh9kg   1/1     Running     0          8m2s
```

### Step 4: Deploy MySQL for WordPress

Your task is to update the MySQL manifests in the [config](./config) directory. Ensure that your MySQL deployment meets the following criteria:

- Run the MySQL deployment in the `wordpress` namespace.
- Define the deployments resource requests and limits.
  - please request sixty-four megabytes (`64Mi`) of memory and two hundred millicores (`200m`) CPU
- Create a PersistentVolumeClaim named `mysql-pv-claim` that is 100Mi, in `ReadWriteOnce` mode.
  - Hint: create a `persistentvolumeclaims` [object](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#persistentvolumeclaims).
- Mount the PersistentVolumeClaim to the `/var/lib/mysql` directory in the MySQL container on the deployment object like [this](https://akomljen.com/kubernetes-persistent-volumes-with-deployment-and-statefulset/).
  - Hint: Use the `volumeMounts` [field](https://kubernetes.io/docs/tasks/configure-pod-container/configure-volume-storage/#create-a-pod-that-uses-a-persistentvolumeclaim) in the deployment.
- Create matchSelector labels `app: wordpress` and `tier: mysql` for the MySQL deployment.
  - Hint: Use the `matchLabels` [field](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors) in the deployment.
- Create pod template labels `app: wordpress` and `tier: mysql` for the MySQL deployment.
  - Hint: Use the `labels` [field](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors) in the deployment.

Create and Verify that the MySQL deployment is running by running the following command:

```bash
# create the mysql deployment
kubectl apply -f ./config/mysql-deployment.yaml

# all the pods should be `Healthy` status
kubectl get pods -n wordpress

# use the describe command to see events for troubleshooting
kubectl describe pod <pod-name> -n wordpress
```

### Step 5: Deploy WordPress App

Your task is to update the Wordpress manifests in the [config](./config) directory. Ensure that your Wordpress deployment meets the following criteria:

- Run the `Wordpress` deployment in the `wordpress` namespace.
- Define appropriate resource requests and limits.
  - please request two hundred megabytes (`200Mi`) memory and one hundred millicores (`100m`) of CPU
- Create a PersistentVolumeClaim named `wp-pv-claim` that is 1Gi, in `ReadWriteOnce` mode.
  - Hint: create a `persistentvolumeclaims` [object](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#persistentvolumeclaims).
- Mount the PersistentVolumeClaim to the `/var/www/html` directory in the Wordpress container on the deployment object like [this](https://akomljen.com/kubernetes-persistent-volumes-with-deployment-and-statefulset/).
  - Hint: Use the `volumeMounts` [field](https://kubernetes.io/docs/tasks/configure-pod-container/configure-volume-storage/#create-a-pod-that-uses-a-persistentvolumeclaim) in the deployment.
- Create matchSelector labels `app: wordpress` and `tier: frontend` for the MySQL deployment.
  - Hint: Use the `matchLabels` [field](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors) in the deployment.
- Create pod template labels `app: wordpress` and `tier: frontend` for the MySQL deployment.
  - Hint: Use the `labels` [field](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors) in the deployment.

Create and Verify that the WordPress deployment is running by running the following command:

```bash
# create the wordpress deployment
kubectl apply -f ./config/wp-deployment.yaml

# all the pods should be `Healthy` status
kubectl get pods -n wordpress

# use the describe command to see events for troubleshooting
kubectl describe pod <pod-name> -n wordpress
```

### Step 6: Access the WordPress Application

Now, open your web browser and go to [http://localhost:8080](http://localhost:8080) to access your WordPress site. 

Or you can port-forwarding to a local port to the wordpress service:

```bash
kubectl port-forward service/wordpress -n wp 8080:80

# now you can access the wordpress site at http://localhost:8080 in you browser
```

You should see the WordPress [installation page](wordpress.png)

## Submission
Please push up all of your changes to the main branch of your repository, and submit the link to your GitHub repository in Canvas.

## Cleanup

To clean up the resources and delete the KinD cluster, run the following command:

```bash
kind delete cluster --name cloud
```

This will remove the KinD cluster and all associated resources.

## Conclusion
Please let me know if you any question in the assignment Discord channel or in office hours.
