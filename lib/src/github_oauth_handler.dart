// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

///
/// This presents an API for initiating OAuth requests to github and then
/// redirecting back to the calling Dart-Pad application.
///
/// A OAuth application must be registered with GitHub and if the
/// initFromEnvironmentalVars() initializer is used then the GitHub client
/// id and client secret should be stored in the
/// PK_GITHUB_OAUTH_CLIENT_ID and PK_GITHUB_OAUTH_CLIENT_SECRET
/// enviromental variables.  Likewise the authorization return url and the
/// return to dart-pad app url should be stored in
/// K_GITHUB_OAUTH_AUTH_RETURN_URL and K_GITHUB_OAUTH_RETURN_TO_APP_URL
/// environmental variables respectively.
///

import 'dart:convert';
import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

final Logger _logger = Logger('github_oauth_handler');

class GitHubOAuthHandler {
  /// Entry point called from Dart-Pad to initiate a GitHub OAuth Token request.
  /// NOTE: any change to [kEntryPointGitHubOAuthInitiate] must also be
  /// reflected in changing value in dart-pad\lib\github.dart's
  /// [GitHubUIController.kEntryPointGitHubOAuthInitiate] to
  /// match.
  static const kEntryPointGitHubOAuthInitiate = 'github_oauth_initiate';

  /// Entry point specifed to GitHub when setting up OAuth App that GitHub will
  /// redirect to after the OAuth process is completed.  This entry point name
  /// here must also match that used in [_returnToAppUrl] member variable (or
  /// set using the K_GITHUB_OAUTH_RETURN_TO_APP_URL environmental variable).
  static const entryPointGitHubReturnAuthorize = 'github_oauth_authorized';

  static const minimumHiveSizeBeforeHousekeeping = 10;
  static bool initialized = false;
  static bool initializationEndedInErrorState = false;

  static late final Box<int> _stateBox;
  static late final String _clientId;
  static late final String _clientSecret;
  static late final String _authReturnUrl;
  static late final String _returnToAppUrl;

  /// Adds the GitHub OAuth api end point routes to the passed in Router.
  static bool addRoutes(Router router) {
    if (!initializationEndedInErrorState) {
      // Add our routes to the router.
      _logger.info('Adding GitHub OAuth routes to passed router.');
      router.get('/$kEntryPointGitHubOAuthInitiate/<randomState|[a-zA-Z0-9]+>',
          _initiateHandler);
      router.get('/$entryPointGitHubReturnAuthorize', _returnAuthorizeHandler);
    } else {
      _logger.info('''Attempt to add GitHub OAuth routes to router FAILED
because initialization of GitHubOAuthHandler failed earlier.''');
    }
    return !initializationEndedInErrorState;
  }

