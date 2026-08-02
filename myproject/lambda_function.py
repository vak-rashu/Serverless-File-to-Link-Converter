import json
import boto3
import os
import io
import base64
import random
import string
import time
import re
import cgi

s3_client = boto3.client('s3')
dynamodb = boto3.client('dynamodb')

BUCKET_NAME = os.environ.get('BUCKET_NAME')
TABLE_NAME = os.environ.get('TABLE_NAME')
API_ID = os.environ.get('API_ID')

def generate_short_key(length=6):
    return ''.join(random.choices(string.ascii_letters + string.digits, k=length))

def sanitize_filename(name):
    return re.sub(r'[^a-zA-Z0-9._-]', '_', name)

def upload_file_to_s3(file_content, key):
    s3_client.put_object(
        Bucket=BUCKET_NAME,
        Key=key,
        Body=file_content
    )

def create_presigned_url(key):
    return s3_client.generate_presigned_url(
        'get_object',
        Params={'Bucket': BUCKET_NAME, 'Key': key},
        ExpiresIn=300
    )

def store_url_in_dynamodb(short_key, url):
    ttl = int(time.time()) + 300
    dynamodb.put_item(
        TableName=TABLE_NAME,
        Item={
            'shortKey': {'S': short_key},
            'originalUrl': {'S': url},
            'TimeToExist': {'N': str(ttl)}
        }
    )

def get_url_from_dynamodb(short_key):
    response = dynamodb.get_item(
        TableName=TABLE_NAME,
        Key={'shortKey': {'S': short_key}}
    )
    if 'Item' not in response:
        raise Exception("Invalid Key")
    return response['Item']['originalUrl']['S']

def lambda_handler(event, context):
    method = event.get("httpMethod")

    cors_headers = {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,Accept",
        "Access-Control-Allow-Methods": "POST, GET, OPTIONS"
    }

    if method == "OPTIONS":
        return {
            "statusCode": 200,
            "headers": cors_headers,
            "body": json.dumps({"msg": "CORS preflight OK"})
        }

    if method == "POST":
        try:
            # Decode base64-encoded body (multipart/form-data comes in like this)
            headers = event.get("headers") or {}
            content_type = headers.get("Content-Type") or headers.get("content-type") or ""

            body_raw = event.get("body", "")
            if event.get("isBase64Encoded", False):
                body = base64.b64decode(body_raw)
            elif isinstance(body_raw, str):
                body = body_raw.encode("utf-8")
            else:
                body = body_raw

            # Use cgi to parse multipart data
            environ = {'REQUEST_METHOD': 'POST'}
            env_headers = {'content-type': content_type}
            fs = cgi.FieldStorage(fp=io.BytesIO(body), environ=environ, headers=env_headers)

            # Get the file
            file_field = fs['file']
            file_bytes = file_field.file.read()

            # Get custom filename
            custom_name = fs.getvalue('filename')
            filename = sanitize_filename(custom_name) if custom_name else file_field.filename

            # Detect if it's a binary file (e.g., based on extension)
            binary_extensions = ['.pdf', '.jpg', '.jpeg', '.png', '.xlsx']
            is_binary = any(filename.endswith(ext) for ext in binary_extensions)

            content = file_bytes if is_binary else file_bytes.decode("utf-8", errors="ignore")

            upload_file_to_s3(content, filename)
            presigned_url = create_presigned_url(filename)
            short_key = generate_short_key()
            store_url_in_dynamodb(short_key, presigned_url)

            short_url = f"https://{API_ID}.execute-api.us-east-1.amazonaws.com/project/short?shortKey={short_key}"

            return {
                "statusCode": 200,
                "headers": cors_headers,
                "body": json.dumps({"msg": short_url})
            }

        except Exception as e:
            return {
                "statusCode": 500,
                "headers": cors_headers,
                "body": json.dumps({"msg": "Error: " + str(e)})
            }

    elif method == "GET":
        try:
            short_key = event.get("queryStringParameters", {}).get("shortKey")
            original_url = get_url_from_dynamodb(short_key)

            return {
                "statusCode": 301,
                "headers": {
                    'Location': original_url,
                    "Access-Control-Allow-Origin": "*"
                },
            }

        except Exception as e:
            return {
                "statusCode": 500,
                "headers": cors_headers,
                "body": json.dumps({"msg": "Error: " + str(e)})
            }

    else:
        return {
            "statusCode": 405,
            "headers": cors_headers,
            "body": json.dumps({"msg": "Method not allowed"})
        }

