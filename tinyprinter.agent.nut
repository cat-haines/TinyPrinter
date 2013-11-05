// OAuth.io
const OAUTHIO_KEY = ""

allowAuth <- false;
OAuth <- {};

// Twitter
_CONSUMER_KEY <- ""
_CONSUMER_SECRET <- "";

// HTTP
BASE_URL <- http.agenturl();

/****************************** HTML ******************************/
const PAGE_TEMPLATE = @"
<!DOCTYPE html>
<html lang='en'>
    <head>
        <meta charset='utf-8'>
        <meta name='viewport' content='width=device-width, initial-scale=1.0'>
        <meta name='apple-mobile-web-app-capable' content='yes'>        

        <title>Electric Imp - [Tiny]Printer</title>

        <!-- Latest compiled and minified CSS -->
        <link rel='stylesheet' href='https://netdna.bootstrapcdn.com/bootstrap/3.0.1/css/bootstrap.min.css'>
        <link rel='stylesheet' href='https://netdna.bootstrapcdn.com/bootstrap/3.0.1/css/bootstrap-theme.min.css'>
        <style>
            .centered { text-align:center; padding:40px; }
            body {
              padding-top: 50px;
              padding-bottom: 20px;
            } 
        </style>
    </head>
    <body style=''>
        <div id='wrap'>
            <div class='navbar navbar-inverse navbar-fixed-top'>
              <div class='container'>
                <div class='navbar-header'>
                  <button type='button' class='navbar-toggle' data-toggle='collapse' data-target='.navbar-collapse'>
                    <span class='icon-bar'></span>
                    <span class='icon-bar'></span>
                    <span class='icon-bar'></span>
                  </button>
                  <a class='navbar-brand' href='#'>[Tiny]Printer</a>
                </div>
                <div class='navbar-collapse collapse'>
                  <div class='navbar-right navbar-form'>
                    <button id='login' onclick='login()' class='btn btn-success'>Sign in with Twitter</button>
                    <button id='logout' style='display: none;' onclick='logout()' class='btn btn-success'>Sign out</button>
                  </div>
                </div><!--/.navbar-collapse -->
              </div>
            </div>
            <div id='body'>%s</div>
        </div>
        <div id='messages' class='container'>
          <hr>
          <footer>
            <p>Powered by <a href='http://electricimp.com'>Electric Imp</a>.</p>
          </footer>
        </div>
        
        <!-- jQuery -->
        <script src='https://code.jquery.com/jquery-1.9.1.min.js'></script>
        <script src='https://code.jquery.com/jquery-migrate-1.2.1.min.js'></script>
        <!-- Latest compiled and minified JavaScript -->
        <script src='https://netdna.bootstrapcdn.com/bootstrap/3.0.1/js/bootstrap.min.js'></script>
        <!-- Oauth.io -->
        <script src='https://devious-dorris.gopagoda.com/assets/js/oauth.min.js'></script>
        <script>
            function logSuccess(title, message, autoclear) {
                autoclear = autoclear || true;
                var t = new Date().getTime();
                $('#messages').prepend('<div id=\'' + t + '\' class=\'alert alert-success\'><button type=\'button\' class=\'close\' data-dismiss=\'alert\'>x</button><strong>' + title + '</strong>&nbsp;' + message + '</div>');
                if (autoclear) {
                    window.setTimeout(function() { $('#' + t).alert('close'); }, 3000);
                }
            }

            function (title, message, autoclear) {
                autoclear = autoclear || true;
                var t = new Date().getTime();
                $('#messages').prepend('<div id =\'' + t + '\'class=\'alert alert-error\'><button type=\'button\' class=\'close\' data-dismiss=\'alert\'>x</button><strong>' + title + '</strong>&nbsp;' + message + '</div>');
                if (autoclear) {
                    window.setTimeout(function() { $('#' + t).alert('close'); }, 3000);
                }
            }

            var OAuthToken = null;
            var OAuthTokenSecret = null;
            
            OAuth.initialize('%s');
            
            function login() {
                OAuth.popup('twitter', function(err, result) {
                    if(!err) {
                        $.ajax({
                            url: '%s/auth',
                            data: { token: result.oauth_token, token_secret: result.oauth_token_secret },
                            method: 'POST',
                            success: function(response) {
                                OAuthToken = result.oauth_token;
                                OAuthTokenSecret = result.oauth_token_secret;
                                $('#login').css('display', 'none');
                                $('#logout').css('display', 'inline-block');
                                $('#body').html(response);
                            },
                            error: function (request, status, error) {
                                logError('Whoops!', 'Looks like someone is already logged into this printer. To enable a new user to login, power cycle the device and try logging in within 1 minute of the device coming online', false);
                            }
                        });
                    }
                });
            }
            
            function logout() {
                $.ajax({ 
                    url: '%s/logout',
                    data: { token: OAuthToken, token_secret: OAuthTokenSecret },
                    method: 'POST',
                    success: function(response) {
                        OAuthToken = null;
                        OAuthTokenSecret = null;
                        $('#logout').css('display', 'none');
                        $('#login').css('display', 'inline-block');
                        $('#body').html(response);
                    },
                    error: function (request, status, error) {
                        logError('Whoops!', 'Looks like someone is already logged into this printer. To enable a new user to login, power cycle the device and try logging in within 1 minute of the device coming online', false);
                    }
                });
            }
            
            function updateSettings() {
                var _searchTerm = $('#searchTerm')[0].value;
                $.ajax({ 
                    url: '%s/settings',
                    data: { token: OAuthToken, token_secret: OAuthTokenSecret, searchTerm: _searchTerm },
                    method: 'POST',
                    success: function(response) {
                        logSuccess('Success!', 'Your [Tiny]Printer has been updated.', false)
                    },
                    error: function (request, status, error) {
                        logError('Whoops!', request.responseText, false);
                    }
                });

            }
    
        </script>
    </body>
