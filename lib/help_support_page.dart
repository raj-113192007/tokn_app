import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tokn/widgets/animation_utils.dart';
import 'support_form_page.dart';
import 'my_tickets_page.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: ScaleOnTap(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, color: Color(0xFF2E4C9D)),
        ),
        title: Text(
          'Help & Support',
          style: GoogleFonts.poppins(
            color: const Color(0xFF2E4C9D),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroBanner(),
            _buildSupportActions(context),
            _buildKnowledgeBase(),
            _buildFAQSection(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: _buildActionCard(
              context: context,
              title: 'Raise a Ticket',
              subtitle: 'Send us a message',
              icon: Icons.add_comment_rounded,
              color: const Color(0xFF2E4C9D),
              onTap: () => Navigator.push(context, SmoothPageRoute(page: const SupportFormPage())),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _buildActionCard(
              context: context,
              title: 'My Tickets',
              subtitle: 'Track your issues',
              icon: Icons.history_rounded,
              color: Colors.orange.shade700,
              onTap: () => Navigator.push(context, SmoothPageRoute(page: const MyTicketsPage())),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ScaleOnTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2E4C9D).withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.support_agent_rounded, color: Color(0xFF2E4C9D), size: 50),
          ),
          const SizedBox(height: 20),
          Text(
            'How can we help you?',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(15),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for help...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.search, color: Color(0xFF2E4C9D), size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKnowledgeBase() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 4, height: 18, color: const Color(0xFF2E4C9D)),
              const SizedBox(width: 8),
              Text(
                'Knowledge Base',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
              ),
            ],
          ),
          const SizedBox(height: 15),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.2,
            children: [
              _buildCategoryCard('Booking Help', Icons.calendar_today, Colors.blue),
              _buildCategoryCard('Payments', Icons.payment, Colors.orange),
              _buildCategoryCard('Account', Icons.person, Colors.green),
              _buildCategoryCard('Privacy', Icons.security, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String title, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 4, height: 18, color: const Color(0xFF2E4C9D)),
              const SizedBox(width: 8),
              Text(
                'Common Questions',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildFAQTile('How do I book a token?', 'Select a hospital, choose a doctor, and pick a time slot.'),
          _buildFAQTile('Can I cancel my appointment?', 'Yes, go to My Bookings and select the cancel option.'),
          _buildFAQTile('Is my payment secure?', 'We use industry-standard encryption for all transactions.'),
        ],
      ),
    );
  }

  Widget _buildFAQTile(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20),
        title: Text(
          question,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
        ),
        iconColor: const Color(0xFF2E4C9D),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Text(answer, style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13, height: 1.5)),
          ),
        ],
      ),
    );
  }
}
