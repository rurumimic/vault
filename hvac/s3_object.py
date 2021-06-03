import boto3
import json
from types import SimpleNamespace
from decouple import config

BUCKET_NAME = config('BUCKET_NAME')
KEY = config('KEY')
CREDNTIALS = config('CREDNTIALS')

def credentials():
  with open(CREDNTIALS) as json_file:
    return json.load(json_file, object_hook=lambda d: SimpleNamespace(**d))

def s3_client(config):
  return boto3.client('s3', 
    aws_access_key_id = config.data.access_key,
    aws_secret_access_key = config.data.secret_key,
    aws_session_token = config.data.security_token
  )

if __name__ == '__main__':
  # S3 Client
  s3 = s3_client(credentials())

  # Get S3 Object
  s3_object = s3.get_object(Bucket=BUCKET_NAME, Key=KEY)

  # Decode Object
  my_object = s3_object['Body'].read().decode('utf-8')

  print(my_object)
