// ignore_for_file: avoid_print, unused_local_variable, unused_element, use_build_context_synchronously, unused_field, file_names, constant_identifier_names, deprecated_member_use, unused_import
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tokn/l10n/app_localizations.dart';
import 'widgets/animation_utils.dart';
import 'services/supabase_service.dart';
import 'widgets/tokn_snackbar.dart';


class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emergencyContactController = TextEditingController();
  final TextEditingController _houseNoController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  bool _isLoading = false;

  String? _selectedBloodGroup;
  final List<String> _bloodGroups = ['O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-'];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: ScaleOnTap(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Color(0xFF2E4C9D)),
        ),
        title: Text(
          l10n.completeProfile,
          style: GoogleFonts.poppins(
            color: const Color(0xFF2E4C9D),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF2E4C9D).withValues(alpha: 0.1),
              child: Text(
                'JD',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF2E4C9D),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.medicalRecords.toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2E4C9D).withValues(alpha: 0.6),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.finalizeIdentity,
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A1A),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.accurateInfoDesc,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            
            _buildFieldLabel(l10n.age),
            _buildInputField(hint: 'e.g. 28', controller: _ageController, keyboardType: TextInputType.number),
            
            _buildFieldLabel(l10n.bloodGroup),
            _buildDropdownField(
              hint: l10n.selectLanguage, // Assuming this context, or create a new 'selectGroup' 
              value: _selectedBloodGroup,
              items: _bloodGroups,
              onChanged: (v) => setState(() => _selectedBloodGroup = v),
            ),
            
            _buildFieldLabel(l10n.emergencyContact),
            _buildInputField(hint: 'e.g. 9876543210', controller: _emergencyContactController, keyboardType: TextInputType.phone),

            
            _buildFieldLabel(l10n.houseNo),
            _buildInputField(hint: 'e.g. House No. 123', controller: _houseNoController),
            
            _buildFieldLabel(l10n.district),
            _buildInputField(hint: 'e.g. Lucknow', controller: _districtController),
            
            _buildFieldLabel(l10n.pinCode),
            _buildInputField(hint: 'e.g. 226001', controller: _pinCodeController, keyboardType: TextInputType.number),
            
            _buildFieldLabel(l10n.state),
            _buildInputField(hint: 'e.g. Uttar Pradesh', controller: _stateController),
            
            _buildFieldLabel(l10n.country),
            _buildInputField(hint: 'e.g. India', controller: _countryController),
            
            const SizedBox(height: 32),
            _buildPrivacyNotice(l10n.privacyNotice),
            
            const SizedBox(height: 40),
            _buildSaveButton(context, l10n.saveProfile),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 20),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey[500],
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildInputField({required String hint, TextEditingController? controller, TextInputType keyboardType = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE9EDF2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFE9EDF2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 14)),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildPrivacyNotice(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info, color: Color(0xFFD32F2F), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFFB71C1C),
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, String text) {
    return ScaleOnTap(
      onTap: _isLoading ? null : () async {
        setState(() => _isLoading = true);
        try {
          final data = {
            if (_ageController.text.isNotEmpty) 'age': _ageController.text.trim(),
            if (_selectedBloodGroup != null) 'blood_group': _selectedBloodGroup,
            if (_emergencyContactController.text.isNotEmpty) 'emergency_contact': _emergencyContactController.text.trim(),
            if (_houseNoController.text.isNotEmpty) 'address_house_no': _houseNoController.text.trim(),
            if (_districtController.text.isNotEmpty) 'address_district': _districtController.text.trim(),
            if (_pinCodeController.text.isNotEmpty) 'address_pincode': _pinCodeController.text.trim(),
            if (_stateController.text.isNotEmpty) 'address_state': _stateController.text.trim(),
            if (_countryController.text.isNotEmpty) 'address_country': _countryController.text.trim(),
          };
          if (data.isNotEmpty) {
            await SupabaseService().updateProfileDetails(data);
          }
          if (mounted) {
            ToknSnackBar.show(context, message: 'Profile completed successfully!', type: SnackBarType.success);
            Navigator.pop(context);
          }
        } catch (e) {
          if (mounted) {
            ToknSnackBar.show(context, message: e.toString());
          }
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              else ...[
                Text(
                  text,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
