(->
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

	window.Materia = Materia
	window.User = window.Materia.User
	window.OAuth = window.Materia.OAuth
)()
