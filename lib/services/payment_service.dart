import 'package:dio/dio.dart';

import '../config/api_config.dart';
import 'api_service.dart';
import 'session_service.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.durationDays,
  });

  final int id;
  final String name;
  final String? description;
  final double price;
  final int durationDays;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: (json['id'] as num?)?.toInt() ?? 0,
    name: json['name'] as String? ?? '',
    description: json['description'] as String?,
    price: (json['price'] as num?)?.toDouble() ?? 0,
    durationDays: (json['durationDays'] as num?)?.toInt() ?? 0,
  );
}

class PaymentOrder {
  const PaymentOrder({required this.orderNo, required this.amount});

  final String orderNo;
  final double amount;

  factory PaymentOrder.fromJson(Map<String, dynamic> json) => PaymentOrder(
    orderNo: json['orderNo'] as String? ?? '',
    amount: (json['amount'] as num?)?.toDouble() ?? 0,
  );
}

class Membership {
  const Membership({required this.status, this.expireTime});

  final String status;
  final DateTime? expireTime;

  factory Membership.fromJson(Map<String, dynamic> json) => Membership(
    status: json['status'] as String? ?? '',
    expireTime: DateTime.tryParse(json['expireTime'] as String? ?? ''),
  );
}

class PaymentService {
  const PaymentService();

  Future<List<Product>> listProducts() async {
    final response = await dio.get(ApiConfig.productApi);
    final items = _data(response) as List<dynamic>? ?? const [];
    return items
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// 创建订单；userId 由后端从登录态获取，无需前端传递
  Future<PaymentOrder> createOrder({required int productId}) async {
    final response = await dio.post(
      ApiConfig.orderApi,
      data: {'productId': productId, 'paymentChannel': 'MANUAL'},
    );
    return PaymentOrder.fromJson(_data(response) as Map<String, dynamic>);
  }

  /// 支付回调/人工确认入口；仅限管理员（ADMIN_USER_IDS），接入真实支付渠道后由支付回调替代
  Future<Membership> completeOrder({required String orderNo}) async {
    final response = await dio.post('${ApiConfig.orderApi}/$orderNo/complete');
    return Membership.fromJson(_data(response) as Map<String, dynamic>);
  }

  /// 查询当前有效会员；无有效会员时后端返回 code!=200，这里归为 null
  Future<Membership?> activeMembership() async {
    final userId = session.userId;
    if (userId == null) return null;
    final response = await dio.get(
      ApiConfig.activeMembershipApi,
      queryParameters: {'userId': userId},
    );
    final body = response.data as Map<String, dynamic>;
    if (body['code'] != 200 || body['data'] == null) return null;
    return Membership.fromJson(body['data'] as Map<String, dynamic>);
  }

  dynamic _data(Response<dynamic> response) {
    final body = response.data as Map<String, dynamic>;
    if (body['code'] != 200) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: body['message'],
      );
    }
    return body['data'];
  }
}
