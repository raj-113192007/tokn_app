import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/animation_utils.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: ScaleOnTap(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.black),
        ),
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
    final upcomingBookings = [
      {
        'hospital': 'City General Hospital',
        'dept': 'Cardiology Department',
        'token': 'R34',
        'doctor': 'Dr. Sarah Jenkins',
        'patient': 'John Doe',
        'time': 'Oct 28, 10:00 AM - 11:00 AM',
      },
      {
        'hospital': 'St. Mary\'s Specialty Clinic',
        'dept': 'Pediatrics',
        'token': 'A56',
        'doctor': 'Dr. Robert Chen',
        'patient': 'Emily Smith',
        'time': 'Nov 02, 02:15 PM - 03:45 PM',
      },
      {
        'hospital': 'Wellness Care Center',
        'dept': 'Dermatology',
        'token': 'B12',
        'doctor': 'Dr. Alice Wong',
        'patient': 'John Doe',
        'time': 'Nov 05, 05:00 AM - 05:30 AM',
      },
    ];

    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: upcomingBookings.length + 1,
        itemBuilder: (context, index) {
          if (index == upcomingBookings.length) {
            return _buildNotificationBox();
          }
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 500),
            child: FadeInAnimation(
              child: SlideAnimation(
                verticalOffset: 20,
                child: _buildUpcomingCard(upcomingBookings[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUpcomingCard(Map<String, String> booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add_business_outlined, color: Color(0xFF2E4C9D)),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking['hospital']!,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      booking['dept']!,
                      style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F1FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Token ${booking['token']}',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF3B9966),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(Icons.medical_services_outlined, booking['doctor']!),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.person_outline, 'Patient: ${booking['patient']}'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.access_time, booking['time']!),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ScaleOnTap(
                  onTap: () {},
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E4C9D),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.explore_outlined, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Directions',
                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.more_vert, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedList() {
    final completedBookings = [
      {
        'hospital': 'City General Hospital',
        'doctor': 'Dr. Sarah Mitchell',
        'patient': 'John Doe',
        'date': 'Oct 24, 2023, 10:00 AM',
        'token': 'R31',
        'image': 'https://images.unsplash.com/photo-1587350859728-117622bc75fb?w=800',
      },
      {
        'hospital': 'St. Mary\'s Specialty Clinic',
        'doctor': 'Dr. Robert Chen',
        'patient': 'John Doe',
        'date': 'Oct 15, 2023, 03:15 PM',
        'token': 'A11',
        'image': 'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?w=800',
      },
    ];

    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: completedBookings.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 500),
            child: FadeInAnimation(
              child: SlideAnimation(
                verticalOffset: 20,
                child: _buildHistoryCard(completedBookings[index], 'COMPLETED', Colors.green),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCancelledList() {
    final cancelledBookings = [
      {
        'hospital': 'Downtown Wellness Center',
        'doctor': 'Dr. Emily Wong',
        'patient': 'John Doe',
        'date': 'Sept 30, 2023, 09:30 AM',
        'token': 'C22',
        'image': 'https://images.unsplash.com/photo-1538108197017-c10d7373950f?w=800',
      },
    ];

    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: cancelledBookings.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 500),
            child: FadeInAnimation(
              child: SlideAnimation(
                verticalOffset: 20,
                child: _buildHistoryCard(cancelledBookings[index], 'CANCELLED', Colors.redAccent),
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