</html>"

const INDEX_HTML = @"
<div class='jumbotron'>
  <div class='container'>
    <h1>[Tiny]Printer</h1>
    <p>The [Tiny]Printer is an Internet connected device that creates a physical artifact from your Twitter account. Log in, select what you like the device to print, then sit back, and enjoy the show.</p>
    <p><a class='btn btn-primary btn-lg' role='button'>Build your own >></a></p>
  </div>
</div>      
";

const SETTINGS_HTML = @"
<div class='container'>
  <h1>[Tiny]Printer Settings:</h1>
  <div class='well form-inline'>
    <div class='row'>
        <div class='form-group col-md-11'>
            <input type='text' class='form-control' id='searchTerm' placeholder='Search Term - e.g. electricimp'>
        </div>
        <div class='form-group col-md-1'>
          <button onclick='updateSettings()' type='submit' class='btn btn-primary'>Update</button>
        </div>
    </div>
  </div>
</div>
";
/************************* END HTML *************************/

/************************* TWITTER PART *************************/
class TwitterStream {
    // OAuth
    consumerKey = null;
    consumerSecret = null;
    accessToken = null;
    accessSecret = null;
    
    // URLs
    streamUrl = "https://stream.twitter.com/1.1/";
    
    // Streaming
    streamingRequest = null;
    
    constructor (_consumerKey, _consumerSecret, _accessToken, _accessSecret) {
        this.consumerKey = _consumerKey;
        this.consumerSecret = _consumerSecret;
        this.accessToken = _accessToken;
        this.accessSecret = _accessSecret;
    }
    
    function encode(str) {
        return http.urlencode({ s = str }).slice(2);
    }

    function oAuth1Request(postUrl, headers, post) {
        local time = time();
        local nonce = time;
 
        local parm_string = http.urlencode({ oauth_consumer_key = consumerKey });
        parm_string += "&" + http.urlencode({ oauth_nonce = nonce });
        parm_string += "&" + http.urlencode({ oauth_signature_method = "HMAC-SHA1" });
        parm_string += "&" + http.urlencode({ oauth_timestamp = time });
        parm_string += "&" + http.urlencode({ oauth_token = accessToken });
        parm_string += "&" + http.urlencode({ oauth_version = "1.0" });
        parm_string += "&" + http.urlencode(post);
        
        local signature_string = "POST&" + encode(postUrl) + "&" + encode(parm_string);
        
        local key = format("%s&%s", encode(consumerSecret), encode(accessSecret));
        local sha1 = encode(http.base64encode(http.hash.hmacsha1(signature_string, key)));
        
        local auth_header = "oauth_consumer_key=\""+consumerKey+"\", ";
        auth_header += "oauth_nonce=\""+nonce+"\", ";
        auth_header += "oauth_signature=\""+sha1+"\", ";
        auth_header += "oauth_signature_method=\""+"HMAC-SHA1"+"\", ";
        auth_header += "oauth_timestamp=\""+time+"\", ";
        auth_header += "oauth_token=\""+accessToken+"\", ";
        auth_header += "oauth_version=\"1.0\"";
        
        local headers = { 
            "Authorization": "OAuth " + auth_header
        };
        
        local url = postUrl + "?" + http.urlencode(post);
        local request = http.post(url, headers, "");
        return request;
    }
    
    function looksLikeATweet(data) {
        return (
            "created_at" in data &&
            "id" in data &&
            "text" in data &&
            "user" in data
        );
    }
    
    function defaultErrorHandler(errors) {
        foreach(error in errors) {
            server.log("ERROR " + error.code + ": " + error.message);
        }
    }
    
    function IsStreaming() {
        return streamingRequest != null;
    }
    
