import requests, json
url='http://127.0.0.1:8005/chat'
payload={
 'session_id':'test-session',
 'query':'What are the main findings?'
}
try:
    r = requests.post(url,json=payload,timeout=60)
    print('status',r.status_code)
    print(json.dumps(r.json(),indent=2))
except Exception as e:
    print('error',e)
