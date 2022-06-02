// from https://itnext.io/authentication-with-jwt-in-dart-6fbc70130806
import 'dart:async';
import 'dart:convert';

import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:shelf/shelf.dart';

import 'config.dart';

class AuthProvider {
  static FutureOr<Response?> handle(Request request) async {
    print(" ... ${request.url.toString()}");
    if(request.url.toString() == "login" || request.url.toString() == "session/login") {
      return authenticate(request);
    } else {
      return check(request);
    }
    return null;
  }

  static FutureOr<Response> authenticate(Request request) async {
    try {
      final body = await request.readAsString();
      print(body);
      var loginInfo = jsonDecode(body);
      print(jsonEncode(loginInfo));
      var user = loginInfo["userName"];
      var password = loginInfo["password"];
      var conn = await config.connectToDatabase();

      var result = await conn.execute(
          "select * from tblUser where userName = :user and password = MD5(:pass)",
          {
            "user": user,
            "pass": password,
          });
      List rows = [];
      if (result.rows.length == 0) {
        return Response(401, body: 'Incorrect username/password');
      }

      var fullName = result.rows.first.typedAssoc()["fullName"];

      JwtClaim claim = JwtClaim(
        subject: user,
        issuer: config.jwtIssuer,
        audience: [config.jwtAudience],
      );
      String token = issueJwtHS256(claim, config.jwtSecret);

      var response = {
        "name": fullName,
        "loggedIn": true,
        "token": token,
      };

      return Response.ok(jsonEncode(response));
    } catch (e, stacktrace) {
      print("Login failure: $e");
      print(stacktrace);
      return Response(401, body: 'Error with signin');
    }
  }

  static FutureOr<Response?> check(Request request) async {
    try {
      if(request.headers['Authorization'] == null) {
        return Response.forbidden('Authorization required');
      }
      String token = request.headers['Authorization']!.replaceAll('Bearer ', '');
      JwtClaim claim = verifyJwtHS256Signature(token, config.jwtSecret);
      claim.validate(issuer: config.jwtIssuer, audience: config.jwtAudience);
      return null;

    } catch (e, stacktrace) {
      return Response.forbidden('Authorization failure');
    }
  }

}
