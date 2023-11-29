const express = require(`express`);
const PORT = 80;   // You can change this
var app = express(); // start a web server running on port 5000

// Listen for requests on the root page (/) 
// Send Hello world! as the response
app.get(`/`, (req, res) => {     
  res.send(`Hello world!`);
});

app.listen(PORT, () => {
  console.log(`Listening on port ${PORT}.`);
});