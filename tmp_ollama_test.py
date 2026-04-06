import requests
url = 'http://127.0.0.1:11434/api/generate'
payload = {
    'model': 'llama3.2:3b',
    'prompt': 'Summarize the concept of attention in transformers in one sentence.'
}
try:
    r = requests.post(url, json=payload, timeout=30)
    print('status', r.status_code)
    print(r.text[:2000])
except Exception as e:
    print('error', e)