  /// This routine attempts to read all required initialization parameters
  /// from environmental variables.
  /// This must be called before calling addRoutes() to initialize the hive and
  /// static class variables.
  /// Returns true if initialization was successful.
  static Future<bool> initFromEnvironmentalVars() async {
    if (initialized) return !initializationEndedInErrorState;

    final String clientId =
        _stripQuotes(Platform.environment['PK_GITHUB_OAUTH_CLIENT_ID']) ??
            'MissingClientIdEnvironmentalVariable';
    final String clientSecret =
        _stripQuotes(Platform.environment['PK_GITHUB_OAUTH_CLIENT_SECRET']) ??
            'MissingClientSecretEnvironmentalVariable';
    String authReturnUrl =
        _stripQuotes(Platform.environment['K_GITHUB_OAUTH_AUTH_RETURN_URL']) ??
            '';
    String returnToAppUrl = _stripQuotes(
            Platform.environment['K_GITHUB_OAUTH_RETURN_TO_APP_URL']) ??
        '';

    bool missingEnvVariables = false;
    if (clientId == 'MissingClientIdEnvironmentalVariable') {
      _logger.severe(
          'PK_GITHUB_OAUTH_CLIENT_ID environmental variable not set! This is REQUIRED.');
      missingEnvVariables = true;
    }
    if (clientSecret == 'MissingClientSecretEnvironmentalVariable') {
      _logger.severe(
          'PK_GITHUB_OAUTH_CLIENT_SECRET environmental variable not set! This is REQUIRED.');
      missingEnvVariables = true;
    }
    if (missingEnvVariables) {
      _logger.severe(
          'GitHub OAuth Handler DISABLED - Ensure all required environmental variables are set and re-run.');
      initializationEndedInErrorState = true;
      return false;
    }

    _logger.info(
        '''Enviroment PK_GITHUB_OAUTH_CLIENT_ID=${_replaceAllButLastFour(clientId)}');
Enviroment PK_GITHUB_OAUTH_CLIENT_SECRET=${_replaceAllButLastFour(clientSecret)}
Enviroment K_GITHUB_OAUTH_AUTH_RETURN_URL=$authReturnUrl'
Enviroment K_GITHUB_OAUTH_RETURN_TO_APP_URL=$returnToAppUrl'
''');

    if (authReturnUrl.isEmpty) {
      // This would be the locally running dart-services server.
      authReturnUrl = 'http://localhost:8080/$entryPointGitHubReturnAuthorize';
      _logger.info(
          'K_GITHUB_OAUTH_AUTH_RETURN_URL environmental variable not set - defaulting to "$authReturnUrl"');
    }
    if (returnToAppUrl.isEmpty) {
      // This would be the locally running dart-pad server.
      returnToAppUrl = 'http://localhost:8000/index.html';
      _logger.info(
          'K_GITHUB_OAUTH_RETURN_TO_APP_URL environmental variable not set - defaulting to "$returnToAppUrl"');
    }
    return init(clientId, clientSecret, authReturnUrl, returnToAppUrl);
  }

  /// This must be called before calling addRoutes() to initialize the hive and
  /// static class variables.
  /// All required parameters are passed directly to this init() routine.
  /// Returns true if initialization was successful.
  static Future<bool> init(String clientId, String clientSecret,
      String authReturnUrl, String returnToAppUrl) async {
    _clientId = clientId;
    _clientSecret = clientSecret;
    _authReturnUrl = authReturnUrl;
    _returnToAppUrl = returnToAppUrl;

    bool missingParameters = false;
    if (_clientId.isEmpty) {
      _logger.severe('GitHubOAuthHandler no client id passed to init().');
      missingParameters = true;
    }
    if (_clientSecret.isEmpty) {
      _logger.severe('GitHubOAuthHandler no client secret passed to init().');
      missingParameters = true;
    }
    if (_authReturnUrl.isEmpty) {
      _logger.severe(
          'GitHubOAuthHandler no authorization return url passed to init().');
      missingParameters = true;
    }
    if (_returnToAppUrl.isEmpty) {
      _logger
          .severe('GitHubOAuthHandler no return ti app url passed to init().');
      missingParameters = true;
    }
    if (missingParameters) {
      _logger.severe(
          'GitHub OAuth Handler DISABLED - Ensure all required parameters not passed to init().');
      initializationEndedInErrorState = true;
      return false;
    }

    if (!initializationEndedInErrorState) {
      // We have all required parameters, go ahead and init hive db.
      final path = Directory.current.path;
      Hive.init(path);

      _stateBox = await Hive.openBox<int>('statebox');
      await _stateBox.clear(); // State never persist across runs.
    }

    initialized = true;
    return !missingParameters;
  }

