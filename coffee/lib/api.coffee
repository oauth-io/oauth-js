"use strict"

module.exports = (oio) ->
	$ = oio.getJquery()
	return {
		get: (url, params) =>
			base = oio.getOAuthdURL()
			$.ajax
				url: base + url
				type: 'get'
				data: params
		post: (url, params) =>
			base = oio.getOAuthdURL()
			$.ajax
				url: base + url
				type: 'post'
				data: params
		put: (url, params) =>
			base = oio.getOAuthdURL()
			$.ajax
				url: base + url
				type: 'put'
				data: params
		del: (url, params) =>
			base = oio.getOAuthdURL()
			$.ajax
				url: base + url
				type: 'delete'
				data: params
	}