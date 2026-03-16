import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'animation_utils.dart'; // Assuming this is in the same folder

class BookingCard extends StatelessWidget {
  final String hospitalName;
  final String department;
  final String doctorName;
  final String patientName;
  final String date;
  final String time;
  final String tokenNumber;
  final String status;
  final VoidCallback? onActionTap;
  final String actionText;

  const BookingCard({
    super.key,
    required this.hospitalName,
    this.department = 'General',
    required this.doctorName,
    required this.patientName,
    required this.date,
    required this.time,
    required this.tokenNumber,
    this.status = 'Upcoming',
    this.onActionTap,
    this.actionText = 'Directions',
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    if (status.toUpperCase() == 'COMPLETED') {
      statusColor = Colors.green;
    } else if (status.toUpperCase() == 'CANCELLED') {
      statusColor = Colors.redAccent;
    } else {
      statusColor = const Color(0xFF3B9966); // Greenish for Upcoming/Pending
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Section: Token & Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      status.toUpperCase() == 'COMPLETED'
                          ? Icons.check_circle
                          : status.toUpperCase() == 'CANCELLED'
                              ? Icons.cancel
                              : Icons.access_time_filled,
                      color: statusColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      status.toUpperCase(),
                      style: GoogleFonts.poppins(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Text(
                    'Token: $tokenNumber',
                    style: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Main Content Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F6FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.local_hospital_rounded,
                        color: Color(0xFF2E4C9D),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hospitalName,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            department,
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(color: Colors.grey[200], thickness: 1.5),
                const SizedBox(height: 20),
                
                // Info Details Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        icon: Icons.calendar_today_rounded,
                        title: 'Date',
                        value: date,
                      ),
                    ),
                    Expanded(
                      child: _buildDetailItem(
                        icon: Icons.schedule_rounded,
                        title: 'Time',
                        value: time,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        icon: Icons.person_rounded,
                        title: 'Patient',
                        value: patientName,
                      ),
                    ),
                    Expanded(
                      child: _buildDetailItem(
                        icon: Icons.medical_services_rounded,
                        title: 'Doctor',
                        value: doctorName,
                      ),
                    ),
                  ],
                ),
                
                if (onActionTap != null) ...[
                  const SizedBox(height: 25),
                  ScaleOnTap(
                    onTap: onActionTap,
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E4C9D),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2E4C9D).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            status.toUpperCase() == 'COMPLETED'
                                ? Icons.refresh
                                : Icons.explore_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            actionText,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF2E4C9D).withOpacity(0.7)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.grey[500],
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
