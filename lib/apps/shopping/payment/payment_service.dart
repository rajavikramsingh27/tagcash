import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:stripe_payment/stripe_payment.dart';

class StripeTransactionResponse {
  String message;
  String id;
  String brand;
  String country;
  String expMonth;
  String expYear;
  String last4;
  String name;
  String cvv;
  bool success;

  StripeTransactionResponse(
      {this.id,
      this.brand,
      this.country,
      this.expMonth,
      this.expYear,
      this.last4,
      this.name,
      this.cvv,
      this.message,
      this.success});
}

class StripeService {
  static String apiBase = 'https://api.stripe.com/v1';
  static String paymentApiUrl = '${StripeService.apiBase}/payment_intents';
  static String paymentMethodApiUrl =
      '${StripeService.apiBase}/payment_methods';
  static String secret =
      'sk_test_51Hc4egCpMQbvFPPiRww82TUkZtuPdSrz5BCB2xu6AA2nL4GEbeKhjnag9AXLzvFEdL9ujJEwT3J7gwYM9yUKfkC500REEQM0Xp';
  static String accountId = '';
  static String statusCode = '';

  static Map<String, String> headers = {
    'Authorization': 'Bearer ${StripeService.secret}',
    'Content-Type': 'application/x-www-form-urlencoded',
    'Stripe-Account': accountId
  };

