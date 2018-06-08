const express = require('express')
const router = express.Router()
const sechash = require('sechash')
const defaultName = 'hoge foo'
const title = 'Your identicon'

function render (res, name) {
  const nameHash = sechash.basicHash('sha1', name)
  res.render('index', {
    title: title,
    name: name,
    nameHash: nameHash
  })
}

/* GET home page. */
router.get('/', (req, res, next) => {
  const name = defaultName
  render(res, name)
})

router.post('/', (req, res, next) => {
  const name = req.body.name
  render(res, name)
})
module.exports = router
