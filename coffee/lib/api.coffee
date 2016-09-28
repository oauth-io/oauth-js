"use strict"

module.exports = (OAuthio) ->
	$ = OAuthio.getJquery()
	apiCall = (type, url, params) =>
		defer = $.Deferred()
		base = OAuthio.getOAuthdURL()
		opts = url: base + url, type: type
		if type == 'post' or type == 'put'
			opts.dataType = "json"
			opts.contentType = "application/json"
			opts.data = JSON.stringify(params)
		else
			opts.data = params
		$.ajax(opts).then(
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
