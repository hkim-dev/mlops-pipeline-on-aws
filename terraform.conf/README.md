# MLOps Terraform Project

This project sets up a lightweight MLOps pipeline on AWS using Terraform.

## Project Structure

```bash
.
├── core/     # Shared infrastructure: ECS, IAM, logs
├── mlops/    # ECS tasks and step function
├── api/      # Lambda + API Gateway for inference
├── main.tf   # Root module that connects everything
```

## Usage

1. Initalize the Terraform working directory:
    ```
    terraform init
    ```
2. Apply the infrastructure with your variables:
    ```
    terraform apply -var-file="terraform.tfvars"
    ```
