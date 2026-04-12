import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'services/security_service.dart';
import 'services/wallet_service.dart';
import 'widgets/animation_utils.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'widgets/tokn_snackbar.dart';
import 'widgets/tokn_snackbar.dart';
import 'settings_page.dart';


class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  bool _isBalanceVisible = false;
  final WalletService _walletService = WalletService();
  double _balance = 0.0;
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    final balance = await _walletService.getBalance();
    final history = await _walletService.getTransactionHistory();
    setState(() {
      _balance = balance;
      _history = history;
      _isLoading = false;
    });
  }

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
        actions: [
          IconButton(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh, color: Color(0xFF2E4C9D)),
          )
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : AnimationLimiter(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                      if (_history.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Column(
                              children: [
                                Icon(Icons.history, size: 60, color: Colors.grey[300]),
                                const SizedBox(height: 10),
                                Text(
                                  'No transactions yet',
                                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ..._history.map((tx) => _buildTransactionItem(tx)).toList(),
                    ],
                  ),
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
            _isBalanceVisible ? '₹${_balance.toStringAsFixed(2)}' : '₹ • • • • • •',
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
                  onTap: _showAddMoneyDialog,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildBalanceAction(
                  icon: Icons.send_rounded,
                  label: 'Pay Hospital',
                  onTap: () {
                    ToknSnackBar.show(context, message: 'Select a hospital from home to pay.');
                  },
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

  Widget _buildTransactionItem(Map<String, dynamic> tx) {
    final amount = (tx['amount'] as num).toDouble();
    final isCredit = tx['transaction_type'] == 'credit';
    final date = DateTime.parse(tx['created_at']).toLocal();
    final formattedDate = "${date.day} ${_getMonth(date.month)}, ${date.year}";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isCredit ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCredit ? Icons.arrow_downward : Icons.arrow_upward,
            color: isCredit ? Colors.green : Colors.red,
            size: 20,
          ),
        ),
        title: Text(
          tx['description'] ?? (isCredit ? 'Wallet Recharge' : 'Payment'),
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        subtitle: Text(
          formattedDate,
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isCredit ? '+' : '-'}₹${amount.abs()}',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isCredit ? const Color(0xFF389B66) : Colors.redAccent,
              ),
            ),
            Text(
              tx['status']?.toString().toUpperCase() ?? 'PENDING',
              style: GoogleFonts.poppins(
                fontSize: 9,
                color: tx['status'] == 'completed' ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  void _showAddMoneyDialog() {
    final TextEditingController amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Money', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'Enter Amount',
                prefixText: '₹ ',
                hintStyle: GoogleFonts.poppins(fontSize: 18, color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [100, 500, 1000].map((amt) => ActionChip(
                label: Text('₹$amt'),
                onPressed: () => amountController.text = amt.toString(),
              )).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E4C9D),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                Navigator.pop(context);
                _selectUpiApp(amount);
              } else {
                ToknSnackBar.show(context, message: 'Please enter a valid amount');
              }
            },
            child: const Text('Proceed', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  void _selectUpiApp(double amount) async {
    final success = await _walletService.launchUpiPayment(
      amount: amount,
      note: 'Wallet Recharge'
    );

    if (success && mounted) {
      // For personal UPI IDs, we finalize immediately as we can't track real-time bank status
      final successFinal = await _walletService.finalizeRecharge(
        amount: amount,
        txnId: 'TOK-${DateTime.now().millisecondsSinceEpoch}',
        responseCode: '00',
      );
      if (successFinal && mounted) {
        ToknSnackBar.show(context, message: 'Wallet recharged successfully!', type: SnackBarType.success);
        _refreshData();
      }
    } else if (mounted) {
      ToknSnackBar.show(context, message: 'Could not open UPI apps');
    }
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
              Navigator.pop(context); // Close dialog
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
            child: const Text('Go to Settings'),
          )
        ],
      ),
    );
  }
}
