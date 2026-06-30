import 'package:aeronet_app_flutter/data/services/api_client.dart';
import 'package:aeronet_app_flutter/data/models/payment_model.dart';
import 'package:aeronet_app_flutter/core/utils/helpers.dart';

class PaymentRepository {
  PaymentRepository._();
  static final PaymentRepository instance = PaymentRepository._();

  Future<List<PaymentModel>> getPayments() async {
    final response = await ApiClient.instance.get('/payments');
    final list = asList(response);
    return list.map((e) => PaymentModel.fromJson(asMap(e))).toList();
  }
}
