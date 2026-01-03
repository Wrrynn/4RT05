import 'dart:convert';
import 'package:artos/model/topup.dart';
import 'package:artos/model/pengguna.dart';
import 'package:http/http.dart' as http;

class TopupController {
  final String _serverKey = "Mid-server-XXXXXXXXXXXX";

  String _auth() =>
      'Basic ${base64Encode(utf8.encode('$_serverKey:'))}';

  Future<Topup?> createTransaction({
    required String userId,
    required double jumlah,
    required String category,
    required String detailName,
  }) async {
    final orderId = "ARTOS-${DateTime.now().millisecondsSinceEpoch}";

    List<String> payments = [];
    if (category == 'bank') payments = ["bca_va", "bni_va", "bri_va"];
    if (category == 'qris') payments = ["gopay"];
    if (category == 'cash') payments = ["indomaret"];

    final response = await http.post(
      Uri.parse('https://app.sandbox.midtrans.com/snap/v1/transactions'),
      headers: {
        'Authorization': _auth(),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "transaction_details": {
          "order_id": orderId,
          "gross_amount": jumlah.toInt()
        },
        "enabled_payments": payments,
      }),
    );

    if (response.statusCode != 201) return null;

    final data = jsonDecode(response.body);

    return await Topup.insert(
      Topup(
        idPenggunaTopup: userId,
        jumlah: jumlah,
        metode: category,
        detailMetode: detailName,
        orderId: orderId,
        redirectUrl: data['redirect_url'],
        status: 'pending',
      ),
    );
  }

  Future<String> checkTransactionStatus(
      String orderId, String userId, double amount) async {
    final response = await http.get(
      Uri.parse('https://api.sandbox.midtrans.com/v2/$orderId/status'),
      headers: {'Authorization': _auth()},
    );

    if (response.statusCode != 200) return "error";

    final data = jsonDecode(response.body);
    final status = data['transaction_status'];
    final fraud = data['fraud_status'] ?? '';

    String detailMetode = data['payment_type'];
    if (data['va_numbers'] != null) {
      detailMetode = data['va_numbers'][0]['bank'].toUpperCase();
    }

    await Topup.updateDetailMetode(orderId, detailMetode);

    final isSuccess =
        (status == 'capture' && fraud == 'accept') ||
            status == 'settlement';

    if (!isSuccess) return status;

    final existing = await Topup.findByOrderId(orderId);
    if (existing?.status == 'sukses') return "already_paid";

    await Topup.updateStatus(orderId, 'sukses');
    await Pengguna.addSaldo(userId, amount);

    return "success";
  }
}
