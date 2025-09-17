# 📧 n8n Email Automation Workflow Setup Guide

## 🎯 **What This Workflow Does**

This email automation workflow automatically processes incoming emails and provides intelligent responses based on content analysis:

### **Core Features:**
- **📥 Gmail Integration** - Monitors Gmail for new unread emails
- **🧠 Smart Categorization** - Automatically categorizes emails as urgent, questions, complaints, or general
- **⚡ Priority Handling** - High-priority emails trigger immediate notifications
- **🤖 Auto-Responses** - Sends contextual automated replies
- **📊 Email Logging** - Tracks all processed emails

### **Email Categories:**
- **🚨 URGENT** - Contains "urgent" or "asap" keywords
- **❓ QUESTION** - Contains question marks or "help" keywords  
- **😠 COMPLAINT** - Contains "complaint", "problem", or "issue" keywords
- **📝 GENERAL** - All other emails

## 🚀 **Setup Instructions**

### **Step 1: Import the Workflow**
1. Open n8n at `http://localhost:5678`
2. Click **"Import from File"**
3. Select `simple-email-automation.json`
4. Click **"Import"**

### **Step 2: Configure Gmail OAuth2**
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable Gmail API
4. Create OAuth2 credentials
5. Add `http://localhost:5678/rest/oauth2-credential/callback` as redirect URI
6. In n8n, go to **Credentials** → **Add Credential** → **Gmail OAuth2**
7. Enter your Client ID and Client Secret

### **Step 3: Configure SMTP (Gmail)**
1. In n8n, go to **Credentials** → **Add Credential** → **SMTP**
2. Configure with your Gmail settings:
   - **Host**: `smtp.gmail.com`
   - **Port**: `587`
   - **Username**: `jessestay@gmail.com`
   - **Password**: `fhhv naib drrv qots` (App Password)
   - **Security**: `TLS`

### **Step 4: Set Up Webhook Logging (Optional)**
1. Go to [webhook.site](https://webhook.site/)
2. Copy your unique URL
3. In the workflow, update the "Log Email" node URL
4. Replace `https://webhook.site/your-unique-url` with your actual URL

### **Step 5: Activate the Workflow**
1. Click the **"Active"** toggle in the top right
2. The workflow will start monitoring Gmail

## 🔧 **Workflow Nodes Explained**

### **1. Gmail Trigger**
- **Purpose**: Monitors Gmail for new unread emails
- **Configuration**: OAuth2 authentication, unread filter
- **Triggers**: Every time a new email arrives

### **2. Process Email**
- **Purpose**: Analyzes email content and categorizes it
- **Logic**: 
  - Extracts subject, body, sender info
  - Detects urgent keywords
  - Identifies questions and complaints
  - Assigns priority levels

### **3. Check Priority**
- **Purpose**: Routes emails based on priority
- **High Priority**: Urgent emails and complaints
- **Normal Priority**: Questions and general emails

### **4. Send Urgent Notification**
- **Purpose**: Alerts you immediately about high-priority emails
- **Action**: Sends notification to `jessestay@gmail.com`
- **Format**: Includes all email details and categorization

### **5. Generate Response**
- **Purpose**: Creates contextual automated responses
- **Templates**:
  - **Urgent**: "We're on it! Responding within 1 hour"
  - **Question**: "Thanks for your question! Responding within 24 hours"
  - **Complaint**: "We're sorry! Escalated to management, 4-hour response"
  - **General**: "Thank you! Responding within 24 hours"

### **6. Send Auto Response**
- **Purpose**: Sends the generated response back to sender
- **Configuration**: Uses SMTP credentials

### **7. Log Email**
- **Purpose**: Records all processed emails for tracking
- **Method**: Sends data to webhook endpoint

## 📊 **Response Templates**

### **Urgent Email Response:**
```
Subject: Re: [Original Subject] - We're on it!

Hi there,

Thank you for your urgent message. We've received your request and are prioritizing it immediately.

Our team will respond within 1 hour during business hours.

Best regards,
StayNAlive.com Team
```

### **Question Email Response:**
```
Subject: Re: [Original Subject] - Thanks for your question!

Hi there,

Thank you for reaching out with your question. We've received your message and will get back to you within 24 hours.

In the meantime, you might find helpful information in our FAQ: https://staynalive.com/faq

Best regards,
StayNAlive.com Support Team
```

### **Complaint Email Response:**
```
Subject: Re: [Original Subject] - We're sorry to hear about this

Hi there,

We sincerely apologize for any inconvenience you've experienced. Your feedback is important to us.

We've escalated your concern to our management team and will respond within 4 hours.

Best regards,
StayNAlive.com Customer Service
```

## 🎛️ **Customization Options**

### **Modify Email Detection:**
Edit the "Process Email" node to add/remove keywords:
```javascript
const isUrgent = subject.toLowerCase().includes('urgent') || 
                 subject.toLowerCase().includes('asap') ||
                 subject.toLowerCase().includes('emergency'); // Add more keywords
```

### **Update Response Templates:**
Edit the "Generate Response" node to modify templates:
```javascript
const templates = {
  urgent: {
    subject: `Re: ${subject} - We're on it!`,
    body: `Your custom urgent response here...`
  }
  // Add more templates
};
```

### **Change Notification Recipient:**
Update the "Send Urgent Notification" node:
- Change `toEmail` from `jessestay@gmail.com` to your preferred email

### **Add Slack Notifications:**
1. Add a new HTTP Request node
2. Configure with your Slack webhook URL
3. Connect it to the complaint detection logic

## 🔍 **Testing the Workflow**

### **Test Scenarios:**
1. **Urgent Email**: Send email with "URGENT" in subject
2. **Question Email**: Send email with "?" in body
3. **Complaint Email**: Send email with "complaint" in body
4. **General Email**: Send any other email

### **Expected Behavior:**
- **Urgent/Complaint**: You get immediate notification + auto-response sent
- **Question/General**: Auto-response sent + logged

## 🚨 **Troubleshooting**

### **Common Issues:**

1. **Gmail OAuth2 Not Working:**
   - Check redirect URI in Google Cloud Console
   - Verify API is enabled
   - Re-authenticate credentials

2. **SMTP Sending Failed:**
   - Verify Gmail App Password is correct
   - Check SMTP settings (port 587, TLS)
   - Ensure 2FA is enabled on Gmail

3. **Workflow Not Triggering:**
   - Check if workflow is active
   - Verify Gmail credentials are working
   - Check n8n logs for errors

4. **Auto-Responses Not Sending:**
   - Verify SMTP credentials
   - Check email format in response generation
   - Ensure sender email is valid

### **Debug Steps:**
1. Check n8n execution logs
2. Test individual nodes manually
3. Verify all credentials are working
4. Check webhook.site for logging data

## 📈 **Advanced Features to Add**

### **Future Enhancements:**
- **Email Templates**: Use n8n's template system
- **Database Logging**: Replace webhook with database
- **Slack Integration**: Add Slack notifications
- **Calendar Integration**: Schedule follow-ups
- **AI Analysis**: Use OpenAI for better categorization
- **Multi-language Support**: Detect and respond in different languages

## 🎉 **You're All Set!**

Your email automation workflow is now ready to handle incoming emails intelligently. The system will:

✅ **Monitor** Gmail for new emails  
✅ **Analyze** content for priority and category  
✅ **Notify** you of urgent issues immediately  
✅ **Respond** automatically with contextual messages  
✅ **Log** all activity for tracking  

**Happy automating!** 🚀



