# DevOps Project – Go App Deployment on AWS using Terraform

This project demonstrates how to deploy a **Go-based web application** onto AWS using **Terraform**, **Auto Scaling Group**, **Application Load Balancer**, **private subnets**, **NAT Gateway**, **IAM roles**, and **S3 for artifacts**.

The goal is to showcase real DevOps skills: infrastructure-as-code, automation, scaling, user-data bootstrapping, and secure cloud architecture.

---

## 🏗️ **Architecture Overview**

This setup provisions:

* **VPC** with public + private subnets
* **Internet Gateway & NAT Gateway**
* **Application Load Balancer (ALB)**
* **Auto Scaling Group (ASG)** with Launch Template
* **IAM Role + Instance Profile**
* **S3 Bucket** to store the Go binary
* **EC2 instances running in private subnets**
* **User-data script** to auto-download & run the Go app

Traffic flow:

**ALB → EC2 (private subnet) → Go API (port 8080)**

The app exposes:

* `/` — root message
* `/health` — ALB health check


## 📁 Folder Structure

```
devops-assignment/
│
├── app/                 # Go source code + build script
│   ├── main.go
│   └── build.sh
│
├── scripts/             # Helper scripts
│   ├── deploy.sh
│   ├── destroy.sh
│   └── test.sh
│
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── provider.tf
│   └── modules/
│       ├── networking/
│       ├── iam/
│       ├── compute/
│       └── alb/
│
└── README.md
```

---

## 🧰 **Prerequisites**

Before starting, ensure you have:

* **AWS CLI** configured (`aws configure`)
* **Terraform ≥ 1.0**
* **Go ≥ 1.19**
* **An S3 bucket** for storing the Go binary
* **IAM permissions** to create VPC, EC2, ALB, IAM, S3, etc.

---

## ⚙️ Step 1 — Build & Upload the Go Binary

Inside the `app/` folder:

```bash
cd app
chmod +x build.sh
./build.sh
```

This script will:

* Build a Linux AMD64 binary
* Upload it to your S3 bucket

To verify the upload:

```bash
aws s3 ls s3://your-bucket-name
```

Expected output:

```
assignment-app
```

---

## 🔧 Step 2 — Configure Terraform Variables

Before deploying the infrastructure, update the Terraform variable file:

📍 **File:** `terraform/terraform.tfvars`

Add your values here:

```hcl
aws_region           = ""
ami_id               = ""
s3_bucket            = ""
s3_key               = ""
vpc_cidr             = ""
public_subnet_cidrs  = ["", ""]
private_subnet_cidrs = ["", ""]
instance_type        = ""
asg_desired          = 1
```


### 📝 What Each Variable Means

| **Variable**           | **Description**                                      |
| ---------------------- | ---------------------------------------------------- |
| `aws_region`           | AWS region where the infrastructure will be deployed |
| `ami_id`               | Ubuntu AMI ID for EC2 instances                      |
| `s3_bucket`            | S3 bucket name where the Go binary is stored         |
| `s3_key`               | Name of the Go binary file inside S3                 |
| `vpc_cidr`             | CIDR block of your VPC                               |
| `public_subnet_cidrs`  | Two public subnet CIDRs for ALB                      |
| `private_subnet_cidrs` | Two private subnet CIDRs for EC2/ASG                 |
| `instance_type`        | EC2 instance size (e.g., t3.micro)                   |
| `asg_desired`          | Number of EC2 instances to run in ASG                |

---

## ⚙️ Step 3 — Deploy Infrastructure with Terraform

Inside the project root:

```bash
cd terraform
./scripts/deploy.sh
```

This script:

* Runs `terraform init`
* Runs `terraform apply`
* Passes required variables
* Deploys all AWS resources

Terraform will output:

* ALB DNS
* ASG Name
* Target Group ARN

---

## 🧪 Step 4 — Test the Application

Open the ALB DNS in browser:

```
http://<alb-dns>/
```

Expected output:

```
Hello from private EC2 (Go)!
```
<img width="1366" height="854" alt="Screenshot 2025-12-06 at 9 16 18 PM" src="https://github.com/user-attachments/assets/824f4e9d-fc87-48e0-9cd9-9db54b9065fe" />

Test the health endpoint:

```
http://<alb-dns>/health
```

Expected output:

```
ok
```
<img width="1313" height="839" alt="Screenshot 2025-12-06 at 9 16 29 PM" src="https://github.com/user-attachments/assets/7b5d8cc5-21af-461e-9128-6484074e101b" />


This confirms the application is successfully running behind the ALB.

---

## 🧹 Step 5 — Destroy Environment (Cleanup)

To remove everything and avoid AWS charges:

```bash
./scripts/destroy.sh
```

---

## 🛠️ How It Works (Behind the Scenes)

### ✔ Auto Scaling Group

Keeps EC2 instances running based on desired capacity.

### ✔ User-Data Script

On EC2 boot:

* Installs AWS CLI
* Downloads binary from S3
* Stores it at `/opt/assignment/assignment-app`
* Creates & starts systemd service

### ✔ Load Balancer

Routes user traffic to private EC2 instances and performs `/health` checks.

### ✔ Networking

* **Public subnets** → ALB, NAT gateway
* **Private subnets** → EC2 instances
* **NAT Gateway** → allows outbound internet access for package downloads
