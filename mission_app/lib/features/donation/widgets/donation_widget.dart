import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go4me/core/models/missionary.dart';
import 'package:go4me/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go4me/features/donation/widgets/gamification_badge.dart';
import 'package:go4me/features/donation/checkout_page.dart';

class DonationWidget extends ConsumerStatefulWidget {
  final MissionaryData missionary;
  const DonationWidget({super.key, required this.missionary});

  @override
  ConsumerState<DonationWidget> createState() => _DonationWidgetState();
}

class _DonationWidgetState extends ConsumerState<DonationWidget> {
  int _donationAmount = 50;
  bool _isMonthly = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: AppTheme.accentYellow.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFundingHeader(),
          const SizedBox(height: 24),
          _buildAmountSelector(),
          const SizedBox(height: 24),
          _buildFrequencyToggle(),
          const SizedBox(height: 24),
          _buildDonateButton(),
          const SizedBox(height: 16),
          GamificationBadge(
            isMonthly: _isMonthly,
            amount: _donationAmount,
          ),
        ],
      ),
    );
  }

  Widget _buildFundingHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "SUPORTE ATUAL",
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: AppTheme.textSecondaryClaro,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.accentYellow.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "${widget.missionary.progressPercentage}%",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentYellow,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: widget.missionary.progress,
            minHeight: 8,
            backgroundColor: AppTheme.accentYellow.withValues(alpha: 0.05),
            valueColor: const AlwaysStoppedAnimation(AppTheme.accentYellow),
          ),
        ),
        const SizedBox(height: 12),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "R\$ ${widget.missionary.currentSupport.toStringAsFixed(0)} ",
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryClaro,
                ),
              ),
              TextSpan(
                text: "/ R\$ ${widget.missionary.goalSupport.toStringAsFixed(0)} mensais",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.textSecondaryClaro,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSelector() {
    final amounts = [30, 50, 100, 200];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "VALOR DO INVESTIMENTO",
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: AppTheme.textSecondaryClaro,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: amounts.map((amt) {
            final isSelected = _donationAmount == amt;
            return GestureDetector(
              onTap: () => setState(() => _donationAmount = amt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? AppTheme.surfaceDark : Colors.grey.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  "R\$ $amt",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppTheme.accentYellow : AppTheme.textPrimaryClaro,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFrequencyToggle() {
    return Row(
      children: [
        Expanded(
          child: _buildToggleItem("MENSAL", _isMonthly, () => setState(() => _isMonthly = true)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildToggleItem("ÚNICO", !_isMonthly, () => setState(() => _isMonthly = false)),
        ),
      ],
    );
  }

  Widget _buildToggleItem(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentYellow.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.accentYellow : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? AppTheme.accentYellow : AppTheme.textSecondaryClaro,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDonateButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => _showCheckout(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.surfaceDark,
          foregroundColor: AppTheme.accentYellow,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: Text(
          "VÁ POR MIM",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  void _showCheckout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(missionary: widget.missionary),
      ),
    );
  }
}
