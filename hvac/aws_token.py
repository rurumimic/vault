import hvac
import json
from decouple import config

VAULT_ADDR = config('VAULT_ADDR')
ROLE_NAME = config('ROLE_NAME')
TTL = config('TTL')
CREDNTIALS = config('CREDNTIALS')

# AWS: List Roles
def list_roles(client):
  response = client.secrets.aws.list_roles()
  roles = response['data']['keys']
  return roles

# AWS: Read Role
def read_role(client, name):
  response = client.secrets.aws.read_role(name=name)
  return response

# AWS: Generate Credentials - AssumeRole
def get_token(client):
  response = client.secrets.aws.generate_credentials(name=ROLE_NAME, ttl=TTL)
  return response

def write_credentials(data):
  with open(CREDNTIALS, 'w') as json_file:
    json.dump(data, json_file)
  
if __name__ == '__main__':
  client = hvac.Client(url=VAULT_ADDR)
  token = get_token(client)
  write_credentials(token)
