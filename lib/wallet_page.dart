import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'services/security_service.dart';
import 'widgets/animation_utils.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'widgets/tokn_snackbar.dart';


class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  bool _isBalanceVisible = false;

  final List<Map<String, dynamic>> _transactions = [
    {
      'hospital': 'Medanta - The Medicity',
      'icon': Icons.local_hospital,
      'transactions': [
        {'title': 'Consultation Fee', 'date': '24 Oct, 2023', 'amount': -500.0, 'status': 'Completed'},
        {'title': 'Lab Report - Blood Test', 'date': '20 Oct, 2023', 'amount': -1200.0, 'status': 'Completed'},
      ]
    },
    {
      'hospital': 'Apollo Hospital',
      'icon': Icons.business_outlined,
      'transactions': [
        {'title': 'Token Booking #892', 'date': '15 Oct, 2023', 'amount': -300.0, 'status': 'Completed'},
        {'title': 'Refund - Cancelled Booking', 'date': '12 Oct, 2023', 'amount': 300.0, 'status': 'Refunded'},
      ]
    },
    {
      'hospital': 'Max Super Speciality',
      'icon': Icons.health_and_safety_outlined,
      'transactions': [
        {'title': 'Pharmacy - Medicine Bill', 'date': '05 Oct, 2023', 'amount': -850.0, 'status': 'Completed'},
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    final securityProvider = Provider.of<SecurityProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: ScaleOnTap(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, color: Color(0xFF2E4C9D)),
        ),
        title: Text(
          'Hospital Wallet',
          style: GoogleFonts.poppins(
            color: const Color(0xFF2E4C9D),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: AnimationLimiter(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 500),
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(child: widget),
              ),
              children: [
                _buildBalanceCard(securityProvider),
                const SizedBox(height: 30),
                Text(
                  'Transaction History',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 15),
                ..._transactions.map((group) => _buildHospitalGroup(group)).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(SecurityProvider securityProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E4C9D), Color(0xFF1E40AF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E4C9D).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Balance',
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              ScaleOnTap(
                onTap: () {
                  if (_isBalanceVisible) {
                    setState(() => _isBalanceVisible = false);
                  } else {
                    _verifyPin(securityProvider);
                  }
                },
                child: Icon(
                  _isBalanceVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.white.withOpacity(0.8),
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _isBalanceVisible ? '₹2,500.00' : '₹ • • • • • •',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: _buildBalanceAction(
                  icon: Icons.add_circle_outline,
                  label: 'Add Money',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildBalanceAction(
                  icon: Icons.send_rounded,
                  label: 'Pay Hospital',
                  onTap: () {},
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBalanceAction({required IconData icon, required String label, required VoidCallback onTap}) {
    return ScaleOnTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHospitalGroup(Map<String, dynamic> group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F6FE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(group['icon'] as IconData, color: const Color(0xFF2E4C9D), size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                group['hospital'] as String,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: (group['transactions'] as List).length,
            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[100], indent: 15, endIndent: 15),
            itemBuilder: (context, index) {
              final tx = (group['transactions'] as List)[index];
              final isNegative = (tx['amount'] as double) < 0;
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                title: Text(
                  tx['title'] as String,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                subtitle: Text(
                  tx['date'] as String,
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isNegative ? '-' : '+'}₹${(tx['amount'] as double).abs()}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isNegative ? Colors.redAccent : const Color(0xFF389B66),
                      ),
                    ),
                    Text(
                      tx['status'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: tx['status'] == 'Refunded' ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  void _verifyPin(SecurityProvider securityProvider) {
    if (!securityProvider.walletPinEnabled) {
      _showNoPinDialog();
      return;
    }

    final TextEditingController pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter PIN', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Verify to view balance.', style: GoogleFonts.poppins(fontSize: 13)),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 10),
              decoration: const InputDecoration(
                counterText: "",
                border: OutlineInputBorder(),
              ),
              onChanged: (val) async {
                if (val.length == 4) {
                  final isValid = await securityProvider.verifyWalletPin(val);
                  if (isValid) {
                    setState(() => _isBalanceVisible = true);
                    Navigator.pop(context);
                  } else {
                    pinController.clear();
                    ToknSnackBar.show(context, message: 'Invalid PIN');

                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNoPinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Setup PIN', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Set a Wallet PIN in Settings to see your balance.', style: GoogleFonts.poppins(fontSize: 14)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigation to settings would go here, but context might be tricky inside dialog
              // Usually better to pass a callback or use a Navigator observer
            },
            child: const Text('Go to Settings'),
          )
        ],
      ),
    );
  }
}
