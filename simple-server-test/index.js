const express = require('express');
const app = express();
const port = 3000;

const appName = process.env.APP_NAME || 'DefaultApp';

app.get('/', (req,res) => {
    res.send(Hello from K3s - App name: ${appName});
});

app.listen(port, () => {
    console.log(App running on port ${port} and recieve req);
});


