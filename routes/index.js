const express = require('express')
const router = express.Router()
const defaultName = 'hoge foo'

/* GET home page. */
router.get('/', function (req, res, next) {
  const name = defaultName
  res.render('index', {
    title: 'Your identicon',
    name: name})
})

module.exports = router
