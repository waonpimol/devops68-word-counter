const express = require('express');
const app = express();

app.get('/count', (req, res) => {
  const { text } = req.query;
  if (!text) return res.status(400).json({ error: 'Missing text parameter' });
  
  const words = text.trim().split(/\s+/).filter(w => w.length > 0).length;
  const chars = text.length;
  const charsNoSpace = text.replace(/\s/g, '').length;
  
  res.json({ text, words, characters: chars, charactersNoSpace: charsNoSpace });
});

app.listen(3008, () => console.log('Word Counter API on port 3008'));
