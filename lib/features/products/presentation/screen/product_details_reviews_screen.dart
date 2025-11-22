import 'package:flutter/material.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/services/localization_service.dart';

class ProductDetailsReviewsScreen extends StatefulWidget {
  const ProductDetailsReviewsScreen({
    super.key,
    this.productId,
    this.productName,
  });

  final String? productId;
  final String? productName;

  @override
  State<ProductDetailsReviewsScreen> createState() =>
      _ProductDetailsReviewsScreenState();
}

class _ProductDetailsReviewsScreenState
    extends State<ProductDetailsReviewsScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          // Dark magenta background extending behind status bar
          Container(
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: SafeArea(
              bottom: false,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.sm,
                ),
                child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.sm,
                ),
                child: Row(
                  children: <Widget>[
                    // Back button
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    // Tabs
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          _buildTab(
                            context,
                            0,
                            LocalizationService.t(
                              context,
                              'productDetails.description',
                            ),
                          ),
                          const SizedBox(width: Spacing.md),
                          _buildTab(
                            context,
                            1,
                            LocalizationService.t(
                              context,
                              'productDetails.technicalSpecifications',
                            ),
                          ),
                          const SizedBox(width: Spacing.md),
                          _buildTab(
                            context,
                            2,
                            LocalizationService.t(
                              context,
                              'productDetails.comment',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    // Chat/Notification icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          const Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                ),
              ),
            ),
          ),
          // Content area
          Expanded(
            child: _buildContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, int index, String label) {
    final bool isSelected = _selectedTabIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? Colors.black87 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          if (isSelected)
            Container(
              height: 2,
              width: label.length * 8.0,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.all(Radius.circular(1)),
              ),
            )
          else
            const SizedBox(height: 2),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildDescriptionContent();
      case 1:
        return _buildTechnicalSpecificationsContent();
      case 2:
        return _buildCommentContent();
      default:
        return _buildDescriptionContent();
    }
  }

  Widget _buildDescriptionContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildSectionTitle('Thin and light design, thin 5.9mm, soft rounded edges, elegant silver color'),
          const SizedBox(height: Spacing.sm),
          _buildSectionText(
            'The Apple iPad Pro 11" (2020) Wifi 128Gb (Silver) features a sleek and lightweight design with a thickness of just 5.9mm. Weighing only 471g, it offers exceptional portability. The device measures 247.6 x 178.5 mm, making it perfect for on-the-go use. The elegant silver color and soft rounded edges provide a premium feel.',
          ),
          const SizedBox(height: Spacing.lg),
          _buildSectionTitle('120Hz screen, 16 million colors, 11-inch IPS LCD panel'),
          const SizedBox(height: Spacing.sm),
          _buildSectionText(
            'Experience stunning visuals with the 11-inch IPS LCD panel featuring a 120Hz refresh rate for smooth scrolling and interactions. The display supports 16 million colors, delivering vibrant and accurate color reproduction. With a resolution of 1668x2388 pixels, every detail comes to life. The ProMotion technology ensures fluid motion, while True Tone adjusts the white balance to match your environment. An oleophobic coating reduces fingerprints and smudges.',
          ),
          const SizedBox(height: Spacing.lg),
          _buildSectionTitle('Perfect Experience'),
          const SizedBox(height: Spacing.sm),
          _buildSectionText(
            'The iPad (2019) 10.2" Wifi + Cellular 32GB (Gold) offers a perfect experience with its Retina display and stereo system. Access your favorite streaming services and enjoy immersive entertainment wherever you go.',
          ),
          const SizedBox(height: Spacing.lg),
          _buildSectionTitle('Impressive performance when owning the A12Z Bionic chip'),
          const SizedBox(height: Spacing.sm),
          _buildSectionText(
            'Powered by the 8-core A12Z Bionic chip, this iPad Pro delivers exceptional performance. The improved controller system enables seamless multitasking and smooth operation. Whether you\'re editing 4K videos or designing 3D images, the device handles it with ease. Choose between 128GB and 256GB internal memory options to suit your storage needs.',
          ),
          const SizedBox(height: Spacing.lg),
          _buildSectionTitle('Improved rear camera system with LIDAR depth gauge'),
          const SizedBox(height: Spacing.sm),
          _buildSectionText(
            'Capture stunning photos and videos with the advanced camera system. The dual rear camera setup includes a 12MP main camera and a 10MP ultra-wide camera, allowing you to capture more in every shot. The LiDAR scanner provides depth sensing up to 5 meters, enabling enhanced AR experiences and improved photography. Record videos in stunning 4K quality. The 7MP selfie camera is perfect for 1080p video calls and vlogging, ensuring you always look your best.',
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalSpecificationsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildSpecRow('Display', '11-inch IPS LCD, 1668x2388 pixels, 120Hz ProMotion'),
          const SizedBox(height: Spacing.md),
          _buildSpecRow('Chipset', 'Apple A12Z Bionic 8-core'),
          const SizedBox(height: Spacing.md),
          _buildSpecRow('Storage', '128GB / 256GB'),
          const SizedBox(height: Spacing.md),
          _buildSpecRow('Operating System', 'iOS 13'),
          const SizedBox(height: Spacing.md),
          _buildSpecRow('Dimensions', '247.6 x 178.5 x 5.9 mm'),
          const SizedBox(height: Spacing.md),
          _buildSpecRow('Weight', '471g'),
          const SizedBox(height: Spacing.md),
          _buildSpecRow('Rear Camera', '12MP main + 10MP ultra-wide'),
          const SizedBox(height: Spacing.md),
          _buildSpecRow('Front Camera', '7MP'),
          const SizedBox(height: Spacing.md),
          _buildSpecRow('Video Recording', '4K video recording'),
          const SizedBox(height: Spacing.md),
          _buildSpecRow('LiDAR Scanner', 'Depth sensing up to 5m'),
          const SizedBox(height: Spacing.md),
          _buildSpecRow('Connectivity', 'Wi-Fi'),
          const SizedBox(height: Spacing.md),
          _buildSpecRow('Color', 'Silver'),
        ],
      ),
    );
  }

  Widget _buildCommentContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildSectionTitle('Customer Reviews'),
          const SizedBox(height: Spacing.md),
          _buildCommentItem(
            'John D.',
            '5.0',
            'Excellent product! The display is amazing and the performance is outstanding.',
          ),
          const SizedBox(height: Spacing.md),
          _buildCommentItem(
            'Sarah M.',
            '4.5',
            'Great tablet for work and entertainment. The camera quality is impressive.',
          ),
          const SizedBox(height: Spacing.md),
          _buildCommentItem(
            'Mike T.',
            '5.0',
            'Perfect for my needs. The battery life is excellent and the design is beautiful.',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildSectionText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.grey.shade800,
        height: 1.6,
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentItem(String name, String rating, String comment) {
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary,
                child: Text(
                  name[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            comment,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade800,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

