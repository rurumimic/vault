import hvac
from decouple import config
from pprint import pprint

VAULT_ADDR = config('VAULT_ADDR')

if __name__ == '__main__':
  client = hvac.Client(url=VAULT_ADDR)
  # print(client.is_authenticated()) # == True

  # Read Vault Secret
  response = client.secrets.kv.v2.read_secret_version(
    mount_point='secrets',
    path='fruit/apple',
  )

  print('fruit/apple')
  pprint(response['data']['data'])
  print()

  print('fruit/apple/address:', response['data']['data']['address'])
  print('fruit/apple/count:', response['data']['data']['count'])
  print()
