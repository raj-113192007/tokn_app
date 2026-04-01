import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tokn/l10n/app_localizations.dart';

import 'package:provider/provider.dart';

import 'package:tokn/services/language_provider.dart';
import 'widgets/animation_utils.dart';
import 'services/api_service.dart';
import 'services/supabase_service.dart';
import 'profile_page.dart';
import 'complete_profile_page.dart';
import 'welcome_page.dart';
import 'widgets/tokn_snackbar.dart';


import 'edit_profile_page.dart';
import 'family_members_page.dart';
import 'package:tokn/services/security_service.dart';
import 'help_support_page.dart';
import 'tic_tac_toe_page.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _pushNotificationsEnabled = true;
  bool _turnOnReminders = true;
  int _aboutClickCount = 0;
  String? _fullName;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await SupabaseService().getProfile();
    if (profile != null && mounted) {
      setState(() {
        _fullName = profile['full_name'];
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    final securityProvider = Provider.of<SecurityProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: ScaleOnTap(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, color: Color(0xFF2E4C9D)),
        ),
        title: Text(
          AppLocalizations.of(context)!.settings,
          style: GoogleFonts.poppins(
            color: const Color(0xFF2E4C9D),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 10),


            const SizedBox(height: 10),
            Center(
              child: Text(
                _fullName ?? 'User',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E4C9D),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildCompleteProfileCard(),
            const SizedBox(height: 18),

            _buildSectionHeader('SECURITY & PRIVACY'),
            _buildTile(
              icon: Icons.language,
              title: AppLocalizations.of(context)!.language,
              subtitle: AppLocalizations.of(context)!.selectLanguage,
              onTap: () => _showLanguageSelectionDialog(context),
            ),
            _buildSwitchTile(
              icon: Icons.lock_outline,
              title: 'App Password (PIN)',
              subtitle: 'Protect your app with a 4-digit PIN',
              value: securityProvider.appPasswordEnabled,
              onChanged: (v) {
                if (v) {
                  _showSetPinGenericDialog(context, securityProvider, isWallet: false);
                } else {
                  securityProvider.setAppPasswordEnabled(false);
                }
              },

            ),
            _buildTile(
              icon: Icons.wallet_outlined,
              title: 'Wallet Password',
              subtitle: securityProvider.walletPinEnabled ? 'Change wallet PIN' : 'Set wallet PIN',
              onTap: () => _showSetPinGenericDialog(context, securityProvider, isWallet: true),
            ),


            const SizedBox(height: 10),
            _buildSwitchTile(
              icon: Icons.fingerprint,
              title: AppLocalizations.of(context)!.biometricLogin,
              subtitle: 'Use fingerprint/face to sign in',
              value: securityProvider.biometricEnabled,
              onChanged: (v) async {
                if (v) {
                  final authenticated = await securityProvider.authenticateBiometric();
                  if (authenticated) {
                    securityProvider.setBiometricEnabled(true);
                  }
                } else {
                  securityProvider.setBiometricEnabled(false);
                }
              },
            ),
            _buildSwitchTile(
              icon: Icons.notifications_none,
              title: AppLocalizations.of(context)!.notifications,
              subtitle: 'TokN booking alerts',
              value: _pushNotificationsEnabled,
              onChanged: (v) => setState(() => _pushNotificationsEnabled = v),
            ),
            _buildSwitchTile(
              icon: Icons.timer_outlined,
              title: AppLocalizations.of(context)!.reminders,
              subtitle: 'Get turn/time reminders',
              value: _turnOnReminders,
              onChanged: (v) => setState(() => _turnOnReminders = v),
            ),


            const SizedBox(height: 16),
            _buildSectionHeader('ACCOUNT'),
            _buildTile(
              icon: Icons.edit_note_outlined,
              title: AppLocalizations.of(context)!.editProfile,
              subtitle: 'Update your details',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfilePage()),
                );
              },
            ),
            _buildTile(
              icon: Icons.people_alt_outlined,
              title: AppLocalizations.of(context)!.manageFamily,
              subtitle: 'Add or remove members',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FamilyMembersPage()),
                );
              },
            ),

            const SizedBox(height: 16),
            _buildSectionHeader('SUPPORT'),
            _buildTile(
              icon: Icons.help_outline,
              title: AppLocalizations.of(context)!.helpCenter,
              subtitle: 'Get help with TokN',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HelpSupportPage()),
                );
              },
            ),
            _buildTile(
              icon: Icons.info_outline,
              title: AppLocalizations.of(context)!.aboutTokn,
              subtitle: 'Version 1.0.0',
              onTap: () {
                setState(() {
                  _aboutClickCount++;
                });

                if (_aboutClickCount >= 2 && _aboutClickCount < 5) {
                  ToknSnackBar.show(
                    context, 
                    message: 'You are ${5 - _aboutClickCount} clicks away from something interesting!',
                    type: SnackBarType.info,
                    duration: const Duration(seconds: 1),
                  );

                } else if (_aboutClickCount >= 5) {
                  setState(() => _aboutClickCount = 0);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TicTacToePage()),
                  );
                }
              },

            ),


            const SizedBox(height: 20),
            _buildLogoutButton(context),
            const SizedBox(height: 12),
            _buildDeleteAccountButton(context),
            const SizedBox(height: 10),
          ],

        ),
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.grey[700],
          letterSpacing: 0.6,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ScaleOnTap(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.withOpacity(0.08)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF0FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF2E4C9D)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.withOpacity(0.08)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF0FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF2E4C9D), size: 20),
          ),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: const Color(0xFF1F2937),
            ),
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF2E4C9D),
        ),
      ),
    );
  }


  Widget _buildCompleteProfileCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFFFF3F3),
            child: const Icon(Icons.error_outline, color: Colors.redAccent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Complete Your Profile',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your profile is ${'35'.toString()}% complete.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ScaleOnTap(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CompleteProfilePage()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
                      ),
                      child: Text(
                        'Finish Now',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          color: Colors.redAccent,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ScaleOnTap(
      onTap: () async {
        await SupabaseService().signOut();
        if (!context.mounted) return;


        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => WelcomePage()),
          (route) => false,
        );
      },
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.redAccent.withOpacity(0.35)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_outlined, color: Colors.redAccent),
            const SizedBox(width: 10),
            Text(
              AppLocalizations.of(context)!.logout,
              style: GoogleFonts.poppins(
                color: Colors.redAccent,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton(BuildContext context) {
    return ScaleOnTap(
      onTap: () {
        _showDeleteConfirmationDialog(context);
      },
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.delete_forever_outlined, color: Colors.redAccent),
            const SizedBox(width: 10),
            Text(
              AppLocalizations.of(context)!.deleteAccount,
              style: GoogleFonts.poppins(
                color: Colors.redAccent,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    final user = SupabaseService.client.auth.currentUser;
    final phone = user?.phone;

    showDialog(
      context: context,
      builder: (context) {
        bool isSendingOTP = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(AppLocalizations.of(context)!.deleteConfirmTitle, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.redAccent)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppLocalizations.of(context)!.deleteConfirmDesc, style: GoogleFonts.poppins(fontSize: 13)),
                  const SizedBox(height: 16),
                  if (phone != null && phone.isNotEmpty)
                    Text('A verification code will be sent to $phone.', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold))
                  else
                    Text('Warning: No phone number associated with your account.', style: GoogleFonts.poppins(fontSize: 12, color: Colors.redAccent)),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancel, style: GoogleFonts.poppins(color: Colors.grey)),
                ),
                isSendingOTP
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                    : TextButton(
                        onPressed: (phone == null || phone.isEmpty) ? null : () async {
                          setDialogState(() => isSendingOTP = true);
                          try {
                            // Send OTP
                            await SupabaseService().signInWithOtp(phone: phone);
                            if (context.mounted) {
                              Navigator.pop(context); // close confirm dialog
                              _showDeleteOTPVerifyDialog(context, phone); // open OTP dialog
                            }
                          } catch (e) {
                            if (context.mounted) ToknSnackBar.show(context, message: e.toString());
                          } finally {
                            if (mounted) setDialogState(() => isSendingOTP = false);
                          }
                        },
                        child: Text(AppLocalizations.of(context)!.sendOTP, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                      ),
              ],
            );
          }
        );
      },
    );
  }

  void _showDeleteOTPVerifyDialog(BuildContext context, String phone) {
    final otpController = TextEditingController();
    bool isVerifying = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(AppLocalizations.of(context)!.verifyOTP, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppLocalizations.of(context)!.enterOTP, style: GoogleFonts.poppins(fontSize: 13)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8),
                    decoration: const InputDecoration(counterText: "", border: OutlineInputBorder()),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancel, style: GoogleFonts.poppins(color: Colors.grey)),
                ),
                isVerifying
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                    : TextButton(
                        onPressed: () async {
                          if (otpController.text.length < 6) return;
                          setDialogState(() => isVerifying = true);
                          try {
                            await SupabaseService().verifyOTP(
                              phone: phone,
                              token: otpController.text.trim(),
                            );
                            
                            // Verification succeeded, delete the user
                            await SupabaseService().deleteUserAccount();
                            
                            if (context.mounted) {
                              ToknSnackBar.show(context, message: 'Account deleted successfully.');
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => const WelcomePage()),
                                (route) => false,
                              );
                            }
                          } catch (e) {
                            if (context.mounted) ToknSnackBar.show(context, message: e.toString());
                            setDialogState(() => isVerifying = false);
                          }
                        },
                        child: Text(AppLocalizations.of(context)!.deleteAccount, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                      ),
              ],
            );
          }
        );
      },
    );
  }


  void _showLanguageSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.selectLanguage, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption(context, AppLocalizations.of(context)!.english, 'en'),
              _buildLanguageOption(context, AppLocalizations.of(context)!.hindi, 'hi'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(BuildContext context, String title, String code) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final isSelected = languageProvider.currentLocale.languageCode == code;

    return ListTile(
      title: Text(title, style: GoogleFonts.poppins(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF2E4C9D)) : null,
      onTap: () {
        languageProvider.changeLanguage(code);
        Navigator.pop(context);
      },
    );
  }

  void _showSetPinGenericDialog(BuildContext context, SecurityProvider securityProvider, {required bool isWallet}) {
    String firstPin = '';
    bool isConfirming = false;
    final TextEditingController pinController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(
              isConfirming ? 'Confirm PIN' : (isWallet ? 'Set Wallet PIN' : 'Set App PIN'),
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isConfirming ? 'Please confirm your 4-digit PIN.' : 'Enter a 4-digit PIN to secure your ${isWallet ? 'Wallet' : 'App'}.',
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: pinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  textAlign: TextAlign.center,
                  autofocus: true,
                  style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 10),
                  decoration: const InputDecoration(
                    counterText: "",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) {
                    if (val.length == 4) {
                      if (!isConfirming) {
                        setDialogState(() {
                          firstPin = val;
                          isConfirming = true;
                          pinController.clear();
                        });
                      } else {
                        if (firstPin == val) {
                          // PINs match
                          if (isWallet) {
                            securityProvider.setWalletPinEnabled(true, pin: val);
                          } else {
                            securityProvider.setAppPasswordEnabled(true, pin: val);
                          }
                          Navigator.pop(context);
                          _showSuccessPopup(context, '${isWallet ? 'Wallet' : 'App'} PIN set successfully!');
                        } else {
                          // Mismatch
                          pinController.clear();
                          ToknSnackBar.show(context, message: 'PINs do not match. Starting over.', type: SnackBarType.warning);

                          setDialogState(() {
                            isConfirming = false;
                            firstPin = '';
                          });
                        }
                      }
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSuccessPopup(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, color: Color(0xFF389B66), size: 60),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF2E4C9D))),
          )
        ],
      ),
    );
  }
}


