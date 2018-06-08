const express = require('express')
const router = express.Router()
const defaultName = 'hoge foo'
const title = 'Your identicon'

/* GET home page. */
router.get('/', (req, res, next) => {
  const name = defaultName
  res.render('index', {
    title: title,
    name: name})
})

router.post('/', (req, res, next) => {
  const name = req.body.name
  res.render('index', {
    title: title,
    name: name
  })
})
module.exports = router
