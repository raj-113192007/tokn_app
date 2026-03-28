import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/animation_utils.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:home_widget/home_widget.dart';
import 'services/api_service.dart';
import 'services/scroll_notifier.dart';
import 'widgets/booking_card.dart';


class MyBookingsPage extends StatefulWidget {
  final ScrollNotifier? scrollNotifier;

  const MyBookingsPage({super.key, this.scrollNotifier});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _allBookings = [];
  bool _isLoading = true;
  late final ScrollController _upcomingScrollController;
  late final ScrollController _completedScrollController;
  late final ScrollController _cancelledScrollController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _upcomingScrollController = ScrollController();
    _completedScrollController = ScrollController();
    _cancelledScrollController = ScrollController();

    // Register scroll controllers so the bottom bar can hide/show.
    // Each booking sub-tab gets its own page id, and we update the notifier's
    // current page when the TabBar index changes.
    widget.scrollNotifier?.registerPageController('bookings_upcoming', _upcomingScrollController);
    widget.scrollNotifier?.registerPageController('bookings_completed', _completedScrollController);
    widget.scrollNotifier?.registerPageController('bookings_cancelled', _cancelledScrollController);

    // Ensure bar starts visible when entering this page.
    widget.scrollNotifier?.reset();
    widget.scrollNotifier?.setCurrentPage('bookings_upcoming');

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;

      widget.scrollNotifier?.reset();
      switch (_tabController.index) {
        case 0:
          widget.scrollNotifier?.setCurrentPage('bookings_upcoming');
          break;
        case 1:
          widget.scrollNotifier?.setCurrentPage('bookings_completed');
          break;
        case 2:
          widget.scrollNotifier?.setCurrentPage('bookings_cancelled');
          break;
      }
    });
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() => _isLoading = true);
    final result = await ApiService.getBookings();
    if (mounted) {
      setState(() {
        if (result['success'] == true) {
          _allBookings = result['data'];
          _updateHomeWidget(_allBookings);
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _updateHomeWidget(List<dynamic> bookings) async {
    try {
      final upcomingBookings = bookings.where((b) => 
        b['status'] == 'Pending' || b['status'] == 'Confirmed'
      ).toList();

      if (upcomingBookings.isNotEmpty) {
        final b = upcomingBookings.first;
        await HomeWidget.saveWidgetData<String>('hospital', b['hospital']?['name'] ?? 'Hospital');
        await HomeWidget.saveWidgetData<String>('serving', '42'); // Mocked serving number
        await HomeWidget.saveWidgetData<String>('mine', b['token_number'] ?? 'N/A');
        await HomeWidget.saveWidgetData<String>('wait_time', '15');
      } else {
        await HomeWidget.saveWidgetData<String>('hospital', 'No Appointment');
        await HomeWidget.saveWidgetData<String>('serving', '-');
        await HomeWidget.saveWidgetData<String>('mine', '-');
        await HomeWidget.saveWidgetData<String>('wait_time', '0');
      }
      await HomeWidget.updateWidget(
        name: 'TokenWidgetProvider',
        androidName: 'TokenWidgetProvider',
      );

    } catch (e) {
      debugPrint('Error updating Home Widget: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    widget.scrollNotifier?.unregisterPageController('bookings_upcoming');
    widget.scrollNotifier?.unregisterPageController('bookings_completed');
    widget.scrollNotifier?.unregisterPageController('bookings_cancelled');
    _upcomingScrollController.dispose();
    _completedScrollController.dispose();
    _cancelledScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,

        title: Text(
          'My Bookings',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2E4C9D),
          unselectedLabelColor: Colors.grey,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
          indicatorColor: const Color(0xFF2E4C9D),
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUpcomingList(),
          _buildCompletedList(),
          _buildCancelledList(),
        ],
      ),
    );
  }

  Widget _buildUpcomingList() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    
    final upcomingBookings = _allBookings.where((b) => 
      b['status'] == 'Pending' || b['status'] == 'Confirmed'
    ).toList();

    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        controller: _upcomingScrollController,
        itemCount: upcomingBookings.length + 1,
        itemBuilder: (context, index) {
          if (index == upcomingBookings.length) {
            return _buildNotificationBox();
          }
          final b = upcomingBookings[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 500),
            child: FadeInAnimation(
              child: SlideAnimation(
                verticalOffset: 20,
                child: BookingCard(
                  hospitalName: b['hospital']?['name'] ?? 'Hospital',
                  department: b['hospital']?['categories']?.join(', ') ?? 'General',
                  tokenNumber: b['token_number'] ?? 'N/A',
                  doctorName: 'On Duty Doctor',
                  patientName: 'You',
                  date: b['booking_date'].split('T')[0],
                  time: b['booking_time'] ?? 'N/A',
                  status: b['status'] ?? 'Upcoming',
                  actionText: 'Directions',
                ),
              ),
            ),
          );

        },
      ),
    );
  }

  Widget _buildCompletedList() {

    if (_isLoading) return const Center(child: CircularProgressIndicator());
    final completedBookings = _allBookings.where((b) => b['status'] == 'Completed').toList();

    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        controller: _completedScrollController,
        itemCount: completedBookings.length,
        itemBuilder: (context, index) {
          final b = completedBookings[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 500),
            child: FadeInAnimation(
              child: SlideAnimation(
                verticalOffset: 20,
                child: _buildHistoryCard({
                  'hospital': b['hospital']?['name'] ?? 'Hospital',
                  'doctor': 'On Duty Doctor',
                  'patient': 'You',
                  'date': b['booking_date'].split('T')[0],
                  'token': b['token_number'] ?? 'N/A',
                  'image': b['hospital']?['image'] ?? 'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?w=800',
                }, 'COMPLETED', Colors.green),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCancelledList() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    final cancelledBookings = _allBookings.where((b) => b['status'] == 'Cancelled').toList();

    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        controller: _cancelledScrollController,
        itemCount: cancelledBookings.length,
        itemBuilder: (context, index) {
          final b = cancelledBookings[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 500),
            child: FadeInAnimation(
              child: SlideAnimation(
                verticalOffset: 20,
                child: _buildHistoryCard({
                  'hospital': b['hospital']?['name'] ?? 'Hospital',
                  'doctor': 'On Duty Doctor',
                  'patient': 'You',
                  'date': b['booking_date'].split('T')[0],
                  'token': b['token_number'] ?? 'N/A',
                  'image': b['hospital']?['image'] ?? 'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?w=800',
                }, 'CANCELLED', Colors.redAccent),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, String> booking, String status, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(
              booking['image']!,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      status,
                      style: GoogleFonts.poppins(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• Token ${booking['token']}',
                      style: GoogleFonts.poppins(color: Colors.grey, fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  booking['hospital']!,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),
                _buildInfoRow(Icons.person_outline, '${booking['doctor']} • Patient: ${booking['patient']}'),
                const SizedBox(height: 5),
                _buildInfoRow(Icons.calendar_today_outlined, booking['date']!),
                const SizedBox(height: 15),
                Align(
                  alignment: Alignment.centerRight,
                  child: ScaleOnTap(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E4C9D),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.refresh, color: Colors.white, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            status == 'COMPLETED' ? 'Rebook' : 'Retry',
                            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationBox() {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7EC),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFFFE0B2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active_outlined, color: Colors.orange),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stay on time!',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  'Enable push notifications to get alarms for your turn.',
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
