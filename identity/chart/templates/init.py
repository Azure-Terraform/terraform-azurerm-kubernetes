#!/usr/local/bin/python
import requests
#import logging
#
#try:
#    import http.client as http_client
#except ImportError:
#    # Python 2
#    import httplib as http_client
#http_client.HTTPConnection.debuglevel = 1
#
#logging.basicConfig()
#logging.getLogger().setLevel(logging.DEBUG)
#requests_log = logging.getLogger("requests.packages.urllib3")
#requests_log.setLevel(logging.DEBUG)
#requests_log.propagate = True

VAULT_INIT_URL='http://vault-0.vault-internal:8200/v1/sys/init'
VAULT_INIT_JSON={'recovery_shares': 5, 'recovery_threshold': 3}
init_request = requests.post(url=VAULT_INIT_URL, json=VAULT_INIT_JSON)

TOKEN_URL='http://169.254.169.254/metadata/identity/oauth2/token'
TOKEN_PARAMS={'api-version': '2018-02-01','resource': 'https://vault.azure.net'}
TOKEN_URL_HEADERS={'Metadata': 'true'}
token_request = requests.get(url=TOKEN_URL, params=TOKEN_PARAMS, headers=TOKEN_URL_HEADERS)
access_token = token_request.json()['access_token']

AZURE_VAULT_URL='${azure_vault_url}/secrets/${azure_vault_secret}'
AZURE_VAULT_PARAMS={'api-version': '7.0'}
AZURE_VAULT_HEADERS={'Authorization': "Bearer %s" % (access_token)}
AZURE_VAULT_JSON={'value': "%s" % (init_request.json())}

azure_vault_request = requests.put(url=AZURE_VAULT_URL, params=AZURE_VAULT_PARAMS, headers=AZURE_VAULT_HEADERS, json=AZURE_VAULT_JSON)