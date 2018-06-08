const express = require('express')
const router = express.Router()
const request = require('request')
const redis = require('redis')
const Buffer = require('safe-buffer').Buffer

const dnmonster = 'http://dnmonster:8080/monster/'

const cache = redis.createClient({
  host: 'redis',
  detect_buffers: true,
  retry_strategy: (options) => {
    if (options.attempt > 2) return undefined
    return Math.min(options.attempt * 100, 3000)
  }
})

cache.on('connect', () => {
  console.log('Redis DB Connected.')
})

cache.on('error', (err) => {
  console.log('Redis DB Error: ' + err)
})

router.get('/:name', (req, res, next) => {
  const dnmonsterOpts = {
    url: dnmonster + req.params.name,
    qs: {size: '80'},
    encoding: null
  }
  cache.get(new Buffer(req.params.name), (err, image) => {
    if (image === null) {
      console.log('キャッシュミス')
      request.get(dnmonsterOpts, (error, response, image) => {
        if (!error && response.statusCode === 200) {
          if (!err) {
            // キャッシュに登録する
            cache.set(req.params.name, image, 'EX', 10)
          }
          res.set({'Content-Type': 'image/png'})
          res.status(200).send(image)
        } else {
          console.log('Error' + response.statusCode)
          res.send('NG')
        }
      })
    } else {
      console.log('キャッシュヒット')
      res.set({'Content-Type': 'image/png'})
      res.status(200).send(image)
    }
  })
})
module.exports = router
