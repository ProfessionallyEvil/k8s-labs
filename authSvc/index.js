const restify = require('restify')
const OAuthServer = require('restify-oauth-server')
const mongoose = require('mongoose')
const crypto = require('crypto')
const uuid = require('uuid/v4')
const jwt = require('json-web-token')

const User = mongoose.model('User', new mongoose.Schema({
  email: { type: String, index: true, unique: true },
  password: String,
  salt: String,
  defaultAuthor: String
}))

var server = restify.createServer({ name: 'authService' })

server.oauth = new OAuthServer({
  model: {
    getClient: function() {
      console.log('getClient()');
    }
  }
})

server.use(restify.plugins.acceptParser(server.acceptable))
server.use(restify.plugins.authorizationParser())
server.use(restify.plugins.bodyParser())

// Node Oauth2 Server expects the token request to be x-www-url-formencoded according to the Oauth2 spec
// Restify's body parser puts formencoded params in req.params, so we'll need a quick little bit of middleware to copy them over to the body
server.use((req, res, next) => {
  if (req.headers['content-type'] === 'application/x-www-url-formencoded') {
    req.body = req.params
  }
  return next()
})

server.post('/legacy/register', (req, res, next) => {
  let salt = uuid()
  let pwdhash = hashPassword(req.body.password, salt)
  let user = new User({
    email: req.body.email,
    password: pwdhash,
    salt: salt,
    defaultAuthor: req.body.author
  })
  user.save().then(() => {
    res.json(200, { message: 'registered' })
  })
})

server.post('/legacy/login', (req, res, next) => {
  User.findOne({ email: req.body.email }).then((user) => {
    if (user.password === hashPassword(req.body.password, user.salt)) {
      res.json(200, { message: 'Login success', token: generateAuthToken(user) })
    } else {
      console.warn('Password mismatch for ', req.body.email)
      res.json(401, { message: 'Invalid credentials' })
    }
  }).catch(() => {
    console.warn('User lookup failed for ', req.body.email)
    res.json(401, { message: 'Invalid credentials' })
  })
})

server.post('/token', server.oauth.token())

server.get('/secret', server.oauth.authenticate(), (req, res, next) => {
  res.send('Authenticated!')
})

mongoose.connect('mongodb://dbase:27017', { useNewUrlParser: true, dbName: 'arrrspace', user: 'root', pass: 'toor', auth: { authdb: 'admin' }, reconnectTires: 20, reconnectInterval: 1000 })

server.listen(3000, async function () {
  await seedData()
  console.log('%s listening at %s', server.name, server.url)
})

async function seedData () {
  await User.deleteMany()
  let salt = uuid()
  let user = new User({
    email: 'yondu@ravager.net',
    password: hashPassword('umbrella', salt),
    salt: salt,
    defaultAuthor: 'yondu'
  })
  user.save()
}

function hashPassword (password, salt) {
  return crypto.createHash('sha256').update(password + '__' + salt).digest('base64')
}

function generateAuthToken (user, admin = false) {
  return jwt.encode(process.env.LEGACY_AUTH_SECRET, {
    iss: 'arrrspace_legacy',
    aud: 'arrrspace',
    iat: Number(Date.now()),
    admin: admin,
    email: user.email,
    author: user.defaultAuthor
  }).value
}
