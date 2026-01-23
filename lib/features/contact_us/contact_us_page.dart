import 'package:commercepal/features/contact_us/social_media.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final String phoneNumber = "+251 90-433-0066";
  final String phoneNumber2 = "+251 90-433-0066";
  final String phoneNumber3 = "9491";
  final String url = "https://commercepal.com/browse";

  Future<void> _makePhoneCall(String phone) async {
    try {
      final Uri launchUri = Uri(scheme: 'tel', path: phone);
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not launch $phone'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _openWebsite() async {
    try {
      final uri = Uri.parse(url);

      // Try platform default first, then external if needed
      bool launched = false;

      try {
        launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (e) {
        // Fallback to external application mode
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch $url'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error launching URL: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: (iconColor ?? AppColors.primary).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(Spacing.xs),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: Colors.black,
            ),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Contact Us",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                Spacing.xl,
                Spacing.xxl,
                Spacing.xl,
                Spacing.xl,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.support_agent,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: Spacing.lg),
                  const Text(
                    "Get in Touch",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 28,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),
                  Text(
                    "If you have any inquiries, get in touch with us.\nWe will be happy to help you.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // Contact Methods Section
            Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: Spacing.md),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: Spacing.xs,
                      bottom: Spacing.md,
                    ),
                    child: Text(
                      "Contact Methods",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  // Short Code
                  _buildContactCard(
                    icon: Icons.phone_in_talk,
                    title: "Short Code",
                    subtitle: phoneNumber3,
                    iconColor: AppColors.success,
                    onTap: () => _makePhoneCall(phoneNumber3),
                  ),

                  // Phone Number
                  _buildContactCard(
                    icon: Icons.phone,
                    title: "Phone Number",
                    subtitle: phoneNumber,
                    iconColor: AppColors.success,
                    onTap: () => _makePhoneCall(phoneNumber),
                  ),

                  // Website
                  _buildContactCard(
                    icon: FontAwesomeIcons.globe,
                    title: "Website",
                    subtitle: "https://commercepal.com",
                    iconColor: AppColors.info,
                    onTap: _openWebsite,
                  ),
                ],
              ),
            ),

            // Social Media Section
            Container(
              margin: const EdgeInsets.all(Spacing.md),
              padding: const EdgeInsets.all(Spacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.share,
                          color: AppColors.secondary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: Spacing.sm),
                      Text(
                        "Social Media",
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              color: Colors.black87,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  const SocialMediaLink(
                    icon: Icons.facebook,
                    text:
                        'Stay updated, connect, and engage with us on Facebook.',
                    url: 'https://www.facebook.com/Commercepal/',
                  ),
                  const SocialMediaLink(
                    icon: FontAwesomeIcons.instagram,
                    text:
                        'Explore our visual world and discover beauty of our brand.',
                    url:
                        'https://www.instagram.com/commercepal1/?igshid=YmMyMTA2M2Y%3D',
                  ),
                  const SocialMediaLink(
                    icon: FontAwesomeIcons.tiktok,
                    text:
                        'Discover the beauty of our brand and explore our visual world on TikTok.',
                    url: 'https://www.tiktok.com/@commercepal',
                  ),
                  const SocialMediaLink(
                    icon: FontAwesomeIcons.twitter,
                    text:
                        'Follow us for real-time updates and lively discussions.',
                    url:
                        'https://x.com/CommercePal?t=3gF1oMXGc2GJmiawxvYvvA&s=09',
                  ),
                  const SocialMediaLink(
                    icon: FontAwesomeIcons.telegram,
                    text: 'Connect with us on Telegram @CP9491.',
                    url: 'https://t.me/CP9491',
                  ),
                ],
              ),
            ),

            const SizedBox(height: Spacing.xl),
          ],
        ),
      ),
    );
  }
}
