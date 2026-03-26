import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tokn/l10n/app_localizations.dart';
import 'widgets/animation_utils.dart';

class EditMemberPage extends StatefulWidget {
  final String name;
  final String relationship;
  final String? gender;
  final String? bloodGroup;
  final String? age;
  final String? phoneNumber;
  final bool bookingAccess;

  const EditMemberPage({
    super.key,
    required this.name,
    required this.relationship,
    this.gender,
    this.bloodGroup,
    this.age,
    this.phoneNumber,
    this.bookingAccess = true,
  });

  @override
  State<EditMemberPage> createState() => _EditMemberPageState();
}

class _EditMemberPageState extends State<EditMemberPage> {
  late String? _selectedRelationship;
  late String? _selectedGender;
  late String? _selectedBloodGroup;
  late bool _enableBookingAccess;
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _phoneController;

  final List<String> _relationships = ['Mother', 'Father', 'Spouse', 'Child', 'Sibling', 'Other'];
  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _bloodGroups = ['O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-'];

  @override
  void initState() {
    super.initState();
    _selectedRelationship = widget.relationship;
    _selectedGender = widget.gender;
    _selectedBloodGroup = widget.bloodGroup;
    _enableBookingAccess = widget.bookingAccess;
    _nameController = TextEditingController(text: widget.name);
    _ageController = TextEditingController(text: widget.age);
    _phoneController = TextEditingController(text: widget.phoneNumber);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

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
          'Edit Family Member',
          style: GoogleFonts.poppins(
            color: const Color(0xFF2E4C9D),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'UPDATE PROFILE',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2E4C9D).withOpacity(0.6),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Refine Care Circle',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A1A),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Make sure all information is accurate to ensure better care for your loved ones.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            
            _buildFieldLabel(l10n.fullName),
            _buildInputField(controller: _nameController, hint: 'e.g. Johnathan Smith'),
            
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('RELATIONSHIP'),
                      _buildDropdownField(
                        hint: l10n.select,
                        value: _selectedRelationship,
                        items: _relationships,
                        onChanged: (v) => setState(() => _selectedRelationship = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel(l10n.age),
                      _buildInputField(controller: _ageController, hint: l10n.years, keyboardType: TextInputType.number),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel(l10n.gender),
                      _buildDropdownField(
                        hint: l10n.select,
                        value: _selectedGender,
                        items: _genders,
                        onChanged: (v) => setState(() => _selectedGender = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel(l10n.bloodGroup),
                      _buildDropdownField(
                        hint: l10n.type,
                        value: _selectedBloodGroup,
                        items: _bloodGroups,
                        onChanged: (v) => setState(() => _selectedBloodGroup = v),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            _buildFieldLabel(l10n.phoneNumber),
            Row(
              children: [
                Text(
                  '+91',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInputField(controller: _phoneController, hint: '555-0123', keyboardType: TextInputType.phone),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            _buildAccessSwitch(
              l10n.enableBookingAccess,
              l10n.enableBookingAccessDesc,
            ),
            
            const SizedBox(height: 48),
            _buildSaveButton(context, 'Update & Save'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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

  Widget _buildInputField({required TextEditingController controller, required String hint, TextInputType keyboardType = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey[900]),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: Colors.grey[300], fontSize: 16, fontWeight: FontWeight.normal),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: GoogleFonts.poppins(color: Colors.grey[300], fontSize: 16)),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey[900])),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildAccessSwitch(String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Switch(
            value: _enableBookingAccess,
            onChanged: (v) => setState(() => _enableBookingAccess = v),
            activeColor: const Color(0xFF389B66),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, String text) {
    return ScaleOnTap(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF21559C),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E4C9D).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
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
