🌦️ Multi-Cloud Weather Tracker with Disaster Recovery (AWS + Azure)

A multi-cloud, highly available weather tracking application deployed across AWS and Azure, featuring DNS-based disaster recovery and Infrastructure as Code (IaC) using Terraform.

This project demonstrates real-world cloud architecture concepts such as multi-cloud deployment, static website hosting, CDN integration, DNS failover, and automated provisioning.

📌 Project Overview

The Multi-Cloud Weather Tracker is a static web application built using HTML, CSS, and JavaScript, designed to fetch and display real-time weather data.

To ensure high availability and resilience, the application is deployed on two cloud platforms:

Primary: AWS (S3 + CloudFront)

Secondary / DR: Azure (Blob Storage)

A custom domain registered via Namecheap is configured with AWS Route 53 DNS Failover, allowing seamless traffic redirection to Azure in case AWS becomes unavailable.

All infrastructure is provisioned and managed using Terraform, ensuring repeatable, automated, and scalable deployments.

🏗️ Architecture Overview
High-Level Design
User
 │
 ▼
Route 53 (DNS Failover)
 │
 ├── AWS (Primary)
 │    ├── S3 (Static Website Hosting)
 │    └── CloudFront (CDN)
 │
 └── Azure (Failover)
      └── Azure Blob Storage (Static Website).

☁️ Cloud Services Used
AWS Services

Amazon S3 – Static website hosting

Amazon CloudFront – Global CDN for performance optimization

Amazon Route 53 – DNS management and health-check-based failover

Azure Services

Azure Blob Storage (Static Website) – Disaster recovery hosting endpoint

Other Tools

Terraform – Infrastructure as Code (IaC) for multi-cloud provisioning

Namecheap – Domain registration and DNS delegation

AWS CLI & Azure CLI – Authentication and resource management

--> Features

- Multi-cloud deployment (AWS + Azure)

- Static website hosting on both platforms

- Global content delivery via CloudFront

- DNS-based disaster recovery using Route 53

- Fully automated infrastructure using Terraform

- Low-cost, production-style architecture 

🛠️ Project Workflow

1️⃣ Prerequisites

- Install Terraform

- Configure AWS CLI

- Configure Azure CLI

- Active AWS and Azure subscriptions

- Domain registered via Namecheap

2️⃣ AWS Infrastructure (Terraform)

- S3 bucket for static website hosting

- CloudFront distribution

- Route 53 hosted zone and health checks

3️⃣ Azure Infrastructure (Terraform)

- Resource group

- Storage account

- Blob container with static website enabled

4️⃣ Disaster Recovery Setup

- Route 53 DNS failover routing policy

- Primary endpoint → AWS CloudFront

- Secondary endpoint → Azure Blob Storage

📂 Repository Structure
multi-cloud-weather-tracker/
│
├── aws/
│   ├── s3.tf
│   ├── cloudfront.tf
│   ├── route53.tf
│
├── azure/
│   ├── storage_account.tf
│   ├── resource_group.tf
│
├── terraform/
│   ├── provider.tf
│   ├── variables.tf
│   ├── outputs.tf
│
├── app/
│   ├── index.html
│   ├── style.css
│   └── script.js
│
└── README.md

💰 Estimated Time & Cost
      Item	Estimate
      Setup Time	2–3 hours
      AWS Cost	Free Tier
      Azure Cost	Free Tier
      Domain Name	~$1

🎯 Learning Outcomes

By completing this project, you gain hands-on experience with:

Multi-cloud architecture design

DNS-based disaster recovery strategies

Terraform for cross-cloud infrastructure

Static web hosting best practices

Real-world DevOps & Cloud Engineering workflows

📈 Future Enhancements

🔐 HTTPS with ACM & Azure-managed certificates

📊 CloudWatch & Azure Monitor integration

🧪 CI/CD pipeline using GitHub Actions

🌍 Active-Active multi-cloud traffic routing

🔄 Automated health checks & alerts



-->📚 Acknowledgements & Learning Resources

   -This project was implemented as part of advanced hands-on learning inspired by Techwith Lucy – AWS Advanced Projects.

   -The guidance provided by Techwith Lucy helped in understanding:

          Multi-cloud architecture design (AWS & Azure)

         Terraform-based Infrastructure as Code (IaC)

         DNS failover and disaster recovery concepts

         Real-world cloud deployment best practices

-All infrastructure setup, configuration, and deployment were implemented independently as part of this project for hands-on learning and skill enhancement.
