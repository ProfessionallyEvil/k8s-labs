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

server.get('/by/:author/:page?', async (req, res, next) => {
  console.log(`Get posts by ${req.params.author}`)
  // let result = await Post.find({ author: req.params.author }).limit(10).skip(toPage(req.params.page) * 10).exec()
  // console.log('query result', result)
  // res.json(200, result)
})

mongoose.connect('mongodb://dbase:27017', { useNewUrlParser: true, dbName: 'arrrspace', user: 'root', pass: 'toor', auth: { authdb: 'admin' }, reconnectTires: 20, reconnectInterval: 1000 })

server.listen(3000, async function () {
  await seedData()
  console.log('%s listening at %s', server.name, server.url)
})

function toPage (pageParam) {
  pageParam = Number(pageParam)
  if (isNaN(pageParam) || pageParam < 0) {
    pageParam = 1
  }
  return pageParam.toFixed(0)
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
