# Deployment Roulette

## Getting Started

### Installation

Step by step explanation of how to get a dev environment running.
----------
The AWS environment will be built in the `us-east-2` region of AWS

1. Set up your AWS credentials from Udacity AWS Gateway locally
    - `https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html`

2. From the AWS console manually create an S3 bucket in `us-east-2` called `udacity-tf-<your_name>`
   e.g `udacity-tf-emmanuel`
    - The click `create bucket`
    - Update `_config.tf` with your S3 bucket name

3. Deploy Terraform infrastructure
    - `cd starter/infra`
    - `terraform init`
    - `terraform apply`

5. Setup Kubernetes config so you can ping the EKS cluster
    - `aws eks --region us-east-2 update-kubeconfig --name udacity-cluster`
    - Change Kubernetes context to the new AWS cluster
        - `kubectl config use-context <cluster_name>`
            - e.g ` arn:aws:eks:us-east-2:139802095464:cluster/udacity-cluster`
    - Confirm with: `kubectl get pods --all-namespaces`
    - Change context to `udacity` namespace
        - `kubectl config set-context --current --namespace=udacity`

6. Run K8s initialization script
    - `./initialize_k8s.sh`

7. Done

### Project Tasks

*NOTE* All AWS infrastructure changes outside of the EKS cluster can be made in the project terraform code

1. *[Deployment Troubleshooting]*

   A previously deployed microservice `hello-world` doesn't seem to be reachable at its public endpoint. The product
   teams need you to fix this asap!
    1. The `apps/hello-world` deployment is facing deployment issues.
        - Assess, identify and resolve the problem with the deployment
        - Document your findings via screenshots or text files.

2. *[Canary deployments]*
    1. Create a shell script `canary.sh` that will be executed by GitHub actions.
    2. Canary deploy `/apps/canary-v2` so they take up 50% of the client requests
    3. Curl the service 10 times and save the results to `canary.txt`
        - Ensure that it is able to return results for both services
    4. Provide the output of `kubectl get pods --all-namespaces` to show deployed services

3. *[Blue-green deployments]*

   The product teams want a blue-green deployment for the `green` version of the `/apps/blue-green` microservice because
   they heard it's even safer than canary deployments
    1. Create a shell script `blue-green.sh` that executes a `green` deployment for the service `apps/blue-green`
    2. mimic the blue deployment configuration and replace the `index.html` with the values in `green-config` config-map
    3. The bash script will wait for the new deployment to successfully roll out and the service to be reachable.
    4. Create a new weighted CNAME record `blue-green.udacityproject` in Route53 for the green environment
    5. Use the `curl` ec2 instance to curl the `blue-green.udacityproject` url and take a screenshot to document that
       green & blue services are reachable
        1. The screenshot should be named `green-blue.png`
    6. Simulate a failover event to the `green` environment by destroying the blue environment
    7. Ensure the `blue-green.udacityproject` record now only returns the green environment
        - curl `blue-green.udacityproject` and take a screenshot of the results named `green-only.png` from the `curl`
          ec2 instance

4. *[Node elasticity]*

### Setup auto scale Node Cluster Kubernetes
1. connectivity to your AWS Kubernetes cluster:
    -   aws eks --region us-east-2 update-kubeconfig --name udacity-cluster
2. Change the account ID before running the command below:
    -   kubectl config use-context arn:aws:eks:us-east-2:ID-ACCOUNT:cluster/udacity-cluster
3. Connect to cluster:
    -   eksctl utils associate-iam-oidc-provider --cluster udacity-cluster --approve --region=us-east-2
4. Create IAM Role for policy arn:
    -   eksctl create iamserviceaccount --name cluster-autoscaler --namespace kube-system --cluster udacity-cluster --attach-policy-arn "arn:aws:iam::ID-ACCOUNT:policy/udacity-k8s-autoscale" --approve --region us-east-2
5. ID-ACCOUNT: Get ID using command: 
    aws sts get-caller-identity     --query Account     --output text
6. Deployment Pod check autoscale on kubernetes EKS:
    -   kubectl apply -f cluster_autoscale.yml
    -   kubectl -n kube-system logs -f deployment/cluster-autoscaler
5. *[Observability with metrics]*
 
    - kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
1. Get top memory pod on cluster:
    - kubectl top pod -n udacity --sort-by=memory | head -n 2 | tail -n 1  > high_memory.txt


6. *[Diagramming the cloud landscape with Bob Ross]*  
   In order to improve the onboarding of future developers. You decide to create an architecture diagram so that they
   don't have to learn the lessons you have learnt the hard way.
    1. Create an architectural diagram that accurately describes the current status of your AWS environment.
        1. Make sure to include your AWS resources like the EKS cluster, load balancers
        2. Visualize one or two deployments and their microservices

## Project Clean Up

In an effort to reduce your cost footprint in the AWS environment. Feel free to tear down your aws environment when not
in use. Clean up the environment with the `nuke_everything.sh` script or run the steps individually

```
cd starter/infra
terraform state rm kubernetes_namespace.udacity && terraform state rm kubernetes_service.blue
eksctl delete iamserviceaccount --name cluster-autoscaler --namespace kube-system --cluster udacity-cluster --region us-east-2
kubectl delete all --all -n udacity
terraform destroy

```
