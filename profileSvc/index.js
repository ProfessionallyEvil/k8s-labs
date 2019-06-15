import restify from 'restify'

var server = restify.createServer({ name: 'authService' })

server.use(restify.acceptParser(server.acceptable))
server.use(restify.authorizationParser())
server.use(restify.bodyParser())

server.get('/', (res, req, next) => {
  res.send('Hello profile service')
})
