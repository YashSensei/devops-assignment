const http=require('node:http');
http.createServer((req,res)=>{res.writeHead(200,{'Content-Type':'text/html'});res.end('<h1>Hello World from Node.js</h1><p>Yash Agrawal · 24bcs10164</p>');}).listen(8080,'0.0.0.0');
