$(function() {
	$('#result').hide();

	var providers = ["soundcloud","orkut","google_groups","google_play","ohloh","bitly","google_audit","google_urlshortener","google_apps","instagram","youtube","google_enterprise_licence_manager","linkedin","wordpress","live","google_bigquery","disqus","dailymotion","vk","500px","miso","twitter","google_cloud","dailymile","google_analytics","fitbit","google_blogger","23andme","google_latitude","google_adexchange","imgur","google_prediction","eventbrite","vimeo","trello","google_site","google_calendar","yammer","box","runkeeper","github","google_plus","behance","flickr","google_affiliate_network","google_documents","stackexchange","bitbucket","meetup","foursquare","assembla","google_fusiontables","skyrock","google","google_maps","google_shopping","deezer","google_drive","facebook","google_adsense","freebase","google_contact","google_books","mailchimp","cheddar","google_dfareporting","plurk","tumblr","google_tasks","deviantart","dropbox","tripit"]
	var sample_providers = ["facebook", "twitter", "github", "stackexchange", "soundcloud", "youtube", "tumblr", "instagram", "linkedin"];
	var provider = sample_providers[0];

	function update_code(option, provider) {
		var popup_code = "<span style=\"color: #777\">// Initialize with your OAuth.io app public key</span>\n" +
			"OAuth.initialize('<strong>Public key</strong>');\n" +
			"OAuth.popup('<span class=\"provider\" style=\"color: #428bca; font-weight: bold\">" + provider + "</span>', function(<span style=\"color: red; font-weight: bold\">error</span>, <span style=\"color: orange; font-weight: bold\">success</span>){\n" +
			"  <span style=\"color: #777\">// See the result below</span>\n" +
			"});\n\n\n\n\n ";

		var redirect_code = "<span style=\"color: #777\">// Initialize with your OAuth.io app public key</span>\n" +
			"OAuth.initialize('<span class=\"text-success\"><strong>Public key</strong></span>');\n" +
			"<span style=\"color: #777\">// callback_url is the URL where users are redirected</span>\n" +
			"<span style=\"color: #777\">// after being authorized</span>\n" +
			"OAuth.redirect('<span class=\"provider\" style=\"color: #428bca; font-weight: bold\">" + provider + "</span>', '<strong>callback_url</strong>');\n\n" +
			"<span style=\"color: #777\">// In callback URL</span>\n" +
			"OAuth.callback('<span class=\"provider\" style=\"color: #428bca; font-weight: bold\">" + provider + "</span>', (<span style=\"color: red; font-weight: bold\">error</span>, <span style=\"color: orange; font-weight: bold\">success</span>) { \n" +
			"  <span style=\"color: #777\">// See the result below</span>\n" +
			"});";

		if (option == 'Popup')
		    $('#code').html(popup_code);
		else
		    $('#code').html(redirect_code);
	}

    var oauthProvider = 'facebook'

	// Callback for redirect method
    OAuth.callback(function (error, success) {
		if (error) {
			oauthProvider = "the provider"
			$('#error-text').show().find('span').html(oauthProvider);
		}
		else {
			oauthProvider = success.provider
			$('#success-text').show().find('span').html(oauthProvider)
		}
		$('#result').html("success = " + JSON.stringify(success, undefined, 2) + "\n\nerror = " + JSON.stringify(error, undefined, 2)).show();
		$('#popup_method').removeClass('active');
		$('#redirect_method').addClass('active');
		update_code('Redirect', oauthProvider);
		$('#placeholder-result').hide();
		$('.provider').html(success.provider);
    });


    // Initialize OAuth with the public key
    OAuth.initialize('qb24rqcWu7g5eAUJ2IU6px8WkYE');

    $('#oauth-connect button').click(function(e) {
		e.preventDefault();

		var oauthMethod = $('#provider_actions .btn-group .active').text();
		oauthProvider = $(this).attr('data-provider')

		//display the code sample code in the <pre>
		update_code(oauthMethod, oauthProvider);

		//if popup is selected
		if (oauthMethod == 'Popup')
		{
			//we authorize user using the popup mode
			$('#success-text, #error-text').hide()
			$('#placeholder-result').hide();
			OAuth.popup(oauthProvider, function(error, success) {
				if (error) {
					$('#error-text').show().find('span').html(oauthProvider);
				}
				else {
					$('#success-text').show().find('span').html(oauthProvider)
				}
				$('#result').html("success = " + JSON.stringify(success, undefined, 2) + "\n\nerror = " + JSON.stringify(error, undefined, 2)).show();
			});
		}
		else {
			//we authorize user using the redirect mode
			OAuth.redirect(oauthProvider, "http://oauth-io.github.io/oauth-js");
		}
    });

    $('#oauth-connect button').mouseenter(function() {
    	$('.provider:not(.stay)').html($(this).attr('data-provider'))
    }).mouseleave(function() {
    	$('.provider:not(.stay)').html(oauthProvider)
    })

    //add provider list after the demonstration
	$.each(providers, function(index, value) {
		var srcImg = "https://oauth.io/api/providers/" + value + "/logo";
		var providers_container;

		if (index % 15 == 0)
			$('#providers').append("<div class='row'></div>");

		value = value.replace(/_/g, ' ')
		$('#providers').append("<img data-toggle='tooltip' title data-original-title='" + value + "' style='margin: 4px;' src='" + srcImg + "' width='28'/>");
	});

	$('#providers img').tooltip();
	$('#provider_actions .btn-group button').click(function(e) {
		$("#result").hide();
		$('#placeholder-result').show();
		$('#success-text, #error-text').hide();
		update_code($(this).text(), provider);
	});
});
