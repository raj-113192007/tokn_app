import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tokn/l10n/app_localizations.dart';
import 'widgets/animation_utils.dart';
import 'widgets/tokn_snackbar.dart';
import 'services/supabase_service.dart';


class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController(text: 'John Doe');
  final TextEditingController _emailController = TextEditingController(text: 'john.doe@email.com');
  final TextEditingController _phoneController = TextEditingController(text: '9876543210');
  final TextEditingController _emergencyContactController = TextEditingController();
  bool _isLoading = false;



  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: ScaleOnTap(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Color(0xFF2E4C9D)),
        ),
        title: Text(
          l10n.editProfileTitle,
          style: GoogleFonts.poppins(
            color: const Color(0xFF2E4C9D),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 32),
            _buildAvatarSection(),
            const SizedBox(height: 48),
            _buildSectionTitle(l10n.personalInfo),
            const SizedBox(height: 16),
            _buildInputField(l10n.fullName, _nameController, Icons.person_outline),
            const SizedBox(height: 20),
            _buildInputField(l10n.emailAddress, _emailController, Icons.email_outlined, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 20),
            _buildInputField(l10n.phoneNumber, _phoneController, Icons.phone_android_outlined, keyboardType: TextInputType.phone, isPhone: true),
            const SizedBox(height: 20),
            _buildInputField(l10n.emergencyContact, _emergencyContactController, Icons.contact_emergency_outlined, keyboardType: TextInputType.phone, isPhone: true),

            const SizedBox(height: 60),
            _buildSaveButton(l10n.updateProfile),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF2F6FE), width: 6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
              image: const DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=400'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: ScaleOnTap(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E4C9D),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E4C9D).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[500],
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    bool isPhone = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F9FC).withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF2F6FE)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: GoogleFonts.poppins(
                color: Colors.grey[500],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              border: InputBorder.none,
              icon: Icon(icon, color: const Color(0xFF2E4C9D), size: 20),
              prefixText: isPhone ? '+91 ' : null,
              prefixStyle: GoogleFonts.poppins(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              floatingLabelBehavior: FloatingLabelBehavior.auto,
            ),
          ),
        ),
      ],
    );
  }



  Widget _buildSaveButton(String text) {
    return ScaleOnTap(
      onTap: _isLoading ? null : () async {
        setState(() => _isLoading = true);
        try {
          final data = {
            if (_nameController.text.isNotEmpty) 'full_name': _nameController.text.trim(),
            if (_phoneController.text.isNotEmpty) 'phone_number': _phoneController.text.trim(),
            if (_emergencyContactController.text.isNotEmpty) 'emergency_contact': _emergencyContactController.text.trim(),
            // email is usually managed by Supabase auth directly, so changing the user's email requires an auth update
            // However, updating the profile email is possible here
            if (_emailController.text.isNotEmpty) 'email': _emailController.text.trim().toLowerCase(),
          };

          if (data.isNotEmpty) {
            await SupabaseService().updateProfileDetails(data);
          }
          if (mounted) {
            ToknSnackBar.show(context, message: 'Profile updated successfully!', type: SnackBarType.success);
            Navigator.pop(context);
          }
        } catch (e) {
             if (mounted) ToknSnackBar.show(context, message: e.toString());
        } finally {
             if (mounted) setState(() => _isLoading = false);
        }
      },

      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF2E4C9D),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E4C9D).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: _isLoading 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : Text(
                  text,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }
}

