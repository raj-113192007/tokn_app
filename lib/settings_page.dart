import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tokn/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:tokn/services/language_provider.dart';
import 'widgets/animation_utils.dart';
import 'services/api_service.dart';
import 'profile_page.dart';
import 'complete_profile_page.dart';
import 'welcome_page.dart';
import 'edit_profile_page.dart';
import 'family_members_page.dart';
import 'package:tokn/services/security_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _pushNotificationsEnabled = true;
  bool _turnOnReminders = true;

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
            _buildCompleteProfileCard(),
            const SizedBox(height: 18),
            _buildSectionHeader('SECURITY & PRIVACY'),
            _buildTile(
              icon: Icons.language,
              title: AppLocalizations.of(context)!.language,
              subtitle: AppLocalizations.of(context)!.selectLanguage,
              onTap: () => _showLanguageSelectionDialog(context),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.lock_outline, color: Color(0xFF2E4C9D)),
              title: Text(
                'App Password (PIN)',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Protect your app with a 4-digit PIN',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              value: securityProvider.appPasswordEnabled,
              onChanged: (v) {
                if (v) {
                  _showSetPinDialog(context, securityProvider);
                } else {
                  securityProvider.setAppPasswordEnabled(false);
                }
              },
              activeColor: const Color(0xFF2E4C9D),
            ),
            _buildTile(
              icon: Icons.wallet_outlined,
              title: 'Wallet Password',
              subtitle: 'Change wallet PIN',
              onTap: () {},
            ),
            const SizedBox(height: 4),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.fingerprint, color: Color(0xFF2E4C9D)),
              title: Text(
                AppLocalizations.of(context)!.biometricLogin,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Use fingerprint/face to sign in',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
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
              activeColor: const Color(0xFF2E4C9D),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                AppLocalizations.of(context)!.notifications,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'TokN booking alerts',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              value: _pushNotificationsEnabled,
              onChanged: (v) => setState(() => _pushNotificationsEnabled = v),
              activeColor: const Color(0xFF2E4C9D),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                AppLocalizations.of(context)!.reminders,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Get turn/time reminders',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              value: _turnOnReminders,
              onChanged: (v) => setState(() => _turnOnReminders = v),
              activeColor: const Color(0xFF2E4C9D),
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
              onTap: () {},
            ),
            _buildTile(
              icon: Icons.info_outline,
              title: AppLocalizations.of(context)!.aboutTokn,
              subtitle: 'Version 1.0.0',
              onTap: () {},
            ),

            const SizedBox(height: 20),
            _buildLogoutButton(context),
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
        await ApiService.logout();
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

  void _showSetPinDialog(BuildContext context, SecurityProvider securityProvider) {
    final TextEditingController pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set App PIN', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter a 4-digit PIN to secure your app.', style: GoogleFonts.poppins(fontSize: 13)),
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
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (pinController.text.length == 4) {
                securityProvider.setAppPasswordEnabled(true, pin: pinController.text);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E4C9D),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Save', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
