const restify = require('restify')

var server = restify.createServer({ name: 'authService' })

server.use(restify.plugins.acceptParser(server.acceptable))
server.use(restify.plugins.authorizationParser())
server.use(restify.plugins.bodyParser())

server.get('/', (res, req, next) => {
  res.send('Hello feed service')
})

server.listen(3000, function () {
  console.log('%s listening at %s', server.name, server.url)
})
