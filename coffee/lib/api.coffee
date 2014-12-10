"use strict"

module.exports = (Materia) ->
	$ = Materia.getJquery()
	return {
		get: (url, params) =>
			base = Materia.getOAuthdURL()
			$.ajax
				url: base + url
				type: 'get'
				data: params
		post: (url, params) =>
			base = Materia.getOAuthdURL()
			$.ajax
				url: base + url
				type: 'post'
				data: params
		put: (url, params) =>
			base = Materia.getOAuthdURL()
			$.ajax
				url: base + url
				type: 'put'
				data: params
		del: (url, params) =>
			base = Materia.getOAuthdURL()
			$.ajax
				url: base + url
				type: 'delete'
				data: params
	}
