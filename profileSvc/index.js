const restify = require('restify')

var server = restify.createServer({ name: 'authService' })

server.use(restify.plugins.acceptParser(server.acceptable))
server.use(restify.plugins.authorizationParser())
server.use(restify.plugins.bodyParser())

server.use((req, res, next) => {
  console.log('Request received: ', req)
  return next()
})

server.get('/bar', (res, req, next) => {
  res.send('Hello profile service')
})
