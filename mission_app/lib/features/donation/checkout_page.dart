import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go4me/core/theme/app_theme.dart';
import 'package:go4me/core/services/payment_repository.dart';
import 'package:go4me/core/models/missionary.dart';
import 'package:lottie/lottie.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  final MissionaryData missionary;
  const CheckoutPage({super.key, required this.missionary});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  double _amount = 50.0;
  bool _isLoading = false;

  void _handlePayment() async {
    setState(() => _isLoading = true);
    
    try {
      final paymentRepo = ref.read(paymentRepositoryProvider);
      final result = await paymentRepo.createPaymentIntent(
        amount: _amount,
        currency: 'brl',
        missionaryId: widget.missionary.id,
      );
      
      if (result == null || !result.containsKey('clientSecret')) {
        throw Exception('Falha ao criar pagamento');
      }
      
      final clientSecret = result['clientSecret'];
      final success = await paymentRepo.presentPaymentSheet(clientSecret);
      
      if (success && mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erro no pagamento. Tente novamente.', isError: true);
      }
    }
    
    setState(() => _isLoading = false);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: isError ? AppTheme.errorRed : AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.network(
              'https://assets10.lottiefiles.com/packages/lf20_m3495lft.json', // Checkmark animation
              height: 150,
              repeat: false,
            ),
            const SizedBox(height: 16),
            Text(
              "Doação Realizada!",
              style: GoogleFonts.lora(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              "Sua semente de R\$ ${_amount.toStringAsFixed(2)} foi plantada com sucesso no campo missionário.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Dialog
                  Navigator.pop(context); // CheckoutPage
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("VOLTAR À MISSÃO", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text("CHECKOUT SEGURO", style: GoogleFonts.lora(fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Missionary Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  CircleAvatar(radius: 30, backgroundImage: NetworkImage(widget.missionary.profileImageUrl)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.missionary.name, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)),
                        Text(widget.missionary.location, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Amount Selection
            Text("Escolha o valor da sua doação:", style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [20, 50, 100, 500].map((val) => _buildAmountChip(val.toDouble())).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Outro valor",
                prefixText: "R\$ ",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onChanged: (val) {
                if (val.isNotEmpty) setState(() => _amount = double.tryParse(val) ?? 0);
              },
            ),
            const SizedBox(height: 48),

            // Pay Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handlePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text("DOAR R\$ ${_amount.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.security, color: Colors.grey, size: 16),
                const SizedBox(width: 8),
                Text("Pagamento seguro via Stripe", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountChip(double val) {
    final isSelected = _amount == val;
    return GestureDetector(
      onTap: () => setState(() => _amount = val),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppTheme.primaryGreen : Colors.grey[200]!),
        ),
        child: Text(
          "R\$ ${val.toInt()}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppTheme.textDark,
          ),
        ),
      ),
    );
  }
}
