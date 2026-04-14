// ignore_for_file: avoid_print, unused_local_variable, unused_element, use_build_context_synchronously, unused_field, file_names, constant_identifier_names, deprecated_member_use, unused_import
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/animation_utils.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'services/scroll_notifier.dart';
import 'settings_page.dart';
import 'package:tokn/l10n/app_localizations.dart';
import 'add_member_page.dart';
import 'package:provider/provider.dart';
import 'services/security_service.dart';
import 'wallet_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/supabase_service.dart';
import 'widgets/tokn_snackbar.dart';




class ProfilePage extends StatefulWidget {
  final ScrollNotifier? scrollNotifier;

  const ProfilePage({super.key, this.scrollNotifier});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userName = 'User';
  String _userEmail = '';
  String _userPhone = '';
  String _age = 'Not Set';
  String _bloodGroup = 'Not Set';
  String _customId = 'Pending';
  final String _tokensBooked = '0';
  int _familyMemberCount = 0;
  bool _isEmailVerified = false;

  late final ScrollController _profileScrollController;
  bool _isBalanceVisible = false;
  String? _avatarUrl;
  bool _isUploading = false;
  bool _isProfileComplete = false;



  @override
  void initState() {
    super.initState();
    _profileScrollController = ScrollController();
    // Register scroll controller so the bottom bar can hide/show on this tab.
    widget.scrollNotifier?.registerPageController('profile', _profileScrollController);
    _loadUserData();
  }

