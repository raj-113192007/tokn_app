// ignore_for_file: avoid_print, unused_local_variable, unused_element, use_build_context_synchronously, unused_field, file_names, constant_identifier_names, deprecated_member_use, unused_import
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/animation_utils.dart';
import 'package:tokn/l10n/app_localizations.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'services/scroll_notifier.dart';
import 'services/api_service.dart';
import 'individual_chat_page.dart';
import 'widgets/tokn_snackbar.dart';



class MessagesPage extends StatefulWidget {
  final ScrollNotifier? scrollNotifier;

  const MessagesPage({super.key, this.scrollNotifier});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final ScrollController _messagesScrollController;
  List<Map<String, dynamic>> _visibleChats = [];
  final List<Map<String, dynamic>> _archivedChats = [];
  bool _showingArchived = false;
  bool _isFetchingBookings = false;
  List<dynamic> _userBookings = [];


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _messagesScrollController = ScrollController();
    _visibleChats = List.from(_chats);
    // Register scroll controller so the bottom bar can hide/show on this tab.
    widget.scrollNotifier?.registerPageController('messages', _messagesScrollController);
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() => _isFetchingBookings = true);
    final result = await ApiService.getBookings();
    if (mounted && result['success'] == true) {
      setState(() {
        _userBookings = result['data'];
        _isFetchingBookings = false;
      });
    } else if (mounted) {
      setState(() => _isFetchingBookings = false);
    }
  }

  void _showNewChatBottomSheet() {
    // Filter bookings for unique hospitals
    final Map<String, dynamic> uniqueHospitals = {};
    for (var b in _userBookings) {
      final h = b['hospital'];
      if (h != null && h['name'] != null) {
        uniqueHospitals[h['name']] = h;
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.selectHospitalChat,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E40AF),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.chatBookingRequirement,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            if (_isFetchingBookings)
              const Center(child: CircularProgressIndicator())
            else if (uniqueHospitals.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Column(
                    children: [
                      Icon(Icons.event_busy, size: 48, color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      Text(
                        AppLocalizations.of(context)!.noBookingsFound,
                        style: GoogleFonts.poppins(color: Colors.grey, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: uniqueHospitals.length,
                  itemBuilder: (context, index) {
                    final hName = uniqueHospitals.keys.elementAt(index);
                    final hData = uniqueHospitals[hName];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFF2F6FE),
                        backgroundImage: hData['image'] != null ? NetworkImage(hData['image']) : null,
                        child: hData['image'] == null ? const Icon(Icons.business, color: Color(0xFF2E4C9D)) : null,
                      ),
                      title: Text(
                        hName,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Text(
                        AppLocalizations.of(context)!.verifiedHospital,
                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => IndividualChatPage(
                              contactName: hName,
                              contactImage: hData['image'] ?? '',
                              isOnline: true,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }


  @override
  void dispose() {
    _tabController.dispose();
    widget.scrollNotifier?.unregisterPageController('messages');
    _messagesScrollController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _chats = [
    {
      'name': 'TokN Platform Support',
      'message': 'Reach out to Admin for help',
      'time': 'Live',
      'unread': 0,
      'isOnline': true,
      'imageUrl': 'https://ui-avatars.com/api/?name=Admin&background=1E3A8A&color=fff',
      'isReception': true,
      'isAdmin': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,

        title: Text(
          _showingArchived ? AppLocalizations.of(context)!.archivedChats : AppLocalizations.of(context)!.messages,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: _showingArchived 
          ? ScaleOnTap(
              onTap: () => setState(() => _showingArchived = false),
              child: const Icon(Icons.arrow_back, color: Color(0xFF2E4C9D)),
            )
          : null,
        actions: [
          if (!_showingArchived)
            ScaleOnTap(
              onTap: _showNewChatBottomSheet,
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
          if (!_showingArchived)
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
                            hintText: AppLocalizations.of(context)!.searchChats,
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
              child: (_showingArchived ? _archivedChats : _visibleChats).isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _showingArchived ? Icons.archive_outlined : Icons.chat_bubble_outline, 
                            size: 64, color: Colors.grey[200]
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _showingArchived ? AppLocalizations.of(context)!.noArchivedChats : AppLocalizations.of(context)!.noConversations,
                            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
                          ),
                          if (_showingArchived)
                            TextButton(
                              onPressed: () => setState(() => _showingArchived = false),
                              child: Text(AppLocalizations.of(context)!.goBack, style: GoogleFonts.poppins(color: const Color(0xFF2E4C9D))),
                            ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _messagesScrollController,
                      padding: const EdgeInsets.only(top: 10),
                      itemCount: (_showingArchived ? _archivedChats : _visibleChats).length + (!_showingArchived && _archivedChats.isNotEmpty ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (!_showingArchived && _archivedChats.isNotEmpty && index == 0) {
                          return _buildArchivedBanner();
                        }
                        
                        final chatIndex = (!_showingArchived && _archivedChats.isNotEmpty) ? index - 1 : index;
                        final chats = _showingArchived ? _archivedChats : _visibleChats;
                        final chat = chats[chatIndex];
                        
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 500),
                          child: FadeInAnimation(
                            child: SlideAnimation(
                              verticalOffset: 20,
                              child: Dismissible(
                                key: Key(chat['name']),
                                background: Container(
                                  color: Colors.blue,
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Icon(
                                    _showingArchived ? Icons.unarchive_outlined : Icons.archive_outlined, 
                                    color: Colors.white
                                  ),
                                ),
                                secondaryBackground: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(Icons.delete_outline, color: Colors.white),
                                ),
                                onDismissed: (direction) {
                                  setState(() {
                                    if (direction == DismissDirection.startToEnd) {
                                      // Archive/Unarchive
                                      if (_showingArchived) {
                                        _archivedChats.removeAt(chatIndex);
                                        _visibleChats.insert(0, chat);
                                      } else {
                                        _visibleChats.removeAt(chatIndex);
                                        _archivedChats.insert(0, chat);
                                      }
                                    } else {
                                      // Delete
                                      chats.removeAt(chatIndex);
                                    }
                                  });
                                  
                                  ToknSnackBar.show(
                                    context, 
                                    message: direction == DismissDirection.endToStart
                                        ? 'Conversation deleted'
                                        : (_showingArchived ? 'Conversation unarchived' : 'Conversation archived'),
                                    actionLabel: 'UNDO',
                                    onAction: () {
                                      setState(() {
                                        if (direction == DismissDirection.startToEnd) {
                                          if (_showingArchived) {
                                            _visibleChats.removeAt(0);
                                            _archivedChats.insert(chatIndex, chat);
                                          } else {
                                            _archivedChats.removeAt(0);
                                            _visibleChats.insert(chatIndex, chat);
                                          }
                                        } else {
                                          chats.insert(chatIndex, chat);
                                        }
                                      });
                                    },
                                  );
                                },
                                child: _buildChatItem(chat),
                              ),
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

  Widget _buildArchivedBanner() {
    return ScaleOnTap(
      onTap: () => setState(() => _showingArchived = true),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade100, width: 1)),
        ),
        child: Row(
          children: [
            const Icon(Icons.archive_outlined, color: Color(0xFF2E4C9D), size: 24),
            const SizedBox(width: 15),
            Text(
              AppLocalizations.of(context)!.archived,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            Text(
              _archivedChats.length.toString(),
              style: GoogleFonts.poppins(
                color: const Color(0xFF2E4C9D),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 5),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildChatItem(Map<String, dynamic> chat) {
    return ScaleOnTap(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IndividualChatPage(
              contactName: chat['name'],
              contactImage: chat['imageUrl'],
              isOnline: chat['unread'] > 0 || chat['isOnline'] == true,
              isAdminChat: chat['isAdmin'] == true,
            ),
          ),
        );
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
