var request = require('request')
var tar = require('tar-fs')
var gunzip = require('gunzip-maybe')
var path = require('path')

exports.packageDir = path.join(__dirname, '..')

exports.runRequestImpl = function(url) {
  return function() {
    return request(url)
  }
}

exports.tar2fs = function(dir) {
  return function() {
    return tar.extract(dir)
  }
}

exports.gzipMaybe = function() {
  return gunzip()
}
