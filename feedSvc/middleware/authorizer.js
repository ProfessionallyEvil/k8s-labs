const jwt = require('json-web-token')

module.exports = function async (req, res, next) {
  let authHeader = req.header('Authorization', '')
  let token = authHeader.split(' ')[1]
  if (!token) {
    res.json(401, { message: 'Unauthorized' })
  } else {
    jwt.decode(process.env.LEGACY_AUTH_SECRET, token, (err, payload, header) => {
      if (err) {
        console.warn('Unable to decode token ', token)
        res.json(401, { message: 'Unauthorized' })
      } else {
        let tokenLife = Number(Date.now()) - payload.iat
        if (tokenLife > 300000) {
          console.log('Expired token ', token)
          res.json(401, { message: 'Token is Expired' })
        } else {
          req.user = {
            email: payload.email,
            admin: payload.admin,
            author: payload.author
          }
          return next()
        }
      }
    })
  }
}
