// ignore_for_file: avoid_print, unused_local_variable, unused_element, use_build_context_synchronously, unused_field, file_names, constant_identifier_names, deprecated_member_use, unused_import
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/supabase_service.dart';
import 'widgets/animation_utils.dart';
import 'package:intl/intl.dart';

class MyTicketsPage extends StatefulWidget {
  const MyTicketsPage({super.key});

  @override
  State<MyTicketsPage> createState() => _MyTicketsPageState();
}

class _MyTicketsPageState extends State<MyTicketsPage> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _tickets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  Future<void> _fetchTickets() async {
    setState(() => _isLoading = true);
    try {
      final tickets = await _supabaseService.getSupportTickets();
      setState(() {
        _tickets = tickets;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

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
          'My Tickets',
          style: GoogleFonts.poppins(
            color: const Color(0xFF2E4C9D),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchTickets,
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _tickets.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _tickets.length,
                itemBuilder: (context, index) {
                  return FadeSlideTransition(
                    delay: Duration(milliseconds: 100 * index),
                    child: _buildTicketCard(_tickets[index]),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.confirmation_number_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            'No tickets raised yet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Raised issues will appear here.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> ticket) {
    final date = DateTime.parse(ticket['created_at']).toLocal();
    final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(date);
    final status = ticket['status'] ?? 'open';
    final attachmentUrl = ticket['attachment_url'];

    Color statusColor;
    switch (status.toLowerCase()) {
      case 'open': statusColor = Colors.orange; break;
      case 'in progress': statusColor = Colors.blue; break;
      case 'resolved': statusColor = Colors.green; break;
      case 'closed': statusColor = Colors.grey; break;
      default: statusColor = Colors.black54;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showTicketDetails(ticket),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                    Text(
                      formattedDate,
                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  ticket['subject'] ?? 'No Subject',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Category: ${ticket['category']}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF2E4C9D),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  ticket['message'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                if (attachmentUrl != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.attach_file, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '1 Attachment',
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTicketDetails(Map<String, dynamic> ticket) {
    final status = ticket['status'] ?? 'open';
    final attachmentUrl = ticket['attachment_url'];
    final TextEditingController replyController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85, // Increased height for chat
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        ticket['subject'] ?? '',
                        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow('Status', status.toUpperCase()),
                              _buildDetailRow('Category', ticket['category'] ?? ''),
                              _buildDetailRow('Sent on', DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(ticket['created_at']).toLocal())),
                              const SizedBox(height: 16),
                              
                              // Original Message Header
                              Text('Problem Description', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey[600])),
                              const SizedBox(height: 8),
                              _buildMessageBubble(
                                message: ticket['message'] ?? '',
                                time: ticket['created_at'],
                                isAdmin: false,
                                isFirst: true,
                                attachmentUrl: attachmentUrl,
                              ),
                              
                              // Chat History
                              FutureBuilder<List<Map<String, dynamic>>>(
                                future: _supabaseService.getTicketMessages(ticket['id']),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
                                  }
                                  final messages = snapshot.data ?? [];
                                  return Column(
                                    children: messages.map((m) => _buildMessageBubble(
                                      message: m['message'],
                                      time: m['created_at'],
                                      isAdmin: m['is_admin'],
                                    )).toList(),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Reply Input
                      if (status.toLowerCase() != 'closed')
                        Container(
                          padding: const EdgeInsets.only(top: 15),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: replyController,
                                  style: GoogleFonts.poppins(fontSize: 14),
                                  decoration: InputDecoration(
                                    hintText: 'Type a message...',
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ScaleOnTap(
                                onTap: () async {
                                  if (replyController.text.trim().isEmpty) return;
                                  await _supabaseService.sendTicketReply(ticket['id'], replyController.text.trim());
                                  replyController.clear();
                                  setModalState(() {}); // Refresh chat inside modal
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(color: Color(0xFF2E4C9D), shape: BoxShape.circle),
                                  child: const Icon(Icons.send, color: Colors.white, size: 20),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble({
    required String message,
    required String time,
    required bool isAdmin,
    bool isFirst = false,
    String? attachmentUrl,
  }) {
    final date = DateTime.parse(time).toLocal();
    final formattedTime = DateFormat('hh:mm a').format(date);

    return Align(
      alignment: isAdmin ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isAdmin ? Colors.grey[100] : const Color(0xFF2E4C9D).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomLeft: isAdmin ? Radius.zero : const Radius.circular(20),
            bottomRight: !isAdmin ? Radius.zero : const Radius.circular(20),
          ),
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isFirst)
              Text('Initial Request', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))
            else if (isAdmin)
              Text('Support Agent', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF2E4C9D))),
            const SizedBox(height: 4),
            Text(message, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87)),
            if (attachmentUrl != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(attachmentUrl, fit: BoxFit.cover, width: double.infinity),
              ),
            ],
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(formattedTime, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '$label: ', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.grey[600], fontSize: 12)),
            TextSpan(text: value, style: GoogleFonts.poppins(color: const Color(0xFF2E4C9D), fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
