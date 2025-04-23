# Access the API:

## start server

```
uvicorn rag:app --reload --host 0.0.0.0 --port 8000
```

## search

```
POST http://localhost:8000/search
Accept: application/application/json

{
    "query": "How to increase woman's sexual desire",
    "k": 5
}
```