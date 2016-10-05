do ->
	jquery = require('./tools/jquery-lite.js')

	OAuthio = require('./lib/core') window, document, jquery, navigator
	OAuthio.extend 'OAuth', require('./lib/oauth')
	OAuthio.extend 'API', require('./lib/api')
	OAuthio.extend 'User', require('./lib/user')

	if angular?
		angular.module 'oauthio', []
			.factory 'OAuth', [() ->
				return OAuthio.OAuth
			]
			.factory 'User', [() ->
				return OAuthio.User
			]

	exports.OAuthio = OAuthio
	window.User = exports.User = exports.OAuthio.User
	window.OAuth = exports.OAuth = exports.OAuthio.OAuth

	if (typeof define == 'function' && define.amd)
		define -> exports
	if (module?.exports)
		module.exports = exports

	return exports