"use strict"

module.exports = (oio) ->
	base = oio.getOAuthdURL()
	$ = oio.getJquery()

	return {
		get: (url, params, cb) =>
			$.ajax
				url: base + url
				type: 'get'
				data: params
				success: cb
				error: cb
		post: (url, params, cb) =>
			$.ajax
				url: base + url
				type: 'post'
				data: params
				success: cb
				error: cb
		put: (url, params, cb) =>
			$.ajax
				url: base + url
				type: 'put'
				data: params
				success: cb
				error: cb
		del: (url, params, cb) =>
			$.ajax
				url: base + url
				type: 'delete'
				data: params
				success: cb
				error: cb
	}