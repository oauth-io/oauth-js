"use strict"

module.exports = (Materia) ->
	$ = Materia.getJquery()
	apiCall = (type, url, params) =>
		defer = $.Deferred()
		base = Materia.getOAuthdURL()
		$.ajax(
			url: base + url
			type: type
			data: params
		).then(
			((data) => defer.resolve data),
			((err) => defer.reject err && err.responseJSON)
		)
		return defer.promise()
	
	return {
		get: (url, params) => apiCall 'get', url, params
		post: (url, params) => apiCall 'post', url, params
		put: (url, params) => apiCall 'put', url, params
		del: (url, params) => apiCall 'delete', url, params
	}
