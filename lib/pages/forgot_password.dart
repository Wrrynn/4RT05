import 'package:flutter/material.dart';
import 'package:artos/widgets/glass.dart';
import 'package:artos/controller/resetPassCtrl.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  final ForgotPasswordController _controller = ForgotPasswordController();

  final _emailCtrl = TextEditingController();
  final _telpCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _telpCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  InputDecoration _inputDeco(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: Colors.white38),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: Color.fromARGB(255, 183, 41, 171)),
      ),
    );
  }

  Widget _buildButton({required String text, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 183, 41, 171),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0A0A0A),
              Color(0xFF0A0A0A),
              Color(0xFF1A0B1E),
              Color(0xFF4B146D),
              Color(0xFF8B1FA5),
              Color(0xFFCA3BCB),
              Color(0xFF8B1FA5),
              Color(0xFF2A0835),
              Color(0xFF0A0A0A),
              Color(0xFF0A0A0A),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: GlassContainer(
                width: double.infinity,
                height: 520,
                borderRadius: BorderRadius.circular(25),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Lupa Password",
                      style: TextStyle(
                        fontSize: 26,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),

                    TextField(
                      controller: _emailCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDeco("Email"),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _telpCtrl,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDeco("No Telp"),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _newPassCtrl,
                      obscureText: _obscureNew,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDeco("Password Baru").copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNew ? Icons.visibility_off : Icons.visibility,
                            color: Colors.pinkAccent,
                          ),
                          onPressed: () => setState(() => _obscureNew = !_obscureNew),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _confirmPassCtrl,
                      obscureText: _obscureConfirm,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDeco("Confirm Password").copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                            color: Colors.pinkAccent,
                          ),
                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                      ),
                    ),

                    const SizedBox(height: 26),

                    _buildButton(text: "Ubah", onPressed: () {
                      _controller.handleUbah(
                        context: context,
                        email: _emailCtrl.text,
                        telepon: _telpCtrl.text,
                        newPassword: _newPassCtrl.text,
                        confirmPassword: _confirmPassCtrl.text,
                      );
                    }),

                    const SizedBox(height: 12),

                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        "Kembali Login",
                        style: TextStyle(
                          color: Colors.pinkAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
