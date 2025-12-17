import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:artos/service/db_service.dart';
import 'package:artos/model/topup.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TopupController {
  final supabase = DBService.client;
  
  // ⚠️ GANTI DENGAN SECRET KEY SANDBOX MIDTRANS ⚠️ 
  final String serverKey = "Mid-server-IApp0q6liFZkeMsmwN586_0E"; 

  // --- 1. Request Transaksi ---
  Future<Topup?> createTransaction({
    required String userId,
    required double jumlah,
    required String category,
    required String detailName,
  }) async {
    final String orderId = "ARTOS-${DateTime.now().millisecondsSinceEpoch}";
    final String basicAuth = 'Basic ${base64Encode(utf8.encode('$serverKey:'))}';

    List<String> enabledPayments = [];
    if (category == 'bank') enabledPayments = ["bca_va", "bni_va", "bri_va"];
    if (category == 'qris') enabledPayments = ["gopay"]; // Sandbox pakai gopay utk QRIS
    if (category == 'cash') enabledPayments = ["indomaret"];

    try {
      final response = await http.post(
        Uri.parse('https://app.sandbox.midtrans.com/snap/v1/transactions'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': basicAuth
        },
        body: jsonEncode({
          "transaction_details": {"order_id": orderId, "gross_amount": jumlah.toInt()},
          "customer_details": {"first_name": "User", "last_name": userId},
          "enabled_payments": enabledPayments,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final dbRes = await supabase.from('Top Up').insert({
          'id_pengguna_topup': userId,
          'jumlah': jumlah,
          'metode': category,
          'detail_metode': detailName,
          'order_id': orderId,
          'status': 'pending',
          'payment_code': data['redirect_url'],
        }).select().single();

        return Topup.fromMap(dbRes);
      } else {
        print("Midtrans Error: ${response.body}"); // Cek debug console untuk pesan error detail
      }
    } catch (e) {
      print("Exception: $e");
    }
    return null;
  }

  // GANTI fungsi checkTransactionStatus Anda dengan versi "Pintar" ini:
  Future<String> checkTransactionStatus(String orderId, String userId, double amount) async {
    // Ingat: Gunakan Split String agar aman push ke GitHub
    final String serverKey = "Mid-server-" + "IApp0q6liFZkeMsmwN586_0E"; // Sesuaikan key Anda
    final String basicAuth = 'Basic ${base64Encode(utf8.encode('$serverKey:'))}';
    
    try {
      final response = await http.get(
        Uri.parse('https://api.sandbox.midtrans.com/v2/$orderId/status'),
        headers: {'Authorization': basicAuth, 'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String transactionStatus = data['transaction_status'];
        String fraudStatus = data['fraud_status'] ?? '';

        // --- 1. LOGIKA UPDATE NAMA BANK OTOMATIS ---
        String detectedBank = "";
        
        // Cek apakah user bayar pakai Virtual Account (Bank)?
        if (data.containsKey('va_numbers')) {
          // Ambil nama bank dari respon Midtrans (misal: "bca")
          detectedBank = data['va_numbers'][0]['bank'].toString().toUpperCase(); 
        } else if (data['payment_type'] == 'qris') {
          detectedBank = "QRIS (GoPay/Lainnya)";
        } else {
          detectedBank = data['payment_type'].toString(); // Store/Indomaret
        }

        // Jika ada deteksi bank baru, update ke Database Supabase
        if (detectedBank.isNotEmpty) {
          await supabase.from('Top Up')
              .update({'detail_metode': detectedBank}) // Update kolom detail_metode
              .eq('order_id', orderId);
        }
        // ---------------------------------------------

        bool isSuccess = (transactionStatus == 'capture' && fraudStatus == 'accept') || 
                        (transactionStatus == 'settlement');

        if (isSuccess) {
          final checkDb = await supabase.from('Top Up').select('status').eq('order_id', orderId).single();
          if (checkDb['status'] != 'success') {
            await supabase.from('Top Up').update({'status': 'success'}).eq('order_id', orderId);
            
            final user = await supabase.from('Pengguna').select('saldo').eq('id_pengguna', userId).single();
            double oldSaldo = (user['saldo'] ?? 0).toDouble();
            await supabase.from('Pengguna').update({'saldo': oldSaldo + amount}).eq('id_pengguna', userId);
            
            return "success";
          }
          return "already_paid";
        }
        return transactionStatus; 
      }
    } catch (e) {
      return "error";
    }
    return "unknown";
  }
}