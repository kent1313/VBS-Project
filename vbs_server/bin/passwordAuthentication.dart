// from https://itnext.io/authentication-with-jwt-in-dart-6fbc70130806
import 'dart:async';
import 'dart:convert';

import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:shelf/shelf.dart';

import 'config.dart';

class AuthProvider {
  static Middleware createMiddleware({
    FutureOr<Response?> Function(Request)? requestHandler,
    FutureOr<Response> Function(Response)? responseHandler,
    FutureOr<Response> Function(Object error, StackTrace)? errorHandler,
  }) {
    requestHandler ??= (request) => null;
    responseHandler ??= (response) => response;

    FutureOr<Response> Function(Object, StackTrace)? onError;
    if (errorHandler != null) {
      onError = (error, stackTrace) {
        if (error is HijackException) throw error;
        return errorHandler(error, stackTrace);
      };
    }

    return (Handler innerHandler) {
      return (request) {
        // to allow passing info from middleware to request
        request = request.change(context: {"payload": ContextPayload()});
        return Future.sync(() => requestHandler!(request)).then((response) {
          if (response != null) return response;

          return Future.sync(() => innerHandler(request))
              .then((response) => responseHandler!(response), onError: onError);
        });
      };
    };
  }

  static FutureOr<Response?> handle(Request request) async {
    print(" ... ${request.url.toString()}");
    if(request.url.toString() == "login" || request.url.toString().endsWith("/login")) {
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
      conn.close();
      if (result.rows.length == 0) {
        return Response(401, body: 'Incorrect username/password');
      }

      List<String> data = [];
      var fullName = result.rows.first.typedAssoc()["fullName"];
      // There's only 1 row eer returned ... so ignore the rest and just look at the first
      //  Also, data shouldn't be a List!!
      for(var row in result.rows) {
        String admin = row.typedAssoc()['systemAdmin'];
        if(admin == 'Y') {
          data.add('full');
        } else {
          if(admin == 'N') {
            data.add('none');
          } else {
            data.add('some');
          }
        }
      }

      JwtClaim claim = JwtClaim(
        subject: user,
        issuer: config.jwtIssuer,
        audience: [config.jwtAudience],
        payload: {"admin": data[0].toString()}
      );
      String token = issueJwtHS256(claim, config.jwtSecret);

      var response = {
        "name": fullName,
        "loggedIn": true,
        "token": token,
        "admin": data[0],
      };

      var payload = (request.context["payload"]! as ContextPayload);
      payload.user = user;
      payload.admin = response["admin"].toString();

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

      var payload = (request.context["payload"]! as ContextPayload);
      payload.user = claim.subject!;
      payload.admin = claim.payload["admin"];

      return null;

    } catch (e, stacktrace) {
      print("Check failed! $e");
      print(stacktrace);
      return Response.forbidden('Authorization failure');
    }
  }

}

class ContextPayload {
  String user = "";
  String admin = "";
}
