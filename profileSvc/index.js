const restify = require('restify')

var server = restify.createServer({ name: 'profileService' })

server.use(restify.plugins.acceptParser(server.acceptable))
server.use(restify.plugins.authorizationParser())
server.use(restify.plugins.bodyParser())

server.use((req, res, next) => {
// console.log('Request received: ', req)
  return next()
})

server.get('/:id', (req, res, next) => {
  res.send(`Showing profile for ${req.params.id}`)
})

server.listen(3000, function () {
  console.log('%s listening at %s', server.name, server.url)
})
