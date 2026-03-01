import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/animation_utils.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _chats = [
    {
      'name': 'Dr. Sarah Jenkins',
      'message': 'The test results are ready for your re...',
      'time': '10:24 AM',
      'unread': 2,
      'isOnline': true,
      'imageUrl': 'https://images.unsplash.com/photo-1559839734-2b71ef197ec2?w=200',
    },
    {
      'name': 'Dr. Michael Chen',
      'message': 'Your follow-up appointment is confirmed ...',
      'time': 'Yesterday',
      'unread': 0,
      'isOnline': false,
      'imageUrl': 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=200',
    },
    {
      'name': 'St. Mary\'s Reception',
      'message': 'We have received your insurance docum...',
      'time': 'Oct 24',
      'unread': 0,
      'isOnline': false,
      'isReception': true,
      'imageUrl': '', // Will use an icon
    },
    {
      'name': 'Dr. Emily Watson',
      'message': 'Please remember to fast for 8 hours befor...',
      'time': 'Oct 22',
      'unread': 0,
      'isOnline': true,
      'imageUrl': 'https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=200',
    },
    {
      'name': 'Dr. Robert Wilson',
      'message': 'I\'ve reviewed your pharmacy request. It\'s...',
      'time': 'Oct 20',
      'unread': 0,
      'isOnline': false,
      'imageUrl': 'https://images.unsplash.com/photo-1537368910025-700350fe46c7?w=200',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: ScaleOnTap(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Text(
          'Messages',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          ScaleOnTap(
            onTap: () {},
            child: const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Icon(Icons.edit_note_rounded, color: Color(0xFF2E4C9D), size: 28),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: GlassBox(
              borderRadius: 25,
              opacity: 0.05,
              color: Colors.grey,
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.blueGrey),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search hospital chats',
                          hintStyle: GoogleFonts.poppins(color: Colors.blueGrey, fontSize: 14),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const Divider(height: 1, thickness: 0.5),

          // Chat List - Filtered to only show Reception/Hospital chats
          Expanded(
            child: AnimationLimiter(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 10),
                itemCount: _chats.where((chat) => chat['isReception'] == true).length,
                itemBuilder: (context, index) {
                  final filteredChats = _chats.where((chat) => chat['isReception'] == true).toList();
                  final chat = filteredChats[index];
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 500),
                    child: FadeInAnimation(
                      child: SlideAnimation(
                        verticalOffset: 20,
                        child: _buildChatItem(chat),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(Map<String, dynamic> chat) {
    return ScaleOnTap(
      onTap: () {
        // Navigate to actual chat screen
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade100, width: 1)),
        ),
        child: Row(
          children: [
            // Profile Image
            Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: chat['isReception'] == true ? const Color(0xFFE8F1FF) : Colors.grey[200],
                    image: chat['imageUrl'] != ''
                        ? DecorationImage(
                            image: NetworkImage(chat['imageUrl']),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: chat['imageUrl'] == ''
                      ? const Icon(Icons.add_box, color: Color(0xFF2E4C9D), size: 30)
                      : null,
                ),
                if (chat['isOnline'] == true)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 15),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        chat['name'],
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        chat['time'],
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat['message'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (chat['unread'] > 0)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2E4C9D),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            chat['unread'].toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
