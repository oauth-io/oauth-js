"use strict"

module.exports = (oio) ->
	base = oio.getOAuthdURL()
	$ = oio.getJquery()
	return {
		get: (url, params) =>
			$.ajax
				url: base + url
				type: 'get'
				data: params
		post: (url, params) =>
			$.ajax
				url: base + url
				type: 'post'
				data: params
		put: (url, params) =>
			$.ajax
				url: base + url
				type: 'put'
				data: params
		del: (url, params) =>
			$.ajax
				url: base + url
				type: 'delete'
				data: params
	}