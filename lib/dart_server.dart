import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

Future<void> main() async {
  final port = 8080;

  // Define the routes for the server.
  final router = Router();

  router.get('/', (Request request) async {
    return Response.ok('Hello, world!');
  });

  router.post('/login', (Request request) async {
    print('login ${inspect(request)}');

    // Get the username and password from the request body.
    final body = await request.readAsString();
    final Map<String, String> credentials = json.decode(body);

    // Check the username and password against the database.
    if (credentials['username'] == 'admin' && credentials['password'] == 'password') {
      // The user is authenticated, generate an access token and a refresh token.
      final accessToken = 'Bearer 1234567890abcdefghijklmnopqrstuvwxyz';
      final refreshToken = 'Bearer ABCDEFGHIJKLMNOPQRSTUVWXYZ9876543210';

      // Return the access token and refresh token in the response.
      return Response.ok({
        'access_token': accessToken,
        'refresh_token': refreshToken,
      });
    } else {
      // The user is not authenticated, return an unauthorized response.
      return Response.unauthorized(null);
    }
  });

  // Add CORS headers to all responses.
  //router.addMiddleware(CORS());

  // Listen on port 8080.
  await HttpServer.bind('localhost', port).then((server) {
    print('Serving at http://localhost:$port');
    server.listen((request){
      print('request ${inspect(request)}');
    });
  });
}