  static init() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    accountId = _prefs.getString('SAccountId');
    // StripePayment.setOptions(StripeOptions(
    //     publishableKey:
    //         "pk_test_51Hc4egCpMQbvFPPiJB3UEtABdD6iFOKB4CT9V8jYSGslVa27hTjhkw2FQRrW6U6XdW8g8l9iJ8EFyosKlnLxRLGi00n74ARCxS",
    //     merchantId: "Test",
    //     androidPayMode: 'test'));
  }

  static Future<StripeTransactionResponse> payViaExistingCard(
      {String amount,
      String currency,
      String cardNumber,
      String cardMonth,
      String cardYear,
      String cardCVV}) async {
    try {
      var paymentMethod = await StripeService.createPaymentMethod(
          cardNumber, cardMonth, cardYear, cardCVV);

      var paymentIntent = await StripeService.createPaymentIntent(
        amount,
        currency,
      );

      var response = await StripeService.confirmPaymentIntent(
        paymentIntent['id'],
        paymentMethod['id'],
      );

      if (statusCode == '200') {
        return new StripeTransactionResponse(
            id: response['id'],
            message: 'Transaction successful',
            success: true);
      } else {
        return new StripeTransactionResponse(
            message: 'Transaction failed', success: false);
      }
    } on PlatformException catch (err) {
      return StripeService.getPlatformExceptionErrorResult(err);
    } catch (err) {
      return new StripeTransactionResponse(
          message: 'Transaction failed: ${err.toString()}', success: false);
    }
  }

  static Future<StripeTransactionResponse> payWithNewCard(
      {String amount,
      String currency,
      String cardNumber,
      String cardMonth,
      String cardYear,
      String cardCVV}) async {
    var paymentIntent;
    try {
      var paymentMethod = await StripeService.createPaymentMethod(
          cardNumber, cardMonth, cardYear, cardCVV);

      paymentIntent = await StripeService.createPaymentIntent(
        amount,
        currency,
      );

      var response = await StripeService.confirmPaymentIntent(
        paymentIntent['id'],
        paymentMethod['id'],
      );

      if (statusCode == '200') {
        return new StripeTransactionResponse(
            id: response['id'],
            brand: paymentMethod['card']['brand'],
            country: paymentMethod['card']['country'],
            expMonth: cardMonth,
            expYear: cardYear,
            last4: cardNumber,
            cvv: cardCVV,
            name: '',
            message: 'Transaction successful',
            success: true);
      } else {
        return new StripeTransactionResponse(
            message: 'Transaction failed', success: false);
      }
    } on PlatformException catch (err) {
      return StripeService.getPlatformExceptionErrorResult(err);
    } catch (err) {
      return new StripeTransactionResponse(
          message: 'Transaction failed: ${paymentIntent['error']['message']}',
          success: false);
    }
  }

  static getPlatformExceptionErrorResult(err) {
    String message = 'Something went wrong';
    if (err.code == 'cancelled') {
      message = 'Transaction cancelled';
    }

    return new StripeTransactionResponse(message: message, success: false);
  }

  static Future<Map<String, dynamic>> createPaymentIntent(
      String amount, String currency) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String appCharge = _prefs.getString('AppCharge');
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
        'application_fee_amount': appCharge,
        'payment_method_types[]': 'card',
      };
      var response = await http.post(Uri.parse(StripeService.paymentApiUrl),
          body: body, headers: StripeService.headers);
      return jsonDecode(response.body);
    } catch (err) {
      print('err charging user: ${err.toString()}');
    }
    return null;
  }

  static Future<Map<String, dynamic>> createPaymentMethod(String cardNumber,
      String cardMonth, String cardYear, String cardCVV) async {
    try {
      Map<String, dynamic> body = {
        'type': 'card',
        'card[number]': cardNumber,
        'card[exp_month]': cardMonth,
        'card[exp_year]': cardYear,
        'card[cvc]': cardCVV,
      };
      var response = await http.post(
          Uri.parse(StripeService.paymentMethodApiUrl),
          body: body,
          headers: StripeService.headers);
      return jsonDecode(response.body);
    } catch (err) {
      print('err charging user: ${err.toString()}');
    }
    return null;
  }

  static Future<Map<String, dynamic>> confirmPaymentIntent(
      String paymentIntentId, String paymentMethodId) async {
    try {
      Map<String, dynamic> body = {
        'payment_method': paymentMethodId,
      };
      var response = await http.post(
          Uri.parse(StripeService.paymentApiUrl + '/$paymentIntentId/confirm'),
          body: body,
          headers: StripeService.headers);
      statusCode = response.statusCode.toString();
      return jsonDecode(response.body);
    } catch (err) {
      print('err charging user: ${err.toString()}');
    }
    return null;
  }

  static Future requestAccount(String url, String type) async {
    final http.Response response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-type': 'application/x-www-form-urlencoded; charset=UTF-8',
        'Authorization':
            'Bearer sk_test_51Hc4egCpMQbvFPPiRww82TUkZtuPdSrz5BCB2xu6AA2nL4GEbeKhjnag9AXLzvFEdL9ujJEwT3J7gwYM9yUKfkC500REEQM0Xp'
      },
      body: {
        'type': type,
      },
    );
    return jsonDecode(response.body);
  }

  static Future requestAccountLink(String url, String account,
      String refresh_url, String return_url, String type) async {
    final http.Response response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-type': 'application/x-www-form-urlencoded; charset=UTF-8',
        'Authorization':
            'Bearer sk_test_51Hc4egCpMQbvFPPiRww82TUkZtuPdSrz5BCB2xu6AA2nL4GEbeKhjnag9AXLzvFEdL9ujJEwT3J7gwYM9yUKfkC500REEQM0Xp'
      },
      body: {
        'account': account,
        'refresh_url': refresh_url,
        'return_url': return_url,
        'type': type,
      },
    );
    return jsonDecode(response.body);
  }

  static Future requestGetAccount(String url) async {
    final http.Response response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-type': 'application/x-www-form-urlencoded; charset=UTF-8',
        'Authorization':
            'Bearer sk_test_51Hc4egCpMQbvFPPiRww82TUkZtuPdSrz5BCB2xu6AA2nL4GEbeKhjnag9AXLzvFEdL9ujJEwT3J7gwYM9yUKfkC500REEQM0Xp'
      },
    );
    return jsonDecode(response.body);
  }
}
