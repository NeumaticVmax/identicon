const express = require('express')
const router = express.Router()
const sechash = require('sechash')
const defaultName = 'hoge foo'
const title = 'Your identicon'

/* GET home page. */
router.get('/', (req, res, next) => {
  const name = defaultName
  const nameHash = sechash.basicHash('sha1', name)
  res.render('index', {
    title: title,
    name: name,
    nameHash: nameHash
  })
})

router.post('/', (req, res, next) => {
  const name = req.body.name
  const nameHash = sechash.basicHash('sha1', name)
  res.render('index', {
    title: title,
    name: name,
    nameHash: nameHash
  })
})
module.exports = router
