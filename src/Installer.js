var got = require('got')
var tar = require('tar-fs')
var gunzip = require('gunzip-maybe')
var path = require('path')

exports.packageDir = path.join(__dirname, '..')

exports.createDownloadStream = function(url) {
  return function() {
    return got.stream(url)
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
