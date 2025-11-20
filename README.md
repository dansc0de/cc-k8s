# WordPress Deployment on Local Kubernetes Cluster using Minikube

In this assignment, you will deploy a WordPress application on a local Kubernetes cluster using **Minikube** (Kubernetes v1.33). The deployment includes both a WordPress frontend and a MySQL backend, configured using Kubernetes manifest files.

all configuration files **must be placed in the `manifests/` directory**. your submission will be evaluated automatically through a **GitHub Actions workflow** that runs every time you push to the repository. if the workflow passes, your assignment is considered complete and ready for grading.

**reference documentation**: for detailed kubernetes resource specifications, see the [kubernetes api v1.33 reference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/).

---

## Docs

- [Minikube Guide](./docs/minikube.md)
- [kubectl Reference](./docs/kubectl.md)
- [Kubernetes API v1.33 Reference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/)

---

## Prerequisites

Ensure the following tools are installed on your system:

- [Docker](https://www.docker.com/get-started)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [Minikube](https://minikube.sigs.k8s.io/docs/start/)

---

## What is WordPress (and Why Should You Care)?

![wordpress setup page](wordpress.png)

[WordPress](https://wordpress.org/) is the world’s most popular content management system (CMS). It powers blogs, portfolios, ecommerce stores, news sites, recipe blogs your aunt still updates, and basically half the internet.

It runs on PHP, stores data in MySQL, and serves HTML pages using a web server like Apache — making it the perfect example of a classic web stack.

> **Fun Fact (probably true)**:\
> Over **43.6%** of the internet is actually just WordPress plugins arguing with each other.

For this assignment, you won’t be writing WordPress code — you’ll be deploying a ready-to-run containerized version of WordPress alongside its MySQL backend on your local Kubernetes cluster.

This means you'll get to see how real-world applications are deployed, configured, and persisted in production-like environments. Which is kind of a big deal.

---

## Understanding Secrets

Secrets work like ConfigMaps but are designed for sensitive data such as passwords. In this assignment, the Secret named `database` has already been created in `manifests/db-secret.yaml` with the following keys:

- `root-password` - MySQL root user password
- `user-password` - MySQL application user password

You will reference this Secret in your deployments using `secretKeyRef` (similar to how you use `configMapKeyRef` for ConfigMaps). You do not need to modify `manifests/db-secret.yaml`.

---

## What You Need to Build

You must configure the following resources using Kubernetes manifests:

### 1. MySQL Deployment (`wordpress-mysql`)

- Must use labels:\
  `app: wordpress`\
  `tier: mysql`
- Environment variables from:
    - ConfigMap named `wordpress-mysql`:
      ```yaml
      database: 'wordpress'
      user: 'wordpress'
      ```
      Mounted as:
      ```yaml
      - name: MYSQL_DATABASE
        valueFrom:
          configMapKeyRef:
            name: wordpress-mysql
            key: database
      - name: MYSQL_USER
        valueFrom:
          configMapKeyRef:
            name: wordpress-mysql
            key: user
      ```
    - Secret named `database` (already provided):
      Mounted as:
      ```yaml
      - name: MYSQL_ROOT_PASSWORD
        valueFrom:
          secretKeyRef:
            name: database
            key: root-password
      - name: MYSQL_PASSWORD
        valueFrom:
          secretKeyRef:
            name: database
            key: user-password
      ```
- Must include a PVC (`mysql-pv-claim`) of size `1Gi` mounted at:\
  `/var/lib/mysql`

---

### 2. WordPress Deployment (`wordpress`)

- Must use labels:\
  `app: wordpress`\
  `tier: frontend`
- Environment variables from:
    - ConfigMap named `wordpress`:
      ```yaml
      host: 'wordpress-mysql'
      user: 'wordpress'
      ```
      Mounted as:
      ```yaml
      - name: WORDPRESS_DB_HOST
        valueFrom:
          configMapKeyRef:
            name: wordpress
            key: host
      - name: WORDPRESS_DB_USER
        valueFrom:
          configMapKeyRef:
            name: wordpress
            key: user
      ```
    - Secret named `database` (already provided):
      Mounted as:
      ```yaml
      - name: WORDPRESS_DB_PASSWORD
        valueFrom:
          secretKeyRef:
            name: database
            key: user-password
      ```
- Must include a PVC (`wp-pv-claim`) of size `1Gi` mounted at:\
  `/var/www/html`

---

### 3. Services

- Create two services:
    - `wordpress-mysql`
        - Must use selectors: `app: wordpress`, `tier: mysql`
        - Port: `3306`
    - `wordpress`
        - Must use selectors: `app: wordpress`, `tier: frontend`
        - Port: `80`

---

## Rubric

| **Component**            | **Criteria**                                                                   | **Points** |
| ------------------------ | ------------------------------------------------------------------------------ |------------|
| **MySQL Deployment**     | Uses correct labels, environment vars via ConfigMap and Secret, and mounts PVC | 2          |
| **MySQL Service**        | Service with correct selector and port                                         | 2          |
| **WordPress Deployment** | Uses correct labels, environment vars via ConfigMap and Secret, and mounts PVC | 2          |
| **WordPress Service**    | Service with correct selector and port                                         | 2          |
| **ConfigMaps**           | `wordpress` and `wordpress-mysql` with correct keys and used in deployments    | 2          |
| **PersistentVolumes**    | PVCs created and mounted for both WordPress and MySQL                          | 2          |
| **Functionality**        | WordPress loads successfully via port-forward or ingress                       | 3          |

**Total Points:** 15

---

## Important: Resource Naming

**Do not rename any resources.** All resource names are specified in the requirements above and must match exactly:

- deployments: `wordpress`, `wordpress-mysql`
- services: `wordpress`, `wordpress-mysql`
- pvcs: `wp-pv-claim`, `mysql-pv-claim`
- configmaps: `wordpress`, `wordpress-mysql`
- secret: `database`

Grading is done automatically using `check.sh`, which validates these exact names. If you rename resources, the validation will fail and your assignment will not be graded correctly.

---

## Submission

Push your code to the `main` branch of your GitHub repository. Then submit your GitHub URL to Canvas.

A **GitHub Actions workflow** will run on every commit to validate your manifests. It uses a script called `check.sh` to verify that your Kubernetes resources are configured correctly. This script checks for the presence of:

- Required Deployments, Services, PVCs, ConfigMaps, and Secrets
- Correct environment variable mounting from ConfigMaps and Secrets
- An accessible WordPress installation page (HTTP 200 response from `/wp-admin/install.php`)

You can test your setup locally using the same script:

```bash
./check.sh
```

Alternatively, you can manually verify the setup by running:

```bash
kubectl port-forward svc/wordpress 8080:80
```

Then open [http://localhost:8080](http://localhost:8080) in your browser to confirm that the WordPress install page loads.

If the script or manual check succeeds, your submission is likely ready for grading!
