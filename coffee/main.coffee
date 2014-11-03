(->
	jquery = require('./tools/jquery-lite.js')

	window.oio = require('./lib/core') window, document, jquery, navigator
	window.oio.extend 'OAuth', require('./lib/oauth')
	window.oio.extend 'API', require('./lib/api')
	window.oio.extend 'User', require('./lib/user')
	window.OAuth = window.oio.OAuth
)()