  ///  The calling app initiates a request for GitHub OAuth authorization by
  ///  sending get request to `/$kEntryPointGitHubOAuthInitiate/XXXXXXXXX` where
  ///  `XXXXXX` is a random alpha numeric token of at least 40 characters in
  ///  length.
  ///  When the entire process is complete the browser will be redirected to
  ///  the calling app at the URL defined by [_returnToAppUrl].
  ///  The calling app will need to use the originally sent random token
  ///  to decrypt the returned GitHub authorization token.
  static Future<Response> _initiateHandler(
      Request request, String randomState) async {
    // See if we have anything stored for this random state.
    int? timestamp = _stateBox.get(randomState);
    bool newRequest = false;
    final int nowTimeStamp = DateTime.now().millisecondsSinceEpoch;

    if (randomState.isEmpty || randomState.length < 40) {
      return Response.ok('Random token must be >=40 characters in length');
    }

    if (timestamp == null) {
      timestamp = nowTimeStamp;
      newRequest = true;
    }
    // Store this state/timestamp pair within the hive so
    // we can later verify state on a return from GitHub.
    await _stateBox.put(randomState, timestamp);

    if (_stateBox.length > minimumHiveSizeBeforeHousekeeping) {
      // Take this opportunity to do stateBox cleanup and remove any old entries.
      // These would only be 'abandoned' entries, any request that returns
      // from GitHub OAuth would have been automatically deleted.
      try {
        // Check everything in the box for expiration and delete if needed.
        for (int i = _stateBox.length - 1; i >= 0; i--) {
          final int maybeOldTimestamp = _stateBox.getAt(i)!;
          final int howOld = nowTimeStamp - maybeOldTimestamp;
          if (howOld > (15 * 60 * 1000)) {
            // Recored older than 15 minutes, delete it.
            await _stateBox.deleteAt(i);
          }
        }
      } catch (e) {
        _logger.severe('Exception $e caught during state box cleanup');
      }
    }

    /*
      Incoming Random String from DartPad.

      Request Users GitHub Identity.

      GET https://github.com/login/oauth/authorize

      client_id=XXXXXXXXXXX
      redirect_uri=[_authReturnUrl]
      scope=gist
      state=RANDOMSTR
    */
    if (newRequest) {
      String url = 'https://github.com/login/oauth/authorize?';

      url +=
          'client_id=$_clientId&redirect_uri=$_authReturnUrl&scope=gist&state=$randomState';

      _logger.fine('Redirecting to GITHUB authorize');
      return Response(302, headers: {'location': url});
    }

    // Return to app with 'authfailed' to indicate error.
    String backToAppUrl = _returnToAppUrl;
    backToAppUrl += '?gh=authfailed';
    return Response(302, headers: {'location': backToAppUrl});
  }

