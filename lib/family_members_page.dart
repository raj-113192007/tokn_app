// ignore_for_file: avoid_print, unused_local_variable, unused_element, use_build_context_synchronously, unused_field, file_names, constant_identifier_names, deprecated_member_use, unused_import
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tokn/l10n/app_localizations.dart';
import 'widgets/animation_utils.dart';
import 'add_member_page.dart';
import 'edit_member_page.dart';
import 'services/supabase_service.dart';
import 'widgets/tokn_snackbar.dart';

class FamilyMembersPage extends StatefulWidget {
  const FamilyMembersPage({super.key});

  @override
  State<FamilyMembersPage> createState() => _FamilyMembersPageState();
}

class _FamilyMembersPageState extends State<FamilyMembersPage> {
  List<Map<String, dynamic>> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    setState(() => _isLoading = true);
    final members = await SupabaseService().getFamilyMembers();
    if (mounted) {
      setState(() {
        _members = members;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteMember(String id) async {
    final success = await SupabaseService().deleteFamilyMember(id);
    if (success && mounted) {
      setState(() {
        _members.removeWhere((m) => m['id'] == id);
      });
      ToknSnackBar.show(context, message: 'Member deleted', type: SnackBarType.success);
    }
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
          l10n.familyMembersTitle,
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
              l10n.careCircle,
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.careCircleDesc,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            
            _isLoading 
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              : _members.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                         Icon(Icons.family_restroom_outlined, size: 64, color: Colors.grey[300]),
                         const SizedBox(height: 16),
                         Text(
                           'No family members added yet.',
                           style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 16),
                         ),
                      ],
                    ),
                  )
                : Column(
                    children: _members.map((member) {
                      final name = member['full_name'] ?? 'Unknown';
                      final relationship = member['relationship'] ?? 'Member';
                      final hasAccess = member['booking_access'] == true;
                      final id = member['id'];
                      return _buildMemberCard(
                        context,
                        id: id,
                        name: '$name${member['age'] != null ? ' (${member['age']} Yrs)' : ''}',
                        relationship: relationship,
                        accessType: hasAccess ? 'Can book appointments' : 'No booking access',
                        icon: Icons.person_outlined,
                        iconBgColor: const Color(0xFFE3F2FD),
                        iconColor: const Color(0xFF1976D2),
                        isAccessPositive: hasAccess,
                      );
                    }).toList(),
                  ),
            
            _buildAddButton(context, l10n.addFamilyMember),
            
            const SizedBox(height: 48),
            _buildPrivacySection(
              title: l10n.privacyAndConsent,
              desc: l10n.privacyDesc,
              linkText: l10n.viewDataPolicy,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberCard(
    BuildContext context, {
    required String id,
    required String name,
    required String relationship,
    required String accessType,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required bool isAccessPositive,
  }) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      relationship.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isAccessPositive ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isAccessPositive ? Icons.check_circle : Icons.info_outline,
                    size: 14,
                    color: isAccessPositive ? const Color(0xFF2E7D32) : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    accessType,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isAccessPositive ? const Color(0xFF2E7D32) : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ScaleOnTap(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditMemberPage(
                          name: name,
                          relationship: relationship,
                          bookingAccess: isAccessPositive,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F6FE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        l10n.edit,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF2E4C9D),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),
              ScaleOnTap(
                onTap: () => _deleteMember(id),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete_outline, color: Color(0xFFD32F2F), size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, String text) {
    bool isLimitReached = _members.length >= 5;

    return ScaleOnTap(
      onTap: () async {
        if (isLimitReached) {
          ToknSnackBar.show(
            context, 
            message: 'You can only add up to 5 family members.',
            type: SnackBarType.error,
          );
          return;
        }
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddMemberPage()),
        );
        if (result == true) {
          _fetchMembers();
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isLimitReached 
              ? Colors.grey[100] 
              : const Color(0xFFF2F6FE).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isLimitReached 
                ? Colors.grey[300]! 
                : const Color(0xFF2E4C9D).withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isLimitReached ? Colors.grey[400] : const Color(0xFF2E4C9D),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isLimitReached ? Icons.block : Icons.person_add_alt_1, 
                color: Colors.white, 
                size: 20
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isLimitReached ? 'Limit Reached (5/5)' : text,
              style: GoogleFonts.poppins(
                color: isLimitReached ? Colors.grey[600] : const Color(0xFF2E4C9D),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            if (isLimitReached)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Remove a member to add a new one',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[400],
                    fontSize: 11,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySection({
    required String title,
    required String desc,
    required String linkText,
  }) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.shield_outlined, color: Color(0xFF389B66), size: 32),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          desc,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.grey[600],
            height: 1.6,
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {},
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                linkText,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF2E4C9D),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward, color: Color(0xFF2E4C9D), size: 16),
            ],
          ),
        ),
      ],
    );
  }
}
