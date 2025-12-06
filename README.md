# 🚀 DevOps Project – Go App Deployment on AWS using Terraform

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

---

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

You can verify the upload:

```bash
aws s3 ls s3://your-bucket-name
```

You should see:

```
assignment-app
```

---

### Step 2 — Configure Terraform Variables

Before deploying the infrastructure, you must update the Terraform variable file:

📍 File: terraform/terraform.tfvars

Add your own values here:

aws_region           = ""
ami_id               = ""
s3_bucket            = ""
s3_key               = ""
vpc_cidr             = ""
public_subnet_cidrs  = ["", ""]
private_subnet_cidrs = ["", ""]
instance_type        = ""
asg_desired          = 

📝 What each value means

Variable - Description
aws_region - AWS region where the infrastructure will be created
ami_id - AMI for EC2 instances (Ubuntu recommended)
s3_bucket - S3 bucket name that stores your Go binary
s3_key - Binary filename uploaded to S3
vpc_cidr - CIDR block for the VPC
public_subnet_cidrs - Two public subnets for ALB
private_subnet_cidrs - Two private subnets for EC2/ASG
instance_type - EC2 instance size
asg_desired - Desired number of instances in ASG


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
* Deploys full AWS infrastructure

After a few minutes, Terraform outputs:

* ALB DNS
* ASG name
* Target group ARN

---

### Step 4 — Test the Application

Open the ALB DNS in browser:

```
http://<alb-dns>/
```
<img width="1431" height="853" alt="Screenshot 2025-12-06 at 9 16 02 PM" src="https://github.com/user-attachments/assets/38510005-1b78-4e51-8a01-16e50198d8cd" />


You should see:

```
Hello from private EC2 (Go)!
```
<img width="1366" height="854" alt="Screenshot 2025-12-06 at 9 16 18 PM" src="https://github.com/user-attachments/assets/10aa1432-115a-40e0-9876-ab9aff202d52" />


Test the health check:

```
http://<alb-dns>/health
```

Output:

```
ok
```
<img width="1313" height="839" alt="Screenshot 2025-12-06 at 9 16 29 PM" src="https://github.com/user-attachments/assets/83a72132-b8e6-403e-91f4-718f81f11cef" />


This confirms the application is successfully running behind an ALB.

---

### Step 5 — Destroy Environment (Cleanup)

To remove all resources:

```bash
./scripts/destroy.sh
```

This prevents unnecessary AWS billing.

---

## 🛠️ How It Works (Behind the Scenes)

### ✔ Auto Scaling Group

Automatically launches EC2 instances using a Launch Template.

### ✔ User-Data Script

When a new EC2 instance boots:

* Installs AWS CLI via **snap**
* Downloads Go binary from S3
* Stores it at `/opt/assignment/assignment-app`
* Creates and enables a systemd service
* Starts the app automatically

### ✔ Load Balancer

Health checks `/health` endpoint and routes HTTP traffic to private instances.

### ✔ Networking

* Public subnets: ALB + NAT gateway
* Private subnets: EC2 instances
* NAT gives EC2 outbound internet access
