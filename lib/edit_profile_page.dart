// ignore_for_file: avoid_print, unused_local_variable, unused_element, use_build_context_synchronously, unused_field, file_names, constant_identifier_names, deprecated_member_use, unused_import
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tokn/l10n/app_localizations.dart';
import 'widgets/animation_utils.dart';
import 'widgets/tokn_snackbar.dart';
import 'services/supabase_service.dart';
import 'package:image_picker/image_picker.dart';


class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emergencyContactController = TextEditingController();
  
  bool _isLoading = false;
  bool _isInitLoading = true;
  String? _avatarUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      final profile = await SupabaseService().getProfile();
      if (profile != null) {
        setState(() {
          _nameController.text = profile['full_name'] ?? '';
          _emailController.text = profile['email'] ?? '';
          _phoneController.text = (profile['phone'] ?? '').replaceAll('+91', '');
          _emergencyContactController.text = profile['emergency_contact'] ?? '';
          _avatarUrl = profile['avatar_url'];
          _isInitLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ToknSnackBar.show(context, message: 'Failed to load profile');
        setState(() => _isInitLoading = false);
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image != null) {
        setState(() => _isLoading = true);
        final url = await SupabaseService().uploadProfilePhoto(image.path);
        if (url != null) {
          setState(() {
            _avatarUrl = url;
            _isLoading = false;
          });
          if (mounted) {
            ToknSnackBar.show(context, message: 'Photo updated successfully', type: SnackBarType.success);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ToknSnackBar.show(context, message: 'Failed to upload photo');
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF2E4C9D))),
      );
    }

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
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
              image: DecorationImage(
                image: _avatarUrl != null && _avatarUrl!.isNotEmpty
                    ? NetworkImage(_avatarUrl!)
                    : const NetworkImage('https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=400'),
                fit: BoxFit.cover,
              ),
            ),
            child: _isLoading 
              ? Container(
                  decoration: const BoxDecoration(
                    color: Colors.black26,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                )
              : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: ScaleOnTap(
              onTap: _isLoading ? null : _pickAndUploadImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E4C9D),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E4C9D).withValues(alpha: 0.3),
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
            color: const Color(0xFFF7F9FC).withValues(alpha: 0.8),
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
          final phone = _phoneController.text.trim();
          String formattedPhone = phone;
          if (phone.isNotEmpty && !phone.startsWith('+')) {
            formattedPhone = '+91$phone';
          }

          final data = {
            'full_name': _nameController.text.trim(),
            'phone': formattedPhone,
            'emergency_contact': _emergencyContactController.text.trim(),
            'email': _emailController.text.trim().toLowerCase(),
            'avatar_url': _avatarUrl,
          };

          await SupabaseService().updateProfileDetails(data);
          
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
              color: const Color(0xFF2E4C9D).withValues(alpha: 0.3),
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

