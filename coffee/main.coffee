do ->
	jquery = require('./tools/jquery-lite.js')

	Materia = require('./lib/core') window, document, jquery, navigator
	Materia.extend 'OAuth', require('./lib/oauth')
	Materia.extend 'API', require('./lib/api')
	Materia.extend 'User', require('./lib/user')

	if angular?
		angular.module 'oauthio', []
			.factory 'Materia', [() ->
				return Materia
			]
			.factory 'OAuth', [() ->
				return Materia.OAuth
			]
			.factory 'User', [() ->
				return Materia.User
			]

	window.Materia = exports.Materia = Materia
	window.User = exports.User = exports.Materia.User
	window.OAuth = exports.OAuth = exports.Materia.OAuth

	if (typeof define == 'function' && define.amd)
		define -> exports
	if (module?.exports)
		module.exports = exports

	return exports