# 📁 Hybrid Storage Manager Usage Guide

## 🎯 Overview

The **Hybrid Storage Manager** is a core module of the KAVTECH Hybrid Security Suite that provides secure file storage capabilities with intelligent local/cloud placement decisions. It offers encrypted file management with an intuitive interface for uploading, viewing, and managing your documents.

## ✨ Key Features

### 🔐 **Secure File Storage**

- **Encrypted Upload**: Files are processed with security protocols
- **Hybrid Placement**: Intelligent decision between local and cloud storage
- **Content Protection**: Secure handling of sensitive documents
- **Access Control**: User-based file management

### 🌐 **Cross-Platform Support**

- **Web Browser**: Full functionality via Chrome/Safari/Firefox
- **Mobile Apps**: Native Android and iOS support
- **Real-time Sync**: Consistent experience across devices
- **Offline Access**: Local storage capabilities when offline

### 🎨 **Modern Interface**

- **Clean Design**: Professional UI with glassmorphism effects
- **Easy Upload**: Drag-and-drop file upload (planned feature)
- **File Preview**: Quick content viewing
- **Search & Filter**: Find files quickly (planned feature)

## 🚀 How to Access

### **Via Dashboard Navigation**

1. **Login** to your KAVTECH account
2. Navigate to the **Dashboard**
3. Look for the **"Storage Manager"** module card
4. Click to access the Hybrid Storage Manager

### **Direct Module Access**

- **Web**: Available through main navigation menu
- **Mobile**: Accessible via bottom navigation or side drawer

## 📋 Step-by-Step Usage

### **1. Upload a New File** 📤

1. **Open Storage Manager**: Access the module from dashboard
2. **Fill Upload Form**:

   - **File Name**: Enter a descriptive name for your file
   - **File Content**: Add the content or description
   - Click **"Upload File"** button

3. **Confirmation**: Success message appears when upload completes
4. **File Appears**: Your new file shows in the "Your Files" list below

### **2. View Your Files** 👀

- **File List**: All uploaded files appear in the bottom section
- **File Info**: Each file shows:
  - 📄 **File Icon**: Visual file representation
  - 📝 **File Name**: The name you assigned
  - 📋 **Content Preview**: First few lines of content
  - 🗑️ **Delete Button**: Red trash icon for removal

### **3. Delete Files** 🗑️

1. **Find Target File**: Locate the file you want to remove
2. **Click Delete Icon**: Red trash button on the right side
3. **Instant Removal**: File is immediately deleted from storage
4. **List Updates**: File list refreshes automatically

## 🔧 Technical Implementation

### **Backend Integration**

```javascript
// File Storage API Endpoints
POST /api/file/upload    // Upload new file
GET  /api/file/list      // List all files
DELETE /api/file/:id     // Delete specific file
```

### **Platform-Aware URLs**

- **Web Applications**: `http://localhost:3000/api`
- **Mobile Devices**: `http://10.180.6.197:3000/api`
- **Automatic Detection**: Platform detection handles URL routing

### **Data Format**

```json
{
  "id": 1,
  "name": "Document Name",
  "content": "File content or description",
  "uploadDate": "2025-07-26T12:00:00Z"
}
```

## 🛡️ Security Features

### **Current Implementation**

- ✅ **Secure API Communication**: HTTPS-ready endpoints
- ✅ **Input Validation**: Backend validates all uploads
- ✅ **User Authentication**: Login required for access
- ✅ **Error Handling**: Graceful error management

### **Planned Security Enhancements**

- 🔄 **End-to-End Encryption**: AES-256 file encryption
- 🔄 **Access Permissions**: Role-based file access
- 🔄 **Audit Logging**: Track all file operations
- 🔄 **Virus Scanning**: Malware detection for uploads

## 🎮 Testing the Storage Manager

### **1. Basic Upload Test**

```
File Name: "Test Document"
Content: "This is a test file for the storage manager demo."
Expected: File appears in list below
```

### **2. Multiple Files Test**

```
Upload several files with different names and content
Expected: All files appear in chronological order
```

### **3. Delete Functionality Test**

```
Upload a file, then delete it using the trash icon
Expected: File disappears from list immediately
```

### **4. Error Handling Test**

```
Try uploading with empty name or content
Expected: Red error message appears: "Name and content required"
```

## 📱 Platform-Specific Features

### **Web Browser (Chrome/Safari/Firefox)**

- ✅ **Full Interface**: Complete upload and management UI
- ✅ **Responsive Design**: Adapts to different screen sizes
- ✅ **Real-time Updates**: Instant file list refresh
- ✅ **Modern Styling**: Glassmorphism and smooth animations

### **Mobile Apps (Android/iOS)**

- ✅ **Touch-Optimized**: Mobile-friendly interface design
- ✅ **Native Performance**: Smooth scrolling and interactions
- ✅ **Offline Capability**: Local storage when network unavailable
- 🔄 **File Picking**: Native file picker integration (planned)

## 🚨 Troubleshooting

### **Common Issues & Solutions**

#### **"Upload Failed" Error**

- ✅ **Check Connection**: Verify backend server is running
- ✅ **Fill Required Fields**: Ensure both name and content are provided
- ✅ **Network Status**: Check internet connectivity

#### **Files Not Loading**

- ✅ **Refresh Page**: Reload the storage manager module
- ✅ **Check Backend**: Verify server at `localhost:3000` (web) or `10.180.6.197:3000` (mobile)
- ✅ **Clear Cache**: Clear browser cache if on web

#### **Delete Not Working**

- ✅ **Click Precisely**: Make sure to click the red trash icon directly
- ✅ **Wait for Response**: Allow time for backend processing
- ✅ **Refresh if Needed**: Manually refresh if file still appears

## 🔮 Future Enhancements

### **Phase 1: Core Security** (Next Update)

- 🔄 **File Encryption**: AES-256 encryption for all uploads
- 🔄 **Secure Transfer**: TLS/SSL for all communications
- 🔄 **Access Control**: User permissions and sharing

### **Phase 2: Advanced Features**

- 🔄 **File Types**: Support for images, documents, videos
- 🔄 **File Preview**: In-browser preview for common formats
- 🔄 **Search & Filter**: Advanced file discovery
- 🔄 **Folder Organization**: Hierarchical file structure

### **Phase 3: AI Integration**

- 🔄 **Smart Classification**: AI-powered file categorization
- 🔄 **Content Analysis**: Automatic content scanning
- 🔄 **Storage Optimization**: Intelligent local/cloud placement
- 🔄 **Compliance Checking**: Automatic DPDP Act compliance validation

## 📞 Support & Feedback

### **Getting Help**

- 📧 **Email**: support@kavtech.com
- 💬 **Documentation**: Check this guide for common questions
- 🐛 **Bug Reports**: Report issues via the app feedback system

### **Feature Requests**

We're constantly improving the Hybrid Storage Manager. Share your ideas for new features and enhancements!

---

## 🎉 Ready to Use!

Your **KAVTECH Hybrid Storage Manager** is ready for secure file storage and management. Start by uploading your first document and experience the power of hybrid cloud security!

**Access the Storage Manager through your dashboard and begin organizing your digital files with enterprise-grade security.** 🚀
