#!/usr/bin/env node

var spawn = require('child_process').spawn

var child = spawn(
  require('../'),
  process.argv.slice(2),
  {stdio: 'inherit'}
)

child.on('exit', process.exit)

;['SIGINT', 'SIGTERM'].forEach(function(signal) {
  process.on(signal, function() {
    child.kill(signal);
  })
})
