var fs = require('fs')
var path = require('path')

// note: required because the "post-install" hook always runs
if (fs.existsSync(path.join(__dirname, './dist'))) {
  require('./lib/installer').install()
}
