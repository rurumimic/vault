import hvac
from decouple import config
from pprint import pprint

VAULT_ADDR = config('VAULT_ADDR')
VAULT_TOKEN = open('/vault/secrets/token', 'r').read()

if __name__ == '__main__':
  client = hvac.Client(url=VAULT_ADDR, token=VAULT_TOKEN)

  response = client.secrets.kv.v2.read_secret_version(
    mount_point='secret',
    path='apple',
  )

  print('secret/apple')
  pprint(response['data']['data'])
