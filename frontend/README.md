# Frontend - Serverless File to Link Converter

A lightweight, zero-dependency static frontend designed for hosting on **Amazon S3 Static Website Hosting**.

## Files
- `index.html`: Semantic HTML structure featuring API Gateway endpoint configuration, drag-and-drop dropzone, optional custom filename, link copy, and expiration countdown.
- `style.css`: Modern glassmorphic dark-mode design system using pure CSS.
- `app.js`: Pure Vanilla JavaScript (no npm, no node_modules, no build step required).

---

## 🚀 How to Host on AWS S3

### Option 1: AWS CLI Deployment (Quickest)

1. **Create an S3 Bucket** (Replace `my-file-converter-frontend` with your unique bucket name):
   ```bash
   aws s3 mb s3://my-file-converter-frontend --region us-east-1
   ```

2. **Enable Static Website Hosting**:
   ```bash
   aws s3 website s3://my-file-converter-frontend/ --index-document index.html --error-document index.html
   ```

3. **Disable Block Public Access**:
   ```bash
   aws s3api put-public-access-block \
       --bucket my-file-converter-frontend \
       --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"
   ```

4. **Attach Public Read Policy**:
   Save the following JSON to `policy.json` (replace `my-file-converter-frontend`):
   ```json
   {
       "Version": "2012-10-17",
       "Statement": [
           {
               "Sid": "PublicReadGetObject",
               "Effect": "Allow",
               "Principal": "*",
               "Action": "s3:GetObject",
               "Resource": "arn:aws:s3:::my-file-converter-frontend/*"
           }
       ]
   }
   ```
   Apply the policy:
   ```bash
   aws s3api put-bucket-policy --bucket my-file-converter-frontend --policy file://policy.json
   ```

5. **Upload Frontend Files**:
   ```bash
   aws s3 sync . s3://my-file-converter-frontend/ --exclude "README.md" --exclude "policy.json"
   ```

6. **Access Your Website**:
   Your website will be live at:
   `http://my-file-converter-frontend.s3-website-us-east-1.amazonaws.com`

---

### Option 2: AWS S3 Management Console (GUI)

1. Go to **AWS S3 Console** -> **Create bucket**.
2. Uncheck **"Block all public access"** and confirm.
3. Open the newly created bucket -> **Properties** -> scroll down to **Static website hosting** -> Click **Edit**.
4. Select **Enable**, type `index.html` for both Index and Error documents, and save.
5. Go to the **Permissions** tab -> **Bucket policy** -> Edit -> Paste the `PublicReadGetObject` policy.
6. Go to the **Objects** tab -> Upload `index.html`, `style.css`, and `app.js`.

---

## ⚡ Usage Instructions

1. Open your S3 website URL in your browser.
2. Enter your **API Gateway Endpoint URL** (e.g. `https://xxxxxx.execute-api.us-east-1.amazonaws.com/project/shorten`) in the top input box and click **Save** (it will be remembered in `localStorage`).
3. Drag & drop a file or click to select one.
4. (Optional) Provide a custom filename.
5. Click **Generate Short Link**.
6. Copy the generated link (valid for 5 minutes).
