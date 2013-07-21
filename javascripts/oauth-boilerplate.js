$(function() {
	var providers = ["soundcloud","orkut","google_groups","google_play","ohloh","bitly","google_audit","google_urlshortener","google_apps","instagram","youtube","google_enterprise_licence_manager","linkedin","wordpress","live","google_bigquery","disqus","dailymotion","vk","500px","miso","twitter","google_cloud","dailymile","google_analytics","fitbit","google_blogger","23andme","google_latitude","google_adexchange","imgur","google_prediction","eventbrite","vimeo","trello","google_site","google_calendar","yammer","box","runkeeper","github","google_plus","behance","flickr","google_affiliate_network","google_documents","stackexchange","bitbucket","meetup","foursquare","assembla","google_fusiontables","skyrock","google","google_maps","google_shopping","deezer","google_drive","facebook","google_adsense","freebase","google_contact","google_books","mailchimp","cheddar","google_dfareporting","plurk","tumblr","google_tasks","deviantart","dropbox","tripit"]

	var sample_providers = ["facebook", "twitter", "github", "stackexchange", "soundcloud", "youtube", "tumblr", "instagram", "linkedin"];
	var provider = sample_providers[0];


	$.each(providers, function(index, value) {
		var srcImg = "https://oauth.io//auth/api/providers/" + value + "/logo";
		var providers_container;

		if (index % 15 == 0)
			$('#providers').append("<div class='row'></div>");

		value = value.replace(/_/g, ' ')
		$('#providers').append("<img data-toggle='tooltip' title data-original-title='" + value + "' style='margin: 4px;' src='" + srcImg + "' width='28'/>");
	});

	$('#providers img').tooltip();
	$('#result').hide();

	$('#provider_actions .btn-group button').click(function(e) {
		$("#result").hide();
		$('#placeholder-result').show();
		$('#success-text, #error-text').hide();
		update_code($(this).text(), provider);
	});
	function update_code(option, provider) {
		var popup_code = "// Initialize with your OAuth.io app public key\n" +
			"OAuth.initialize('<b>Public key</b>');\n" +
			"OAuth.popup('<span class='provider'>" + provider + "</span>', function(error, success){\n" +
			"  // See the result below\n" +
			"});\n\n\n\n\n ";

		var redirect_code = "// Initialize with your OAuth.io app public key\n" +
			"OAuth.initialize('<b>Public key</b>');\n" +
			"// callback_url is the URL where users are redirected \n" +
			"// after being authorized\n" +
			"OAuth.redirect('<span class=\"provider\">" + provider + "</span>', 'callback_url');\n\n" +
			"// In callback URL\n" +
			"OAuth.callback('<span class=\"provider\">" + provider + "</span>', (error, success) { \n" +
			"  // See the result below\n" +
			"});";

		if (option == 'Popup')
		    $('#code').html(popup_code);
		else
		    $('#code').html(redirect_code);
	}

	// Callback for redirect method
    OAuth.callback(function (error, success) {
		if (error) {
			$('#result').html(JSON.stringify(error, undefined, 2));
		}
		else {
			$('#result').html(JSON.stringify(success, undefined, 2));
		}

		$('#popup_method').removeClass('active');
		$('#redirect_method').addClass('active');
		$('#provider_actions .btn-group .active').trigger('click');
		$('.provider').html(success.provider);
		$('#result').show();
    });


    // Initialize OAuth with the public key
    OAuth.initialize('qb24rqcWu7g5eAUJ2IU6px8WkYE');

    $('#oauth-connect button').click(function(e) {
		e.preventDefault();

		var oauthMethod = $('#provider_actions .btn-group .active').text();
		var oauthProvider = $(this).attr('data-provider')

		//display the code sample code in the <pre>
		update_code(oauthMethod, oauthProvider);

		//if popup is selected
		if (oauthMethod == 'Popup')
		{
			//we authorize user using the popup mode
			OAuth.popup(oauthProvider, function(error, success) {
				$('#placeholder-result').hide();
				if (success) {
					$('#result').html(JSON.stringify(success, undefined, 2));
					$('#success-text').show().find('span').html(oauthProvider)
				}
				else {
					$('#result').html(JSON.stringify(error, undefined, 2));
					$('#success-text').show().find('span').html(oauthProvider);
				}
				$('#result').show();
			});
		}
		else {
			//we authorize user using the redirect mode
			OAuth.redirect(oauthProvider, 'http://oauth-io.github.io/oauth-js');
		}
    });
});