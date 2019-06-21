const restify = require('restify')
const mongoose = require('mongoose')
const Minio = require('minio')
const minioClient = new Minio.Client({
  endPoint: 'simplestoragesvc',
  port: 9000,
  useSSL: false,
  accessKey: process.env.MINIO_ACCESS_KEY,
  secretKey: process.env.MINIO_SECRET_KEY
})
const authorizer = require('./middleware/authorizer')

var server = restify.createServer({ name: 'profileService' })

const Author = mongoose.model('Author', new mongoose.Schema({
  name: { type: String, index: true, unique: true },
  signature: String,
  avatar: String,
  following: Array
}))

server.use(restify.plugins.acceptParser(server.acceptable))
server.use(restify.plugins.authorizationParser())
server.use(restify.plugins.bodyParser())

server.get('/:author', authorizer, async (req, res, next) => {
  await Author.findOne({ name: req.params.author }, 'name signature following').exec().then((author) => {
    res.json(200, author)
  })
})

server.get('/:author/avatar', authorizer, async (req, res, next) => {
  let stat = await minioClient.statObject('arrrspace-avatars', req.params.author).catch((err) => {
    res.json(400, { message: err })
  })
  minioClient.getObject('arrrspace-avatars', req.params.author, (err, stream) => {
    if (err) {
      console.error(err)
      res.json(400, { message: err })
    } else {
      res.setHeader('Content-Type', stat.metaData.type)
      stream.pipe(res)
    }
  })
})

server.post('/:author/avatar', async (req, res, next) => {
  minioClient.fPutObject('arrrspace-avatars', req.params.author, req.files.avatar.path, {
    type: req.files.avatar.type,
    lastModified: req.files.avatar.lastModifiedDate
  }, (err, etag) => {
    if (err) {
      res.send(400)
    } else {
      res.json(200, { etag: etag })
    }
  })
})

mongoose.connect('mongodb://dbase:27017', { useNewUrlParser: true, dbName: 'arrrspace', user: 'root', pass: 'toor', auth: { authdb: 'admin' }, reconnectTires: 20, reconnectInterval: 1000 })

server.listen(3000, async function () {
  await seedData()
  console.log('%s listening at %s', server.name, server.url)
})

async function seedData () {
  minioClient.makeBucket('arrrspace-avatars', 'us-east-1')
  await Author.deleteMany()
  let author = new Author({
    name: 'yondu',
    signature: `I'm Mary Poppins y'all`,
    avatar: '',
    following: []
  })
  author.save()
}
