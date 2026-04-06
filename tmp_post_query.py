import requests
import json
url = 'http://127.0.0.1:8000/query'
payload = {
    'query': 'transformer attention mechanisms',
    'max_results': 3,
    'generate_citations': False,
    'eli5_mode': False,
    'execution_mode': 'single'
}
resp = requests.post(url, json=payload, timeout=120)
print('status', resp.status_code)
try:
    print(json.dumps(resp.json(), indent=2))
except Exception:
    print(resp.text)
