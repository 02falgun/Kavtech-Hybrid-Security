# 📁 Hybrid Storage Manager

The **Hybrid Storage Manager** is a core module of the **KAVTECH Hybrid Security Suite**, designed to provide **secure, intelligent, and scalable file storage** with hybrid local and cloud placement.  
It enables users to upload, view, manage, and delete files with a modern interface and strong security foundations.

---

## 🎯 Overview

Hybrid Storage Manager offers encrypted file management with intelligent decision-making for local or cloud storage.  
It is built to work seamlessly across **web and mobile platforms**, ensuring accessibility, reliability, and security.

---

## ✨ Key Features

### 🔐 Secure File Storage
- Encrypted file upload and processing  
- Intelligent hybrid storage (local + cloud)  
- Secure handling of sensitive data  
- User-based access control  

### 🌐 Cross-Platform Support
- Web browsers (Chrome, Safari, Firefox)  
- Native Android & iOS support  
- Real-time synchronization across devices  
- Offline access using local storage  

### 🎨 Modern User Interface
- Clean and professional UI  
- Glassmorphism design elements  
- Quick file preview  
- Drag-and-drop upload (planned)  
- Search & filter support (planned)  

---

## 🚀 Accessing the Storage Manager

### Via Dashboard
1. Log in to your **KAVTECH** account  
2. Open the **Dashboard**  
3. Select **Storage Manager** module  

### Direct Access
- **Web:** Available via main navigation menu  
- **Mobile:** Accessible through bottom navigation or side drawer  

---

## 📋 How to Use

### 1️⃣ Upload a File
- Open the Storage Manager  
- Enter:
  - **File Name**
  - **File Content / Description**
- Click **Upload File**  
- On success, the file appears in **Your Files**

### 2️⃣ View Files
Each uploaded file displays:
- 📄 File icon  
- 📝 File name  
- 📋 Content preview  
- 🗑️ Delete option  

### 3️⃣ Delete Files
- Click the red **trash icon** next to the file  
- File is removed instantly and list refreshes automatically  

---

## 🔧 Technical Details

### API Endpoints
```http
POST    /api/file/upload   → Upload file
GET     /api/file/list     → Fetch all files
DELETE  /api/file/:id      → Delete a file
Platform-Aware Base URLs
Web: http://localhost:3000/api

Mobile: http://10.180.6.197:3000/api

Sample Data Format
json
Copy code
{
  "id": 1,
  "name": "Document Name",
  "content": "File description or content",
  "uploadDate": "2025-07-26T12:00:00Z"
}
🛡️ Security Implementation
Current
Secure API communication

Backend input validation

Authentication-protected access

Graceful error handling

Planned Enhancements
AES-256 end-to-end encryption

Role-based access control

Audit logs for file activity

Malware scanning on uploads

🧪 Testing Scenarios
Upload a test file → should appear instantly

Upload multiple files → displayed in order

Delete a file → removed immediately

Invalid upload (empty fields) → error message shown

📱 Platform Support
Web
Fully responsive UI

Real-time updates

Smooth animations

Mobile
Touch-optimized design

Offline support

Native file picker (planned)

🚨 Troubleshooting
Upload Failed

Ensure backend is running

Check required fields

Verify network connection

Files Not Loading

Refresh page

Check API base URL

Clear cache if needed

Delete Not Working

Click directly on trash icon

Wait for backend response

Refresh manually if required

🔮 Future Roadmap
Phase 1

AES-256 encryption

TLS/SSL secure transfer

Role-based permissions

Phase 2

File type support (images, videos, PDFs)

File preview

Search & folders

Phase 3

AI-based file classification

Smart storage optimization

Compliance checks (DPDP Act)

📞 Support
📧 Email: support@kavtech.com

🐛 Bug Reports: Use in-app feedback

💡 Feature Requests: Always welcome

🎉 Get Started
Start uploading your files and experience secure, hybrid cloud storage with enterprise-grade security and modern UX.

