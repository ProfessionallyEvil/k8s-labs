const path = require('path');
const gateway = require('express-gateway');
const http = require('http');
const httpProxy = require('http-proxy')
const url = require('url');

gateway()
  .load(path.join(__dirname, 'config'))
  .run();

const proxy = httpProxy.createProxyServer({});
const server = http.createServer(function (req, res) {
  // contruct the URL to proxy to
  console.log(req.headers); 
  if (!req.headers['x-original-host']) {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end('{"msg": "this is an API, welcome.", "status": 200}');
    return;
  }
  const path = (req.headers['x-original-url'] ? req.headers['x-original-url'] : '/');
  const targetUrl = url.parse(req.headers['x-original-host'] + path);
  console.log(targetUrl);
  console.log(targetUrl.href);
  // otherwise proxy the request and response

  let opts = {
    target: (targetUrl.protocol === null ? 'http://' + targetUrl.href : targetUrl.href)
  };

  console.log(opts);
  proxy.web(req, res, opts, function (e) {
    console.log(e);
    res.writeHead(500, {
      'Content-Type': 'text/plain'
    });
    res.end(e.toString());
  });
});
server.listen(9100);