![aws infrastructure](https://github.com/user-attachments/assets/b9fc9d76-3abc-4a1e-b269-a8a75e05acb7)

## What is happening in the diagram?
1. The API Gateway has two endpoints created one for POST and another to GET, and they both are integrated to one lambda function which handles both the request.

### API Gateway has 2 endpoints:
POST /shorten: This route will handle the operation of put_objects in the S3 and creation of short URLs.
GET /short?shortKey={shortKey}: This route will redirect users to the original URL based on the short code provided.
### Lambda: 
There is only one lambda attached to both the endpoints, its job is to  Put objects into S3, creates the Pre Signed URL, generates short key, creates a shortened URL and finally Redirects to the Pre Signed URL.
### S3: 
It is used to store the actual files of the users, only of which Pre Signed URL's will be created.
### DynamoDB: 
It stores a key mapping of shortKey with the original URL with a TTL of 5 mins. So one has only 5 mins to download the file.

---

## 🎨 Static Frontend (S3 Ready)

A minimal, zero-dependency static frontend built with Vanilla HTML5, CSS3, and JavaScript is available in the [`frontend/`](frontend/) directory.

### Features:
- 📁 Drag-and-drop file upload interface
- 🔑 Persistent API Gateway endpoint configuration (saved to `localStorage`)
- ⏱️ Live 5-minute countdown expiration badge
- 📋 One-click URL copying to clipboard
- ☁️ 100% S3 static website hosting compatible (no build step needed)

See [`frontend/README.md`](frontend/README.md) for step-by-step S3 deployment instructions.

---

![a user made a request to POST](https://github.com/user-attachments/assets/bd78aa2c-ee5e-4c80-87d6-455c2ba7576a)
- When a user wants to convert a file into link, he/she will go to POST /shorten and the lambda will put that object into the S3, with the key name being the filename given by the user.
Then a shortKey and Pre Signed URL of that object will be created, with a TimeToLive attribute of 5 mins only. So the user gets total 5 mins of time to use the URL to share or copy paste it into the browser to download the file. All this data will be stored in DynamoDB to create a mapping between the three keys.
- In return to the POST request he gets the generated shortened URL.


![the file being downloaded after the GET request](https://github.com/user-attachments/assets/8d379887-00af-4db4-b744-152a9a8dbc56)
- Now with this URL, the user would like to copy it and share it or paste it in some other browser to GET the download of the file.
This is done by actually redirecting the location to the corresponding Pre Signed URL, and the download will start automatically.

Drawbacks:
* One of the major drawback that I found with this project is that the setup is a monolith. As, the POST method is handling everything from creating the bucket to generating the shortkeys to getting the presigned urls and at last putting it all into the dynamodb.
And that being said, a better architecture has to be build to make services loosely coupled to each other.

* And of course, other drawbacks are that it still doesn't include NOT creating a different short Key even for the same file. Hence, it lacks uniqueness.

* The S3 object still stays even after the deletion of its URL mapping in the DynamoDB.

* And at last, a custom Domain Name, as this API Gateway can't alone be used in real life application.
