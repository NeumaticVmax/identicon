const express = require('express')
const router = express.Router()
const request = require('request')

const dnmonster = 'http://dnmonster:8080/monster/'

router.get('/:name', (req, res, next) => {
  const dnmonsterOpts = {
    url: dnmonster + req.params.name,
    qs: {size: '80'},
    encoding: null
  }
  request.get(dnmonsterOpts, (error, response, image) => {
    if (!error && response.statusCode === 200) {
      res.set({'Content-Type': 'image/png'})
      res.status(200).send(image)
    } else {
      console.log('Error: ' + response.statusCode)
      res.send('NG')
    }
  })
})
module.exports = router
