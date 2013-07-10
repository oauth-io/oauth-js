Installation
============

In the `<head>` of your HTML, include OAuth.js

`<script src="/path/to/OAuth.js"></script>`

In your Javascript, add this line to initialize OAuth.js

`OAuth.initialize('Public key');`

Usage
=====

To connect your user using facebook, 2 methods:

Mode popup
----------

 ```javascript
//Using popup (option 1)
OAuth.popup('facebook', function(err, result) {
  //handle error with err
  //use result.access_token in your API request
});
 ```

Mode redirection
----------------

 ```javascript
//Using redirection (option 2)
OAuth.redirect('facebook', "callback/url");
 ```

In callback url :

 ```javascript
OAuth.callback('facebook', function(err, result) {
  //handle error with err
  //use result.access_token in your API request
});
 ```

Examples
========

* [GitHub create and delete repositories](https://github.com/pcoder/oauth-js/tree/gh-pages): This example ([github-create-delete-repo.html](https://github.com/pcoder/oauth-js/blob/gh-pages/github-create-delete-repo.html)) shows how oauth.io can be used to create/delete repositories from a user's GitHub account.

More information in [oauth.io documentation](http://oauth.io/#/docs)
