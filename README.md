Installation
============

In the `<head>` of your HTML, include OAuth.js

`<script src="/path/to/OAuth.js"></script>`

In your Javascript, add this line to initialize OAuth.js

`OAuth.initialize('App public key');`

Usage
=====

To connect your user using facebook, 2 methods:

Mode popup
----------

 ```javascript
//Using popup (option 1)
OAuth.popup('facebook')
.done(function(result) {
  //use result.access_token in your API request 
  //or use result.get|post|put|del|patch|me methods (see below)
})
.fail(function (err) {
  //handle error with err
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
OAuth.callback('facebook')
.done(function(result) {
    //use result.access_token in your API request
    //or use result.get|post|put|del|patch|me methods (see below)
})
.fail(function (err) {
    //handle error with err
});
 ```

Making requests
---------------

You can make requests to the provider's API manually with the access token you got from the `popup` or `callback` methods, or use the request methods stored in the `result` object.

**GET Request**

To make a GET request, you have to call the `result.get` method like this :

```javascript
//Let's say the /me endpoint on the provider API returns a JSON object
//with the field "name" containing the name "John Doe"
OAuth.popup('aprovider')
.done(function(result) {
    result.get('/me')
    .done(function (response) {
        //this will display "John Doe" in the console
        console.log(response.name);
    })
    .fail(function (err) {
        //handle error with err
    });
})
.fail(function (err) {
    //handle error with err
});
```

**POST Request**

To make a POST request, you have to call the `result.post` method like this :

```javascript
//Let's say the /message endpoint on the provider waits for
//a POST request containing the fields "user_id" and "content"
//and returns the field "id" containing the id of the sent message 
OAuth.popup('aprovider')
.done(function(result) {
    result.post('/message', {
        data: {
            user_id: 93,
            content: 'Hello Mr. 93 !'
        }
    })
    .done(function (response) {
        //this will display the id of the message in the console
        console.log(response.id);
    })
    .fail(function (err) {
        //handle error with err
    });
})
.fail(function (err) {
    //handle error with err
});
```

**PUT Request**

To make a PUT request, you have to call the `result.post` method like this :

```javascript
//Let's say the /profile endpoint on the provider waits for
//a PUT request to update the authenticated user's profile 
//containing the field "name" and returns the field "name" 
//containing the new name
OAuth.popup('aprovider')
.done(function(result) {
    result.put('/message', {
        data: {
            name: "John Williams Doe III"
        }
    })
    .done(function (response) {
        //this will display the new name in the console
        console.log(response.name);
    })
    .fail(function (err) {
        //handle error with err
    });
})
.fail(function (err) {
    //handle error with err
});
```

**PATCH Request**

To make a PATCH request, you have to call the `result.patch` method like this :

```javascript
//Let's say the /profile endpoint on the provider waits for
//a PATCH request to update the authenticated user's profile 
//containing the field "name" and returns the field "name" 
//containing the new name
OAuth.popup('aprovider')
.done(function(result) {
    result.patch('/message', {
        data: {
            name: "John Williams Doe III"
        }
    })
    .done(function (response) {
        //this will display the new name in the console
        console.log(response.name);
    })
    .fail(function (err) {
        //handle error with err
    });
})
.fail(function (err) {
    //handle error with err
});
```

**DELETE Request**

To make a DELETE request, you have to call the `result.del` method like this :

```javascript
//Let's say the /picture?id=picture_id endpoint on the provider waits for
//a DELETE request to delete a picture with the id "84"
//and returns true or false depending on the user's rights on the picture
OAuth.popup('aprovider')
.done(function(result) {
    result.del('/picture?id=84')
    .done(function (response) {
        //this will display true if the user was authorized to delete
        //the picture
        console.log(response);
    })
    .fail(function (err) {
        //handle error with err
    });
})
.fail(function (err) {
    //handle error with err
});
```

**Me() Request**

The `me()` request is an OAuth.io feature that allows you, when the provider is supported, to retrieve a unified object describing the authenticated user. That can be very useful when you need to login a user via several providers, but don't want to handle a different response each time.

To use the `me()` feature, do like the following (the example works for Facebook, Github, Twitter and many other providers in this case) :

```javascript
OAuth.popup('aprovider')
.done(function(result) {
    result.me(['firstname', 'lastname'])
    .done(function (response) {
        //this will display true if the user was authorized to delete
        //the picture
        console.log(response);
    })
    .fail(function (err) {
        //handle error with err
    });
})
.fail(function (err) {
    //handle error with err
});
```

More information in [oauth.io documentation](http://oauth.io/#/docs)