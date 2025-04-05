import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'appointment_screen.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  // Example data
  final String companyName = "Darnal Bro Jewelry";
  final String tagline = "Buy | Sell | Trade Gold";
  final String addressLine1 = "137221 Lorain Ave";
  final String addressLine2 = "Cleveland, CH 44111";
  final String phoneNumber = "(123) 456-7890";
  final String emailAddress = "yes@xyz.com";

  // Replace with your actual Google Maps URL or lat/long
  final String googleMapsUrl =
      "https://www.google.com/maps/search/?api=1&query=137221+Lorain+Ave,+Cleveland";

  // Example: Appointment scheduling link or phone call
  final String appointmentUrl = "tel:(123)456-7890";

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      debugPrint("Could not launch $urlString");
    }
  }

  // Open Google Maps with the address
  Future<void> _openMap() async {
    await _launchUrl(googleMapsUrl);
  }

  // Dial the phone
  Future<void> _callNumber() async {
    final Uri telUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    } else {
      debugPrint("Could not launch phone dialer.");
    }
  }

  // Launch email
  Future<void> _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: emailAddress,
      query: 'subject=Inquiry', // Add subject, body, etc. if desired
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      debugPrint("Could not launch email client.");
    }
  }

  // Make an appointment (example: call, or open a scheduling URL)

  // Social media links
  Future<void> _openFacebook() async {
    await _launchUrl("https://facebook.com/");
  }

  Future<void> _openInstagram() async {
    await _launchUrl("https://instagram.com/");
  }

  Future<void> _openYoutube() async {
    await _launchUrl("https://youtube.com/");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Red header with logo/title
            Container(
              color: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
              width: double.infinity,
              child: SafeArea(
                child: Column(
                  children: [
                    Text(
                      companyName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tagline,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 2. Card for Address
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        addressLine1,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        addressLine2,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _openMap,
                            icon: const Icon(Icons.location_pin),
                            label: const Text("Get Direction"),
                          ),
                          const Spacer(),
                          // Optional location icon on the right
                          const Icon(Icons.location_on, color: Colors.red),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 3. Card for Phone
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  onTap: _callNumber,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.phone, color: Colors.red),
                        const SizedBox(width: 12),
                        Text(
                          phoneNumber,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 4. Card for Email
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  onTap: _sendEmail,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.email, color: Colors.red),
                        const SizedBox(width: 12),
                        Text(
                          emailAddress,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 5. Make an Appointment button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AppointmentScreen(),
                  ),
                );
              },
              child: const Text(
                "Make an Appointment",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),

            // 6. Social icons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.facebook, color: Colors.red, size: 32),
                  onPressed: _openFacebook,
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.camera_alt_outlined, color: Colors.red, size: 32),
                  onPressed: _openInstagram,
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.play_circle_fill, color: Colors.red, size: 32),
                  onPressed: _openYoutube,
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
