const restify = require('restify')
const mongoose = require('mongoose')

const Post = mongoose.model('Post', new mongoose.Schema({
  author: String,
  message: String,
  timestamp: Date,
  replies: Array
}))

var server = restify.createServer({ name: 'feedService' })

server.use(restify.plugins.acceptParser(server.acceptable))
server.use(restify.plugins.authorizationParser())
server.use(restify.plugins.bodyParser())

server.use((req, res, next) => {
  console.log('request received:', req.url)
  return next()
})

server.use(require('./middleware/authorizer'))

server.get('/by/:author/:page', async (req, res, next) => {
  await Post.find({ author: req.params.author }, '_id author message timestamp').sort({ timestamp: 'desc' }).limit(10).skip(toPage(req.params.page) * 10).exec().then((data) => {
    res.json(200, data)
  })
})

server.post('/', async (req, res, next) => {
  if (req.body.message) {
    await new Post({
      author: req.body.author || req.user.author,
      message: req.body.message,
      timestamp: Date.now(),
      replies: []
    }).save().then(() => {
      res.json(200, { message: 'posted' })
    })
  } else {
    res.json(400, { message: 'author and message are required fields' })
  }
})

mongoose.connect('mongodb://dbase:27017', { useNewUrlParser: true, dbName: 'arrrspace', user: 'root', pass: 'toor', auth: { authdb: 'admin' }, reconnectTires: 20, reconnectInterval: 1000 })

server.listen(3000, async function () {
  await seedData()
  console.log('%s listening at %s', server.name, server.url)
})

function toPage (pageParam) {
  let page = Number(pageParam)
  if (isNaN(page) || page < 0) {
    return 0
  }
  return page.toFixed(0)
}

async function seedData () {
  await Post.deleteMany()
  let post = new Post({
    author: 'yondu',
    message: `Hey y'all`,
    timestamp: Date.now(),
    replies: []
  })
  post.save()
}
