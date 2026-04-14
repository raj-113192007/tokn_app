import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/animation_utils.dart';
import 'package:tokn/l10n/app_localizations.dart';
import 'widgets/glass_bottom_bar.dart';
import 'package:url_launcher/url_launcher.dart';

import 'services/api_service.dart';
import 'services/supabase_service.dart';
import 'services/wallet_service.dart';
import 'widgets/tokn_snackbar.dart';
import 'services/notification_service.dart';


class HospitalDetailsPage extends StatefulWidget {
  final String hospitalId;
  final String hospitalName;
  final String hospitalImage;

  const HospitalDetailsPage({
    super.key,
    required this.hospitalId,
    required this.hospitalName,
    required this.hospitalImage,
  });

  @override
  State<HospitalDetailsPage> createState() => _HospitalDetailsPageState();
}

class _HospitalDetailsPageState extends State<HospitalDetailsPage> {
  bool _isLiked = false;
  bool _isLoadingLike = true;
  Map<String, dynamic>? _hospitalDetails;
  bool _isLoadingDetails = true;
  List<dynamic> _familyMembers = [];
  bool _isLoadingFamily = true;
  bool _isProcessingBooking = false;

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
    _fetchFamilyMembers();
    _fetchHospitalDetails();
  }

  Future<void> _fetchHospitalDetails() async {
    final details = await ApiService.getHospitalDetails(widget.hospitalId);
    if (mounted) {
      setState(() {
        _hospitalDetails = details;
        _isLoadingDetails = false;
      });
    }
  }

  Future<void> _checkIfLiked() async {
    final liked = await SupabaseService().isHospitalLiked(widget.hospitalId);
    if (mounted) {
      setState(() {
        _isLiked = liked;
        _isLoadingLike = false;
      });
    }
  }

  Future<void> _fetchFamilyMembers() async {
    try {
      final members = await SupabaseService().getFamilyMembers();
      if (mounted) {
        setState(() {
          _familyMembers = members;
          _isLoadingFamily = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingFamily = false);
    }
  }

  Future<void> _toggleLike() async {
    if (_isLoadingLike) return;
    setState(() => _isLoadingLike = true);
    try {
      final nowLiked = await SupabaseService().toggleHospitalLike(widget.hospitalId);
      if (mounted) setState(() => _isLiked = nowLiked);
    } catch (e) {
      if (mounted) ToknSnackBar.show(context, message: 'Failed to update favorite');
    } finally {
      if (mounted) setState(() => _isLoadingLike = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: ScaleOnTap(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Text(
          AppLocalizations.of(context)!.hospitalDetails,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          ScaleOnTap(
            onTap: () {},
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.share_outlined, color: Colors.black),
            ),
          ),
          ScaleOnTap(
            onTap: _toggleLike,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _isLoadingLike 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_border, 
                      color: _isLiked ? Colors.redAccent : Colors.black
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hospital Image and Badge
            Stack(
              children: [
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(_hospitalDetails?['image_url'] ?? widget.hospitalImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircleAvatar(
                          radius: 4,
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.online,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.hospitalName.replaceAll('\n', ' '),
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A1C1E),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEFC6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Color(0xFFE5A500), size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '4.8',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFE5A500),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _hospitalDetails?['specialties'] != null && (_hospitalDetails!['specialties'] as List).isNotEmpty
                        ? (_hospitalDetails!['specialties'] as List).join(' • ')
                        : 'Specialty Healthcare Center',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF2E4C9D),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Address and Directions
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E4C9D).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.location_on, color: Color(0xFF2E4C9D)),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _hospitalDetails?['location'] ?? 'Location not specified',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Hospital Address',
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        ScaleOnTap(
                          onTap: () async {
                            final mapUrl = _hospitalDetails?['location_url'];
                            if (mapUrl != null && mapUrl.toString().isNotEmpty) {
                              final uri = Uri.parse(mapUrl);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              } else {
                                if (mounted) ToknSnackBar.show(context, message: 'Could not launch maps');
                              }
                            } else {
                              if (mounted) ToknSnackBar.show(context, message: 'Map link not provided for this hospital');
                            }
                          },
                          child: Container(
                            height: 45,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E4C9D),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.directions_outlined, color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  AppLocalizations.of(context)!.directions,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // About Section
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E4C9D),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        AppLocalizations.of(context)!.aboutHospital,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    _hospitalDetails?['about'] ?? 'This hospital has not provided a description yet.',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[700],
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Specialties
                  Text(
                    AppLocalizations.of(context)!.specialties,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: _hospitalDetails?['specialties'] == null || (_hospitalDetails!['specialties'] as List).isEmpty
                      ? Center(child: Text('No specific specialties listed', style: TextStyle(fontSize: 12, color: Colors.grey)))
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: (_hospitalDetails!['specialties'] as List).length,
                          itemBuilder: (context, index) {
                            final specialty = _hospitalDetails!['specialties'][index];
                            return ScaleOnTap(
                              onTap: () {}, 
                              child: _buildSpecialtyChip(Icons.medical_services_outlined, specialty.toString())
                            );
                          },
                        ),
                  ),

                  const SizedBox(height: 30),

                  // Specialist Doctors
                  Text(
                    AppLocalizations.of(context)!.specialistDoctors,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 180,
                    child: _hospitalDetails?['doctors'] == null || (_hospitalDetails!['doctors'] as List).isEmpty
                      ? Center(child: Text('No doctors listed for this hospital', style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: (_hospitalDetails!['doctors'] as List).length,
                          itemBuilder: (context, index) {
                            final doc = _hospitalDetails!['doctors'][index];
                            return ScaleOnTap(
                              onTap: () {},
                              child: _buildDoctorCard(
                                doc['full_name'] ?? 'Doctor',
                                doc['specialty'] ?? 'Specialist',
                                doc['avatar_url'] ?? 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=200',
                              ),
                            );
                          },
                        ),
                  ),

                  const SizedBox(height: 30),

                  // Services Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    childAspectRatio: 2.2,
                    children: [
                      ScaleOnTap(onTap: () {}, child: _buildServiceItem(Icons.ac_unit, 'ER 24/7')),
                      ScaleOnTap(onTap: () {}, child: _buildServiceItem(Icons.local_pharmacy, 'Pharmacy')),
                      ScaleOnTap(onTap: () {}, child: _buildServiceItem(Icons.biotech, 'Lab Tests')),
                      ScaleOnTap(onTap: () {}, child: _buildServiceItem(Icons.settings_overscan, 'MRI / X-Ray')),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Map Placeholder
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1526778548025-fa2f459cd5c1?w=800',
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: GlassBottomBar(
        height: 100,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 20),
          child: Row(
            children: [
              // Normal Booking
              Expanded(
                child: _buildBookingTypeButton(
                  context,
                  label: AppLocalizations.of(context)!.normalBooking,
                  price: '₹19',
                  color: const Color(0xFF2E4C9D),
                  onTap: () => _showPatientSelector(context, 'Normal', 19.0),
                ),
              ),
              const SizedBox(width: 12),
              // Emergency Booking
              Expanded(
                child: _buildBookingTypeButton(
                  context,
                  label: 'Emer...',
                  fullLabel: 'Emergency',
                  price: '₹49',
                  color: Colors.redAccent,
                  onTap: () => _showPatientSelector(context, 'Emergency', 49.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingTypeButton(
    BuildContext context, {
    required String label,
    String? fullLabel,
    required String price,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ScaleOnTap(
      onTap: _isProcessingBooking ? null : onTap,
      child: Opacity(
        opacity: _isProcessingBooking ? 0.6 : 1.0,
        child: Container(
        height: 65,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              MediaQuery.of(context).size.width < 360 ? label : (fullLabel ?? label),
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              price,
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  final _problemController = TextEditingController();

  void _showPatientSelector(BuildContext context, String type, double price) {
    if (_isProcessingBooking) return;
    _problemController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context)!.selectPatient,
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              // Problem Description Field
              Text(
                AppLocalizations.of(context)!.describeProblem,
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _problemController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.describeProblemHint,
                  hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                AppLocalizations.of(context)!.whoIsTokenFor,
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700]),
              ),
              const SizedBox(height: 12),
              // Myself
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFF2E4C9D).withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.person_outline, color: Color(0xFF2E4C9D)),
                ),
                title: Text(AppLocalizations.of(context)!.bookMyself, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                subtitle: Text(AppLocalizations.of(context)!.bookMyselfDesc, style: GoogleFonts.poppins(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  _handleBooking(context, type, price, 'Myself', _problemController.text);
                },
              ),
              if (_familyMembers.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(),
                ),
                ..._familyMembers.map((member) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.people_outline, color: Colors.orange),
                    ),
                    title: Text(member['full_name'] ?? 'Family Member', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    subtitle: Text(member['relationship'] ?? 'Member', style: GoogleFonts.poppins(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pop(context);
                      _handleBooking(context, type, price, member['full_name'], _problemController.text);
                    },
                  ),
                )).toList(),
              ] else if (!_isLoadingFamily) 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: Text(AppLocalizations.of(context)!.noFamilyMembersAdded, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13)),
                  ),
                ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleBooking(BuildContext context, String type, double price, String patientName, String description) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Payment Method',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Total Amount: ₹$price',
              style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF2E4C9D), fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            
            // Wallet Option
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.shade200)),
              leading: const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF2E4C9D)),
              title: Text('TokN Wallet', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              subtitle: Text('Pay using your wallet balance', style: GoogleFonts.poppins(fontSize: 12)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                _processWalletPayment(type, price, patientName, description);
              },
            ),
            const SizedBox(height: 12),
            
            // UPI Option
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.shade200)),
              leading: const Icon(Icons.qr_code_scanner, color: Colors.green),
              title: Text('UPI Apps', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              subtitle: Text('Google Pay, PhonePe, etc.', style: GoogleFonts.poppins(fontSize: 12)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                _processUpiPayment(type, price, patientName, description);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  final WalletService _walletService = WalletService();

  Future<void> _processWalletPayment(String type, double price, String patientName, String description) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final result = await _walletService.deductBalance(
      amount: price,
      description: '$type Booking for $patientName',
    );

    if (mounted) {
      Navigator.pop(context); // Close loading

      if (result['success'] == true) {
        _finalizeBooking(type, price, patientName, description);
      } else {
        ToknSnackBar.show(context, message: result['message'] ?? 'Insufficient wallet balance');
      }
    }
  }

  Future<void> _processUpiPayment(String type, double price, String patientName, String description) async {
    if (_isProcessingBooking) return;
    
    final success = await _walletService.launchUpiPayment(
      amount: price,
      note: '$type Booking Payment'
    );

    if (success && mounted) {
      // Show confirmation dialog after returning from UPI app
      _showUpiConfirmation(type, price, patientName, description);
    } else if (mounted) {
      ToknSnackBar.show(context, message: 'Could not open UPI apps');
    }
  }

  void _showUpiConfirmation(String type, double price, String patientName, String description) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Confirm Payment', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(
          'Have you completed the payment of ₹$price for your $type token? Click "Confirm" only after the payment is successful in your UPI app.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _finalizeBooking(type, price, patientName, description);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E4C9D),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Confirm & Book', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _finalizeBooking(String type, double price, String patientName, String description) async {
    if (_isProcessingBooking) return;
    setState(() => _isProcessingBooking = true);
    
    final now = DateTime.now();
    final dateStr = "${now.year}-${now.month}-${now.day}";
    final timeStr = "${now.hour}:${now.minute}";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await ApiService.createBooking(
        hospitalId: widget.hospitalId,
        date: dateStr,
        time: timeStr,
        type: type,
        price: price,
        patientName: patientName,
        description: description,
      );

      if (mounted) {
        Navigator.pop(context); // Close loading

        if (result['success'] == true) {
        final token = result['data']['token_number'].toString();
        
        // Trigger Notification
        await NotificationService.requestPermission();
        await NotificationService.showBookingConfirmation(
          patientName: patientName,
          type: type,
          token: token,
        );

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(AppLocalizations.of(context)!.bookingConfirmed, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${AppLocalizations.of(context)!.tokenFor} $patientName', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF2E4C9D))),
                const SizedBox(height: 16),
                Text(AppLocalizations.of(context)!.yourTokenIs(type), style: GoogleFonts.poppins()),
                const SizedBox(height: 10),
                Text(
                  token,
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: type == 'Emergency' ? Colors.redAccent : const Color(0xFF2E4C9D),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context); // Go back home or to bookings
                },
                child: Text('OK', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Booking Failed', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.redAccent)),
            content: Text(
              result['error'] ?? 'There was an error creating your booking. If you have already paid, please contact support with your transaction details.',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
      
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ToknSnackBar.show(context, message: 'Booking error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingBooking = false);
      }
    }
  }

  Widget _buildSpecialtyChip(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.orange[700]),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.orange[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(String name, String specialty, String imageUrl) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundImage: NetworkImage(imageUrl),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle, color: Colors.green, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            specialty,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: const Color(0xFF2E4C9D),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(IconData icon, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF2E4C9D), size: 22),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