    function Stream(searchTerms, autoReconnect, onTweet, onError = null) {
        server.log("Opening stream for: " + searchTerms);
        // Set default error handler
        if (onError == null) onError = defaultErrorHandler.bindenv(this);
        
        local method = "statuses/filter.json"
        local headers = { };
        local post = { track = searchTerms };
        local request = oAuth1Request(streamUrl + method, headers, post);
        
        
        this.streamingRequest = request.sendasync(
            
            function(resp) {
                // connection timeout
                server.log("Stream Closed (" + resp.statuscode + ": " + resp.body +")");
                // if we have autoreconnect set
                if (resp.statuscode == 28 && autoReconnect) {
                    Stream(searchTerms, autoReconnect, onTweet, onError);
                }
            }.bindenv(this),
            
            function(body) {
                 try {
                    if (body.len() == 2) {
                        return;
                    }
                    local data = http.jsondecode(body);
                    // if it's an error
                    if ("errors" in data) {
                        server.log("Got an error");
                        onError(data.errors);
                        return;
                    } 
                    else {
                        if (looksLikeATweet(data)) {
                            onTweet(data);
                            return;
                        }
                    }
                } catch(ex) {
                    // if an error occured, invoke error handler
                    onError([{ message = "Squirrel Error - " + ex, code = -1 }]);
                }
            }.bindenv(this)
        
        );
    }
    
    function CancelStream() {
        if (streamingRequest != null) {
            streamingRequest.cancel();
            streamingRequest = null;
        }
    }
}
Twitter <- null;

function SetTwitterSearch(searchTerm) {
    // send to device
    device.send("info", "[Tiny]Printer searching for: '" + searchTerm + "'");
    
    // setup twitter stream
    if (Twitter == null) Twitter = TwitterStream(_CONSUMER_KEY, _CONSUMER_SECRET, OAuth.token, OAuth.token_secret);
    if (Twitter.IsStreaming()) Twitter.CancelStream();
    
    Twitter.Stream(searchTerm, true, function(tweet) {
        server.log("Got a tweet!");
        device.send("tweet", { user = tweet.user.screen_name, text = tweet.text });
    });
    
    // save search term
    local data = server.load();
    if ("searchTerm" in data) {
        data.searchTerm = searchTerm;
    } else {
        data["searchTerm"] <- searchTerm;
    }
    server.save(data); 
}

/********** END TWITTER PART **********/
// Auth Control from deviced
device.on("coldboot", function(nullData) {
    allowAuth = true;
    imp.wakeup(60.0, function() { allowAuth = false; });
})

// OAuth.io stuff

function SaveCredentials(_token, _tokenSecret) {
    local data = server.load();
    OAuth <- { 
        token = _token, 
        token_secret = _tokenSecret 
    }
    data.oauth <- OAuth;
    server.save(data);
}

function LoadConfiguration() {
    local data = server.load();
    if ("oauth" in data) {
        OAuth = data.oauth;
    } else {
        SaveCredentials(null, null);
    }
            if ("searchTerm" in data) {
            SetTwitterSearch(data.searchTerm);
        } 

}

function ValidateCredentials(token, tokenSecret) {
    return (OAuth.token != null && OAuth.token_secret != null && 
            OAuth.token == token && OAuth.token_secret == tokenSecret);
}

function Login(token, tokenSecret) {
    if (allowAuth) {
        OAuth.token = token;
        OAuth.token_secret = tokenSecret;
        allowAuth = false;
        
        SaveCredentials(token, tokenSecret);
    }
    
    return ValidateCredentials(token, tokenSecret);
}

function Logout(token, tokenSecret) {
    if (ValidateCredentials(token, tokenSecret)) {
        SaveCredentials(null, null);
        if (Twitter != null) {
            if (Twitter.IsStreaming()) Twitter.CancelStream();
            Twitter = null;
        }
    }
}

http.onrequest(function(req, resp) {
    local path = req.path.tolower();
    server.log(path);
    
    // index
    if (path == "" || path == "/") {
        resp.send(200, format(PAGE_TEMPLATE, INDEX_HTML, OAUTHIO_KEY, BASE_URL, BASE_URL, BASE_URL));
        return;
    } 
    
    // login flow
    if (path == "/auth" || path == "/auth/") {
        local authData = http.urldecode(req.body);
        // make sure we have the data we need
        if ("token" in authData && "token_secret" in authData) {
            // try logging in
            if(Login(authData.token, authData.token_secret)) {
                resp.send(200, SETTINGS_HTML);
                return;
            }
        }
        resp.send(403, "Bad Credentials");
        return;
    }
    
    // logout flow
    if (path =="/logout" || path == "/logout/") {
        local authData = http.urldecode(req.body);
        // make sure we have the data we need
        if ("token" in authData && "token_secret" in authData) {
            // try logging out
            if(Logout(authData.token, authData.token_secret)) {
                resp.send(200, INDEX_HTML);
                return;
            }
        }
        resp.send(403, "Bad Credentials - Could not logout.");
    }
    
    // settings flow
    if (path =="/settings" || path == "/settings/") {
        local data = http.urldecode(req.body);
        // Make sure we have the data we need to check creds
        if ("token" in data && "token_secret" in data) {
            // if the credentials are valid
            if(ValidateCredentials(data.token, data.token_secret)) {
                // make sure we have the data we need to set search
                if (!("searchTerm" in data) || data.searchTerm == null || data.searchTerm == "") {
                    resp.send(406, "Not Acceptable. Missing required parameter 'searchTerm'");
                    return
                }
                // set the search term
                SetTwitterSearch(data.searchTerm);
                resp.send(200, "OK");
                return;
            }
        }
        resp.send(403, "Bad Credentials - Could not logout.");
    }
});

LoadConfiguration();
server.log("Agent Ready");
