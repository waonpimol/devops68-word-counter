# Word Counter API

Count words and characters in text.

## Endpoint

### GET `/count`

**Parameters:**
- `text` (required): Text to analyze

**Example Request:**
```
http://localhost:3008/count?text=Hello%20World
```

**Example Response:**
```json
{
  "text": "Hello World",
  "words": 2,
  "characters": 11,
  "charactersNoSpace": 10
}
```
