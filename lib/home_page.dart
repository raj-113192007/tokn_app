import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'hospital_details_page.dart';
import 'messages_page.dart';
import 'my_bookings_page.dart';
import 'profile_page.dart';
import 'widgets/animation_utils.dart';
import 'widgets/hideable_bottom_bar.dart';
import 'services/api_service.dart';
import 'services/scroll_notifier.dart';
import 'all_hospitals_page.dart';
import 'all_categories_page.dart';

import 'liked_hospitals_page.dart';
import 'widgets/booking_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/supabase_service.dart';
import 'widgets/tokn_snackbar.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late PageController _pageController;
  late ScrollNotifier _scrollNotifier;
  late ScrollController _homePageScrollController;
  String _userName = 'User';
  List<dynamic> _realHospitals = [];
  List<dynamic> _upcomingBookings = [];
  List<dynamic> _likedHospitalsPreview = [];
  bool _isLoadingHospitals = true;
  bool _isLoadingBookings = true;
  bool _isLoadingLiked = true;


  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _scrollNotifier = ScrollNotifier();
    _homePageScrollController = ScrollController();
    _scrollNotifier.registerPageController('home', _homePageScrollController);
    _scrollNotifier.setCurrentPage('home');
    _loadUserName();
    _fetchHospitals().then((_) => _fetchLikedHospitals());
    _fetchBookings();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkEmailVerification();
    });
  }

  Future<void> _fetchLikedHospitals() async {
    setState(() => _isLoadingLiked = true);
    final likedIds = await SupabaseService().getLikedHospitalIds();
    if (mounted) {
      setState(() {
        _likedHospitalsPreview = _realHospitals.where((h) => likedIds.contains(h['_id'])).toList();
        _isLoadingLiked = false;
      });
    }
  }


  @override
  void dispose() {
    _pageController.dispose();
    _homePageScrollController.dispose();
    _scrollNotifier.dispose();
    super.dispose();
  }

  Future<void> _fetchHospitals() async {
    setState(() => _isLoadingHospitals = true);
    final result = await ApiService.getHospitals();
    if (mounted) {
      setState(() {
        if (result['success'] == true) {
          _realHospitals = result['data'];
        }
        _isLoadingHospitals = false;
      });
    }
  }

  Future<void> _fetchBookings() async {
    setState(() => _isLoadingBookings = true);
    final result = await ApiService.getBookings();
    if (mounted) {
      setState(() {
        if (result['success'] == true) {
          _upcomingBookings = result['data'].where((b) => 
            b['status'] == 'Pending' || b['status'] == 'Confirmed'
          ).toList();
        }
        _isLoadingBookings = false;
      });
    }
  }


  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'User';
    });
  }

  String _getFirstName() {
    try {
      final parts = _userName.split(' ');
      return parts.isNotEmpty ? parts[0] : 'User';
    } catch (e) {
      return 'User';
    }
  }

  Future<void> _checkEmailVerification() async {
    final user = Supabase.instance.client.auth.currentUser;
    // Check if email is NOT confirmed
    if (user == null || user.emailConfirmedAt != null) return;

    final prefs = await SharedPreferences.getInstance();
    final lastPrompt = prefs.getInt('last_email_prompt_time') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // 2 days in milliseconds: 172,800,000
    if (now - lastPrompt > 172800000) {
      if (mounted) {
        _showEmailVerificationDialog(user.email!);
        await prefs.setInt('last_email_prompt_time', now);
      }
    }
  }

  void _showEmailVerificationDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Verify Your Email', 
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)
        ),
        content: Text(
          'Your email ($email) is not verified. Verify it to secure your account and receive queue updates.',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Later', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await SupabaseService().resendOTP(
                  email: email, 
                  type: OtpType.signup
                );
                if (mounted) {
                  Navigator.pop(context);
                  ToknSnackBar.show(context, 
                    message: 'Verification email sent! Check your inbox.', 
                    type: SnackBarType.success
                  );
                }
              } catch (e) {
                if (mounted) {
                  ToknSnackBar.show(context, 
                    message: 'Failed to send: ${e.toString().split(':').last}', 
                    type: SnackBarType.error
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E40AF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Verify Now', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  void _showNotifications() {
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notifications',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Clear all',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF1E40AF),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No new notifications',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We\'ll notify you when something important arrives.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showCityPicker() {

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select City',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.location_city),
                title: const Text('Dehradun'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.location_city),
                title: const Text('Rishikesh'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.location_city),
                title: const Text('Haridwar'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  final List<Map<String, String>> _hospitals = [
    {
      'name': 'Medanta\nThe Medicity',
      'image': 'https://images.unsplash.com/photo-1586773860418-d37222d8fce3?w=400',
    },
    {
      'name': 'Apollo Hospital\nDehradun',
      'image': 'https://images.unsplash.com/photo-1538108149393-fbbd8189718c?w=400',
    },
    {
      'name': 'Max Super\nSpeciality',
      'image': 'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?w=400',
    },
    {
      'name': 'Fortis\nHospital',
      'image': 'https://images.unsplash.com/photo-1512678080530-7760d81faba6?w=400',
    },
  ];

  final List<Map<String, String>> _categories = [
    {
      'name': 'Headache',
      'image': 'https://images.unsplash.com/photo-1584017911766-d451b3d0e843?w=200',
    },
    {
      'name': 'Skin & Derma',
      'image': 'https://images.unsplash.com/photo-1616394584738-fc6e612e71b9?w=200',
    },
    {
      'name': 'Dental',
      'image': 'https://images.unsplash.com/photo-1628177142898-93e36e4e3a50?w=200',
    },
    {
      'name': 'Surgery',
      'image': 'https://images.unsplash.com/photo-1579684385127-1ef15d508118?w=200',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomeContent(),
      MyBookingsPage(scrollNotifier: _scrollNotifier),
      MessagesPage(scrollNotifier: _scrollNotifier),
      ProfilePage(scrollNotifier: _scrollNotifier),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            if (_selectedIndex != index) {
              HapticFeedback.lightImpact();
              setState(() {
                _selectedIndex = index;
              });
              // Update the scroll notifier for the current page
              final pageIds = ['home', 'bookings', 'messages', 'profile'];
              _scrollNotifier.setCurrentPage(pageIds[index]);
              _scrollNotifier.reset();
            }
          },
          children: pages,
        ),
      ),
      bottomNavigationBar: HideableBottomBar(
        scrollNotifier: _scrollNotifier,
        height: 74,
        blur: 15,
        opacity: 0.92,
        backgroundColor: const Color(0xFF1E40AF),
        borderRadius: 40,
        margin: const EdgeInsets.fromLTRB(25, 0, 25, 20),
        child: _buildNavBarContent(),
      ),
    );
  }

  Widget _buildHomeContent() {
    return AnimationLimiter(
      child: Column(
        children: [
          // Top Section: Avatar, Greeting, and Notification Bell
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Row(
            children: [
              Image.asset(
                'assets/splash_logo.png',
                width: 32,
                height: 32,
              ),
              const SizedBox(width: 12),
              Text(
                'Hi ${_getFirstName()}',

                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              ScaleOnTap(
                onTap: _showNotifications,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: const AnimatedBell(),
                ),
              ),

            ],
          ),
        ),

        // Search & Location Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              ScaleOnTap(
                onTap: _showCityPicker,
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.location_on_outlined, color: Colors.black),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by category or name',
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.black, size: 24),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Main Content Scrollable Area
        Expanded(
          child: SingleChildScrollView(
            controller: _homePageScrollController,
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner Carousel
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ScaleOnTap(
                    onTap: () {},
                    child: Stack(
                      children: [
                        Container(
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.grey[300],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              'https://images.unsplash.com/photo-1631217868264-e5b90bb7e133?w=800',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(color: Colors.grey[300]),
                            ),
                          ),
                        ),
                        Container(
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.5),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          left: 20,
                          child: Text(
                            'Find Best Doctors\nNear You',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (!_isLoadingBookings && _upcomingBookings.isNotEmpty) ...[
                  const SizedBox(height: 25),
                  _buildSectionHeader('Upcoming Booking'),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: BookingCard(
                      hospitalName: _upcomingBookings.first['hospital']?['name'] ?? 'Hospital',
                      department: _upcomingBookings.first['hospital']?['categories']?.join(', ') ?? 'General',
                      tokenNumber: _upcomingBookings.first['token_number'] ?? 'N/A',
                      doctorName: 'On Duty Doctor',
                      patientName: 'You',
                      date: _upcomingBookings.first['booking_date'].split('T')[0],
                      time: _upcomingBookings.first['booking_time'] ?? 'N/A',
                      status: _upcomingBookings.first['status'] ?? 'Upcoming',
                      actionText: 'Directions',
                    ),
                  ),
                ],

                const SizedBox(height: 25),


                // Hospitals Section
                _buildSectionHeader(
                  'Hospitals',
                  onMoreTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllHospitalsPage(hospitals: _realHospitals),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                _isLoadingHospitals
                    ? const Center(child: CircularProgressIndicator())
                    : _realHospitals.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'No hospitals found near you.',
                              style: GoogleFonts.poppins(color: Colors.grey),
                            ),
                          )
                        : SizedBox(
                            height: 160,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: _realHospitals.length,
                              itemBuilder: (context, index) {
                                final h = _realHospitals[index];
                                return _buildHospitalCard(
                                  context,
                                  h['_id'] ?? '',
                                  h['name'] ?? 'Hospital',
                                  h['image'] ?? 'https://images.unsplash.com/photo-1586773860418-d37222d8fce3?w=400',
                                );
                              },
                            ),
                          ),



                const SizedBox(height: 25),

                // Liked Hospitals Section
                _buildSectionHeader(
                  'Liked Hospitals',
                  onMoreTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LikedHospitalsPage(),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                _isLoadingLiked
                    ? const Center(child: CircularProgressIndicator())
                    : _likedHospitalsPreview.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'No liked hospitals yet. Tap the heart icon on any hospital to add it here!',
                              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
                            ),
                          )
                        : SizedBox(
                            height: 160,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: _likedHospitalsPreview.length > 3 ? 3 : _likedHospitalsPreview.length,
                              itemBuilder: (context, index) {
                                final h = _likedHospitalsPreview[index];
                                return _buildHospitalCard(
                                  context,
                                  h['_id'] ?? '',
                                  h['name'] ?? 'Hospital',
                                  h['image'] ?? 'https://images.unsplash.com/photo-1586773860418-d37222d8fce3?w=400',
                                );
                              },
                            ),
                          ),


                const SizedBox(height: 25),

                // Category Section
                _buildSectionHeader(
                  'Category',
                  onMoreTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllCategoriesPage(categories: _categories),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      return _buildCategoryCard(
                        _categories[index]['name']!,
                        _categories[index]['image']!,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 25),

                // Recently Visited Section for application homepage
                _buildSectionHeader('Recently Visited'),
                const SizedBox(height: 15),
                SizedBox(
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _realHospitals.length,
                    itemBuilder: (context, index) {
                      final h = _realHospitals[(_realHospitals.length - 1) - index];
                      return _buildHospitalCard(
                        context,
                        h['_id'] ?? '',
                        h['name'] ?? 'Hospital',
                        h['image'] ?? 'https://images.unsplash.com/photo-1586773860418-d37222d8fce3?w=400',
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildDot(bool isActive) {
    return Container(
      width: isActive ? 10 : 8,
      height: isActive ? 10 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.blue : Colors.grey.shade400,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onMoreTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (onMoreTap != null)
            ScaleOnTap(
              onTap: onMoreTap,
              child: const Icon(Icons.more_vert, color: Colors.black),
            ),
        ],

      ),
    );
  }


  Widget _buildHospitalCard(BuildContext context, String id, String name, String imageUrl) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HospitalDetailsPage(
              hospitalId: id,
              hospitalName: name,
              hospitalImage: imageUrl,
            ),
          ),
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
                image: (imageUrl != null && imageUrl.isNotEmpty)
                  ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
                boxShadow: [
                   BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                   )
                ]
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String name, String imageUrl) {
    return Container(
      width: 85,
      margin: const EdgeInsets.only(right: 15),
      child: Column(
        children: [
          Container(
             height: 80,
             width: 85,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              image: (imageUrl != null && imageUrl.isNotEmpty)
                ? DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  )
                : null,
              border: Border.all(color: Colors.grey.shade200),
               boxShadow: [
                 BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                 )
              ]
            ),
          ),
          if (name.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavBarContent() {
    final List<Map<String, dynamic>> navItems = [
      {'icon': Icons.home_filled, 'label': 'Home'},
      {'icon': Icons.receipt_long, 'label': 'Bookings'},
      {'icon': Icons.chat_bubble_outline, 'label': 'Chat'},
      {'icon': Icons.person_outline, 'label': 'Profile'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(navItems.length, (index) {
          final bool isActive = _selectedIndex == index;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (_selectedIndex != index) {
                HapticFeedback.lightImpact();
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOutCubic,
                );
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: isActive ? 16 : 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isActive ? Colors.white.withOpacity(0.24) : Colors.transparent,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    navItems[index]['icon'] as IconData,
                    color: Colors.white,
                    size: 24,
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOutCubic,
                    child: isActive
                        ? Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              navItems[index]['label'] as String,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class AnimatedBell extends StatefulWidget {
  const AnimatedBell({super.key});

  @override
  State<AnimatedBell> createState() => _AnimatedBellState();
}

class _AnimatedBellState extends State<AnimatedBell>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this)
      ..repeat(reverse: true);
    _animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.1, end: -0.1), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -0.1, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value,
          child: const Icon(Icons.notifications_none, color: Colors.black),
        );
      },
    );
  }
}
