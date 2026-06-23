import 'dart:io';
import 'package:aeronet_app_flutter/data/services/api_client.dart';
import 'package:aeronet_app_flutter/data/models/customer_model.dart';
import 'package:aeronet_app_flutter/core/utils/helpers.dart';

class CustomerRepository {
  CustomerRepository._();
  static final CustomerRepository instance = CustomerRepository._();

  Future<List<CustomerModel>> getCustomers() async {
    final response = await ApiClient.instance.get('/customers');
    final list = asList(response);
    return list.map((e) => CustomerModel.fromJson(asMap(e))).toList();
  }

  Future<CustomerModel> getCustomer(String id) async {
    final response = await ApiClient.instance.get('/customers/$id');
    return CustomerModel.fromJson(asMap(response));
  }

  Future<CustomerModel> createCustomer(Map<String, dynamic> data) async {
    final response = await ApiClient.instance.post('/customers', data);
    return CustomerModel.fromJson(asMap(response));
  }

  Future<CustomerModel> updateCustomer(String id, Map<String, dynamic> data) async {
    final response = await ApiClient.instance.patch('/customers/$id', data);
    return CustomerModel.fromJson(asMap(response));
  }

  Future<void> deleteCustomer(String id) async {
    await ApiClient.instance.delete('/customers/$id');
  }

  Future<CustomerModel> getMe() async {
    final response = await ApiClient.instance.get('/customers/me');
    return CustomerModel.fromJson(asMap(response));
  }

  Future<CustomerModel> uploadAvatar(File file) async {
    final response = await ApiClient.instance.uploadAvatar(file);
    return CustomerModel.fromJson(asMap(response));
  }
}
