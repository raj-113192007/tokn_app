import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tokn/l10n/app_localizations.dart';
import 'widgets/animation_utils.dart';
import 'add_member_page.dart';
import 'edit_member_page.dart';


class FamilyMembersPage extends StatelessWidget {
  const FamilyMembersPage({super.key});

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
            
            _buildMemberCard(
              context,
              name: 'Elena Rodriguez',
              relationship: 'Mother',
              accessType: l10n.bookingAccess,
              icon: Icons.person,
              iconBgColor: const Color(0xFFE3F2FD),
              iconColor: const Color(0xFF2196F3),
              isAccessPositive: true,
            ),

            
            _buildMemberCard(
              context,
              name: 'Marco Rodriguez',
              relationship: 'Spouse',
              accessType: l10n.bookingAccess,
              icon: Icons.person,
              iconBgColor: const Color(0xFFE8F5E9),
              iconColor: const Color(0xFF4CAF50),
              isAccessPositive: true,
            ),

            
            _buildMemberCard(
              context,
              name: 'Leo Rodriguez',
              relationship: 'Child',
              accessType: l10n.limitedAccess,
              icon: Icons.child_care,
              iconBgColor: const Color(0xFFFFF3E0),
              iconColor: const Color(0xFFFF9800),
              isAccessPositive: false,
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
            color: Colors.black.withOpacity(0.02),
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
                onTap: () {},
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
    return ScaleOnTap(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddMemberPage()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F6FE).withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF2E4C9D).withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF2E4C9D),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_add_alt_1, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              text,
              style: GoogleFonts.poppins(
                color: const Color(0xFF2E4C9D),
                fontWeight: FontWeight.w600,
                fontSize: 14,
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
                color: Colors.black.withOpacity(0.04),
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
