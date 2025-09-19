# Text-to-Speech App (AWS + Terraform)

A serverless **Text-to-Speech (TTS)** application built using **AWS Lambda, API Gateway, Amazon Polly, and S3**, with infrastructure provisioned by **Terraform**.  
This project was developed as my **capstone project** to demonstrate knowledge of AWS cloud services.

---

## Problem Statement
The goal of this project was to design and implement a **scalable, serverless application** that converts user-provided text into natural-sounding speech.  
It showcases the use of AWS services for compute, storage, and AI, combined with Terraform for Infrastructure as Code (IaC).

---

## Architecture
<img width="644" height="358" alt="tts-architecture diagram" src="https://github.com/user-attachments/assets/574c7d27-ffad-4d36-b1c4-03bd8be995f9" />

**Flow:**
1. **Frontend (HTML, CSS, JS)** → User inputs text.  
2. **API Gateway** → Exposes `/synthesize` route.  
3. **Lambda Function (Python)** → Uses **Amazon Polly** to generate speech and saves the output in **S3**.  
4. **Amazon S3** → Stores audio files.  
5. **Presigned URL** → Returned to frontend, allowing the user to download or play the audio file.

---

## Features
- Convert text into speech (MP3 format).  
- Secure, scalable, and serverless architecture.  
- Real-time response with presigned URLs.  
- Simple frontend interface.  
- Infrastructure as Code using Terraform.  

---

## Tech Stack
- **AWS Lambda** (Python runtime)  
- **Amazon API Gateway v2 (HTTP API)**  
- **Amazon Polly** (Text-to-Speech)  
- **Amazon S3** (Static website + audio storage)  
- **Terraform** (Infrastructure provisioning)  
- **Frontend**: HTML, CSS, JavaScript  

---

## Setup Instructions

### Prerequisites
- AWS Account  
- Terraform installed  
- Live Server extension (VS Code) or S3 static hosting   
   
##Challenges & Solutions

CORS Errors → Fixed by updating API Gateway route and Lambda response headers.

403 Access Denied on S3 → Resolved by setting correct bucket policies and enabling static hosting.

Lambda Permissions → Allowed API Gateway to invoke Lambda using IAM role/policy.

##Future Improvements

Add user authentication with Amazon Cognito.

Support multiple languages and voices.

Store usage logs in DynamoDB.

Add a React/Vue frontend for richer UI.