  /// This entry point is called by the GitHub OAuth process and is the
  /// client return authorization handler defined on GitHub when creating
  /// the GitHub OAuth Client Id and GitHub OAuth Secret when defining this
  /// OAuth app on GitHub.
  static Future<Response> _returnAuthorizeHandler(Request request) async {
    /*
      GitHub REdirects BACK to us here at [_authReturnUrl] with params set:
          code=XXXXXXXX
      and
          state=RANDOMSTR we them sent earlier.

    */
    _logger.fine('Entered _returnAuthorizeHandler');

    String backToAppUrl = _returnToAppUrl;
    bool validCallback = false;
    bool tokenAquired = false;

    try {
      final String code = request.requestedUri.queryParameters['code'] ?? '';
      final String state = request.requestedUri.queryParameters['state'] ?? '';

      // See if we have anything stored for this state value.
      final int? timestamp = _stateBox.get(state);

      if (timestamp == null) {
        // ERROR!! We did not have a record of this initial request - ignore.
      } else {
        validCallback = true;
        final client = http.Client();
        /*
          Now we exchange this code=XXXX for an access token.

          POST https://github.com/login/oauth/access_token

          client_id=XXXXXXX
          client_secret=MYCLIENTSECRET
          code=FROMINCOMING_PARAM code
          redirect_uri=[_returnToAppUrl]

          PUT "Accept: application/json" in ACCEPT HEADER on POST
          and get back JSON

          Accept: application/json
          {
            "access_token":"gho_XXXXXXXXX",
            "scope":"gist",
            "token_type":"bearer"
          }
        */
        final String githubExchangeCodeUri =
            'https://github.com/login/oauth/access_token';
        final Map<String, dynamic> map = {
          'client_id': _clientId,
          'client_secret': _clientSecret,
          'code': code,
          'redirect_uri': _authReturnUrl,
        };
        final String bodydata = json.encode(map);

        await client
            .post(Uri.parse(githubExchangeCodeUri),
                headers: {
                  'Accept': 'application/vnd.github.v3+json',
                  'Content-Type': 'application/json',
                },
                body: bodydata)
            .then((http.Response postResponse) {
          late String accessToken, scope;
          if (postResponse.statusCode >= 200 &&
              postResponse.statusCode <= 299) {
            final retObj =
                jsonDecode(postResponse.body) as Map<String, dynamic>;

            accessToken = retObj['access_token'] as String;
            scope = retObj['scope'] as String;

            tokenAquired = true;

            // We can delete this record because we are done.
            _stateBox.delete(state);

            // Encrypt the auth token using the original random state.
            final String encrBase64AuthToken =
                _encryptAndBase64EncodeAuthToken(accessToken, state);
            // Build URL to redirect back to the app.
            backToAppUrl += '?gh=$encrBase64AuthToken&scope=$scope';

            _logger.fine('success - redirecting back to app');
          } else if (postResponse.statusCode == 404) {
            throw Exception('contentNotFound');
          } else if (postResponse.statusCode == 403) {
            throw Exception('rateLimitExceeded');
          } else if (postResponse.statusCode != 200) {
            throw Exception('unknown');
          }
        });
      }

      if (!validCallback || !tokenAquired) {
        // Return to app with 'noauth' set to indicate failed authorization.
        backToAppUrl += '?gh=noauth&state=$state';
      }

      return Response(302, headers: {'location': backToAppUrl});
    } catch (e) {
      // Fall through and redirect back to app with 'authfailed'.
    }
    // Return to app with 'authfailed' to indicate error.
    backToAppUrl += '?gh=authfailed';
    return Response(302, headers: {'location': backToAppUrl});
  }

  /// Take the GitHub auth token [ghAuthToken] and the original random
  /// state string [randomStateWeWereSent] the client sent in the original
  /// `/$kEntryPointGitHubOAuthInitiate/XXXXX` request and encrypt the token using
  /// the random state string.  This protects the GH token on the return
  /// and also allows the client to verify that we origin of the token.
  /// This is probably overkill, we could just XOR encrypt (or something
  /// similarily simple), but erroring on the side of more secure
  /// probably can't hurt.
  /// The symetric decrypting routine is used client side in Dart-Pad t
  /// decrypt the received token.
  static String _encryptAndBase64EncodeAuthToken(
      String ghAuthToken, String randomStateWeWereSent) {
    if (randomStateWeWereSent.isEmpty) {
      return 'ERROR-no stored initial state';
    }
    try {
      final iv = IV.fromUtf8(randomStateWeWereSent.substring(0, 8));
      final key = Key.fromUtf8(randomStateWeWereSent.substring(8, 40));
      final sasla = Salsa20(key);
      final encrypter = Encrypter(sasla);

      final encryptedToken = encrypter.encrypt(ghAuthToken, iv: iv);

      return Uri.encodeComponent(encryptedToken.base64);
    } catch (e) {
      _logger.severe('CAUGHT EXCEPTION during encryption ${e.toString()}');
    }
    return 'ENCRYPTION_ERROR';
  }

  // Used to mask all but last 4 characters.
  static final selectAllButLast4 = RegExp(r'\w(?!\w{0,3}$)');

  /// Masks everthing off of string but last 4 characters.  Use
  /// to mask secrets when logging.
  static String _replaceAllButLastFour(String hide) {
    return hide.replaceAll(selectAllButLast4, 'X');
  }

  // RegExp to select single and double start/ending quotes.
  static final selectDoubleQuotes = RegExp(r'^"|"$');
  static final selectSingleQuotes = RegExp(r"^'|'$");

  // Ensures quotes are strip from string.
  static String? _stripQuotes(String? str) {
    if (str == null) return null;
    return str
        .replaceAll(selectDoubleQuotes, '')
        .replaceAll(selectSingleQuotes, '');
  }
}
