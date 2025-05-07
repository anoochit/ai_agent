```
uv run adk api_server
```

or

```
uvicorn main:app --host 0.0.0.0
```

request session

```
curl -X POST http://127.0.0.1:8000/apps/query_agent/users/u_123/sessions/s_123 \
-H "Content-Type: application/json"
```

sent request to agent

```
curl -X POST http://127.0.0.1:8000/run \
-H "Content-Type: application/json" \
-d '{
"app_name": "query_agent",
"user_id": "u_123",
"session_id": "s_123",
"new_message": {
    "role": "user",
    "parts": [{
    "text": "Leonado Davinci self portrait in golden frame"
    }]
}
}'
```