  @override
  void dispose() {
    widget.scrollNotifier?.unregisterPageController('profile');
    _profileScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final profile = await SupabaseService().getProfile();
    final members = await SupabaseService().getFamilyMembers();
    final user = SupabaseService.client.auth.currentUser;

    if (profile != null && mounted) {
      setState(() {
        _userName = profile['full_name'] ?? 'User';
        _userEmail = profile['email'] ?? 'Update email in settings';
        _userPhone = profile['phone'] ?? 'Update phone in settings';
        _avatarUrl = profile['avatar_url'];
        _age = profile['age'] != null ? '${profile['age']} ${AppLocalizations.of(context)!.years}' : 'Not Set';
        _bloodGroup = profile['blood_group'] ?? 'Not Set';
        _customId = profile['custom_id'] ?? 'Pending';
        _familyMemberCount = members.length;
        _isEmailVerified = user?.emailConfirmedAt != null;
        
        // Comprehensive check for profile completion
        _isProfileComplete = (profile['full_name'] != null && profile['full_name'] != 'User') &&
                             (profile['age'] != null) &&
                             (profile['blood_group'] != null);
        // You could query tokens_booked from a separate table if needed
      });
    } else {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _userName = prefs.getString('user_name') ?? 'User';
        _userEmail = prefs.getString('user_email') ?? 'Update email in settings';
        _userPhone = prefs.getString('user_phone') ?? 'Update phone in settings';
        _familyMemberCount = members.length;
        _isEmailVerified = user?.emailConfirmedAt != null;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      if (!status.isGranted) return;
    } else {
      final status = await Permission.photos.request();
      if (!status.isGranted && !status.isLimited) {
        await Permission.storage.request();
      }
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 512,
    );

    if (image != null) {
      setState(() => _isUploading = true);
      try {
        final newUrl = await SupabaseService().uploadProfilePhoto(image.path);
        if (newUrl != null && mounted) {
          setState(() => _avatarUrl = newUrl);
          ToknSnackBar.show(context, message: 'Profile photo updated!', type: SnackBarType.success);

        }
      } catch (e) {
        if (mounted) {
          ToknSnackBar.show(context, message: 'Upload failed: $e');

        }
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF2E4C9D)),
              title: Text('Camera', style: GoogleFonts.poppins()),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF2E4C9D)),
              title: Text('Gallery', style: GoogleFonts.poppins()),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,

        title: Text(
          AppLocalizations.of(context)!.profile,
          style: GoogleFonts.poppins(
            color: const Color(0xFF2E4C9D),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          ScaleOnTap(
            onTap: () {
              widget.scrollNotifier?.reset();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Icon(Icons.settings_outlined, color: Color(0xFF2E4C9D)),
            ),
          ),
        ],
      ),
      body: AnimationLimiter(
        child: SingleChildScrollView(
          controller: _profileScrollController,
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 500),
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(child: widget),
              ),
              children: [
                const SizedBox(height: 20),
                // Profile Image with online indicator
                Center(
                  child: Stack(
                    children: [
                      ScaleOnTap(
                        onTap: () => _showImageSourceActionSheet(context),
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              )
                            ],
                            image: DecorationImage(
                              image: _avatarUrl != null 
                                  ? NetworkImage(_avatarUrl!) 
                                  : const NetworkImage('https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=400'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: _avatarUrl == null && !_isUploading
                              ? const Center(child: Icon(Icons.person, size: 40, color: Colors.white54))
                              : null,
                        ),
                      ),
                      if (_isUploading)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(color: Colors.white),
                            ),
                          ),
                        ),
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 10,
                        child: ScaleOnTap(
                          onTap: () => _showImageSourceActionSheet(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFF2E4C9D),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                // Name and Email
                Text(
                  _userName,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                // Profile Completion Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isProfileComplete 
                        ? Colors.green.withValues(alpha: 0.12) 
                        : Colors.redAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isProfileComplete 
                          ? Colors.green.withValues(alpha: 0.3) 
                          : Colors.redAccent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isProfileComplete ? Icons.check_circle_outline : Icons.error_outline, 
                        color: _isProfileComplete ? Colors.green : Colors.redAccent, 
                        size: 16
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isProfileComplete ? AppLocalizations.of(context)!.profileComplete : AppLocalizations.of(context)!.profileIncomplete,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _isProfileComplete ? Colors.green : Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),
                // Add Family Member Button (only if count < 5)
                if (_familyMemberCount < 5)
                  ScaleOnTap(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddMemberPage()),
                      ).then((_) => _loadUserData());
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E4C9D),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2E4C9D).withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)!.addFamilyMemberTitle,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 35),
                // Info Grid
                  Row(
                    children: [
                      Expanded(child: _buildInfoCard(AppLocalizations.of(context)!.age, _age)),
                      const SizedBox(width: 15),
                      Expanded(child: _buildInfoCard(AppLocalizations.of(context)!.bloodGroup, _bloodGroup, valueColor: Colors.redAccent)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: _buildInfoCard(AppLocalizations.of(context)!.tokensBooked, _tokensBooked)),
                      const SizedBox(width: 15),
                      Expanded(child: _buildInfoCard(AppLocalizations.of(context)!.uniqueId, _customId, isCompact: true)),
                    ],
                  ),
                const SizedBox(height: 15),
                // Contact Section: Mobile and Email
                _buildContactCard(Icons.phone_android_outlined, AppLocalizations.of(context)!.mobile, _userPhone),
                const SizedBox(height: 15),
                _buildContactCard(
                  Icons.email_outlined, 
                  AppLocalizations.of(context)!.email, 
                  _userEmail, 
                  isEmail: true,
                  isVerified: _isEmailVerified,
                  onVerify: () {
                    SupabaseService().resendOTP(email: _userEmail, type: OtpType.signup);
                    ToknSnackBar.show(context, message: 'Verification link resent!', type: SnackBarType.success);
                  },
                ),
                const SizedBox(height: 15),
                _buildContactCard(
                  Icons.people_outline, 
                  AppLocalizations.of(context)!.familyMembers, 
                  AppLocalizations.of(context)!.membersAdded('$_familyMemberCount'),
                ),
                const SizedBox(height: 25),
                _buildWalletCard(context),
                const SizedBox(height: 25),
                // Ayushman Card
                _buildAyushmanCard(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, {Color? valueColor, bool isCompact = false}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 12),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: valueColor ?? Colors.black,
              fontSize: isCompact ? 13 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(
    IconData icon, 
    String label, 
    String value, {
    bool isEmail = false, 
    bool isVerified = false,
    VoidCallback? onVerify,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF2E4C9D), size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 12),
                    ),
                    if (isEmail) ...[
                      const SizedBox(width: 8),
                      Icon(
                        isVerified ? Icons.verified : Icons.error_outline,
                        color: isVerified ? Colors.blue : Colors.orange,
                        size: 14,
                      ),
                      Text(
                        isVerified ? AppLocalizations.of(context)!.verified : AppLocalizations.of(context)!.unverified,
                        style: GoogleFonts.poppins(
                          color: isVerified ? Colors.blue : Colors.orange,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ]
                  ],
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isEmail && !isVerified)
            TextButton(
              onPressed: onVerify,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                backgroundColor: const Color(0xFF2E4C9D).withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'Verify',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E4C9D),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAyushmanCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF2E7D32),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.ayushmanCard,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF2E7D32),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Text(
            AppLocalizations.of(context)!.cardNumber,
            style: GoogleFonts.poppins(color: Colors.green[800], fontSize: 10, letterSpacing: 1),
          ),
          const SizedBox(height: 5),
          Text(
            '1234  5678  9012',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.govtOfIndia,
                style: GoogleFonts.poppins(color: Colors.green[800], fontSize: 10, fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.qr_code_2, color: Color(0xFF2E7D32), size: 30),
            ],
          )
        ],
      ),
    );
  }

  void _verifyPinAndShowBalance(BuildContext context, SecurityProvider securityProvider) {
    if (!securityProvider.walletPinEnabled) {
      // PIN not set, show popup and redirect
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Setup PIN Required', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: Text('Please set a Wallet PIN in Settings to view your balance.', style: GoogleFonts.poppins(fontSize: 14)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Later', style: GoogleFonts.poppins(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E4C9D),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Setup Now', style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        ),
      );
      return;
    }

    // PIN is set, ask for it
    final TextEditingController pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.enterWalletPin, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context)!.verifyIdentity, style: GoogleFonts.poppins(fontSize: 13)),
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
                    ToknSnackBar.show(context, message: 'Invalid PIN. Please try again.');

                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final securityProvider = Provider.of<SecurityProvider>(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WalletPage()),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_balance_wallet, color: Color(0xFF2E4C9D), size: 24),
                    const SizedBox(width: 12),
                    Text(
                      l10n.hospitalWallet,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
                Text(
                  l10n.viewHistory,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2E4C9D),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.availableBalance,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500],
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          _isBalanceVisible ? '₹2,500' : '₹ • • • •',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF389B66),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ScaleOnTap(
                          onTap: () {
                            if (_isBalanceVisible) {
                              setState(() => _isBalanceVisible = false);
                            } else {
                              _verifyPinAndShowBalance(context, securityProvider);
                            }
                          },
                          child: Icon(
                            _isBalanceVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            size: 20,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                ScaleOnTap(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E4C9D),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.add_circle_outline, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          l10n.addMoney,
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
          ),

          const SizedBox(height: 24),
          Text(
            l10n.recentTransactions,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 16),
          _buildTransactionItem(
            icon: Icons.receipt_long_outlined,
            title: 'Token #42 Payment',
            date: 'Oct 14, 2023',
            amount: '- ₹500',
            isNegative: true,
          ),
          const Divider(height: 24, color: Color(0xFFF0F0F0)),
          _buildTransactionItem(
            icon: Icons.add_circle_outline,
            title: l10n.addMoney,
            date: 'Oct 10, 2023',
            amount: '+ ₹1000',
            isNegative: false,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required String title,
    required String date,
    required String amount,
    required bool isNegative,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isNegative ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isNegative ? Colors.redAccent : const Color(0xFF389B66),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                date,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
        Text(
          amount,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isNegative ? Colors.redAccent : const Color(0xFF389B66),
          ),
        ),
      ],
    );
  }
}
