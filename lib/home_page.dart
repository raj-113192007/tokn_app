import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  // Logo/Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(12),
                      image: const DecorationImage(
                        image: AssetImage('assets/splash_logo.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Hi User',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  // Notification Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notifications_outlined, color: Colors.black),
                  ),
                ],
              ),
            ),

            // Search Bar Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  // Location Icon
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.location_on_outlined, color: Colors.black),
                  ),
                  const SizedBox(width: 10),
                  // Search Field
                  Expanded(
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.black54),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Search by category or name',
                              style: GoogleFonts.poppins(
                                color: Colors.black54,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content Scroll
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner Carousel
                    const SizedBox(height: 10),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: const DecorationImage(
                          image: NetworkImage('https://images.unsplash.com/photo-1631217868264-e5b90bb7e133?w=800'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Container(
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
                          Positioned(
                            bottom: 10,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildDot(true),
                                const SizedBox(width: 5),
                                _buildDot(false),
                                const SizedBox(width: 5),
                                _buildDot(false),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Hospitals Section
                    _buildSectionHeader('Hospitals'),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 160,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _hospitals.length,
                        itemBuilder: (context, index) {
                          return _buildHospitalCard(
                            _hospitals[index]['name']!,
                            _hospitals[index]['image']!,
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Category Section
                    _buildSectionHeader('Category'),
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

                    // Recently Visited Section - reusing categories for demo purposes
                    _buildSectionHeader('Recently Visited'),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 110,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) { // Just reversing for variety
                           final reversedIndex = (_categories.length - 1) - index;
                          return _buildCategoryCard(
                            _categories[reversedIndex]['name']!,
                            _categories[reversedIndex]['image']!,
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
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF2E4C9D), // Blue
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_filled, 'Home', _selectedIndex == 0, 0),
            _buildNavItem(Icons.receipt_long, 'History', _selectedIndex == 1, 1),
            _buildNavItem(Icons.chat_bubble_outline, 'Chat', _selectedIndex == 2, 2),
            _buildNavItem(Icons.person_outline, 'Profile', _selectedIndex == 3, 3),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      width: isActive ? 8 : 6,
      height: isActive ? 8 : 6,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white54,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
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
          const Icon(Icons.more_vert, color: Colors.black),
        ],
      ),
    );
  }

  Widget _buildHospitalCard(String name, String imageUrl) {
    return Container(
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
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
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
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
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

  Widget _buildNavItem(IconData icon, String label, bool isActive, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
           Container(
             decoration: isActive ? BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
             ) : null,
            padding: EdgeInsets.all(isActive ? 8 : 0),
            child: Icon(
              icon,
              color: Colors.white,
              size: 26,
            ),
          ),
           if (isActive) ...[
             const SizedBox(height: 4),
             Text(label, style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),)
           ]
        ],
      ),
    );
  }
}
