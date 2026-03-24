import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E4C9D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Help & Support',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroBanner(),
            _buildKnowledgeBase(),
            _buildFAQSection(),
            _buildContactSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      decoration: const BoxDecoration(
        color: Color(0xFF2E4C9D),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Text(
            'How can we help you?',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for help...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey),
                border: InputBorder.none,
                icon: const Icon(Icons.search, color: Color(0xFF2E4C9D)),
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
          const Text(
            'Knowledge Base',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E4C9D)),
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
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
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
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
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E4C9D)),
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
    return ExpansionTile(
      title: Text(
        question,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(15),
          child: Text(answer, style: GoogleFonts.poppins(color: Colors.grey[700])),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            'Still need help?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2E4C9D)),
          ),
          const SizedBox(height: 15),
          _buildContactButton(Icons.email, 'tokn.dev@gmail.com', 'Email Support'),
          const SizedBox(height: 10),
          _buildContactButton(Icons.phone, '+91 761121632', 'Call Helpline'),
        ],
      ),
    );
  }

  Widget _buildContactButton(IconData icon, String detail, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2E4C9D)),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(detail, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}
