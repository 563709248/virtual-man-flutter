import 'package:flutter/material.dart';

import '../services/payment_service.dart';

/// 会员中心：展示有效会员状态与在售商品，走下单→确认支付流程。
/// 后端 /payments/orders/{orderNo}/complete 目前是人工确认入口，
/// 接入真实支付渠道前用它在开发环境模拟支付完成。
class MembershipPage extends StatefulWidget {
  const MembershipPage({super.key});

  @override
  State<MembershipPage> createState() => _MembershipPageState();
}

class _MembershipPageState extends State<MembershipPage> {
  final _service = const PaymentService();
  List<Product> _products = const [];
  Membership? _membership;
  bool _loading = true;
  bool _paying = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _service.listProducts(),
        _service.activeMembership(),
      ]);
      if (!mounted) return;
      setState(() {
        _products = results[0] as List<Product>;
        _membership = results[1] as Membership?;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _buy(Product product) async {
    if (_paying) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('购买 ${product.name}'),
        content: Text(
          '¥${product.price.toStringAsFixed(2)} / ${product.durationDays} 天\n\n当前为开发环境，确认后订单将直接置为已支付。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认支付'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _paying = true);
    try {
      final order = await _service.createOrder(productId: product.id);
      final membership = await _service.completeOrder(orderNo: order.orderNo);
      if (!mounted) return;
      setState(() => _membership = membership);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('开通成功')));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('支付失败：$error')));
      }
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('会员中心')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: TextButton(
          onPressed: _load,
          child: Text('加载失败，点击重试\n$_error', textAlign: TextAlign.center),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: Icon(
              _membership != null
                  ? Icons.workspace_premium
                  : Icons.workspace_premium_outlined,
              color: _membership != null
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
            title: Text(
              _membership != null
                  ? '会员有效期至 ${_formatDate(_membership!.expireTime)}'
                  : '暂未开通会员',
            ),
            subtitle: const Text('会员可持续积累与虚拟朋友的羁绊'),
          ),
        ),
        const SizedBox(height: 16),
        Text('会员套餐', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (_products.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text('暂无在售套餐')),
          )
        else
          ..._products.map(
            (product) => Card(
              child: ListTile(
                title: Text(product.name),
                subtitle:
                    product.description == null || product.description!.isEmpty
                    ? Text('${product.durationDays} 天')
                    : Text(
                        '${product.description} · ${product.durationDays} 天',
                      ),
                trailing: FilledButton.tonal(
                  onPressed: _paying ? null : () => _buy(product),
                  child: Text('¥${product.price.toStringAsFixed(2)}'),
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _formatDate(DateTime? time) {
    if (time == null) return '-';
    return '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')}';
  }
}
