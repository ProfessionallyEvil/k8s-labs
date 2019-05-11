const restify = require('restify')
const OAuthServer = require('restify-oauth-server')

var server = restify.createServer({ name: 'authService' })

server.oauth = new OAuthServer({
  model: {}
})

server.use(restify.acceptParser(server.acceptable))
server.use(restify.authorizationParser())
server.use(restify.bodyParser())

// Node Oauth2 Server expects the token request to be x-www-url-formencoded according to the Oauth2 spec
// Restify's body parser puts formencoded params in req.params, so we'll need a quick little bit of middleware to copy them over to the body
server.use((req, res, next) => {
  if (req.headers['content-type'] === 'application/x-www-url-formencoded') {
    req.body = req.params
  }
  return next()
})

server.post('/token', server.oauth.token())

server.get('/secret', server.oauth.authenticate(), (req, res, next) => {
  res.send('Authenticated!')
})

server.listen(3000, function () {
  console.log('%s listening at %s', server.name, server.url)
})
