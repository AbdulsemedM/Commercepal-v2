import 'package:flutter/material.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/widgets/app_bar.dart';
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
      appBar: AppBarWidget(
        cartCount: 0,
        userInitials: 'U',
        onSearchSubmitted: (String query) => null,
        onLogoTap: () => Navigator.of(context).pop(),
        onCartTap: null,
        onProfileTap: null,
        hasNotification: false,
      ),
      body: Column(
        children: <Widget>[
          // White navigation bar with tabs
          Container(
            decoration: const BoxDecoration(color: Colors.white),
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.sm,
            ),
            child: Row(
              children: <Widget>[
                // Tabs
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Flexible(
                        child: _buildTab(
                          context,
                          0,
                          LocalizationService.t(
                            context,
                            'productDetails.description',
                          ),
                        ),
                      ),
                      const SizedBox(width: Spacing.xs),
                      Flexible(
                        child: _buildTab(
                          context,
                          1,
                          LocalizationService.t(
                            context,
                            'productDetails.technicalSpecifications',
                          ),
                        ),
                      ),
                      const SizedBox(width: Spacing.xs),
                      Flexible(
                        child: _buildTab(
                          context,
                          2,
                          LocalizationService.t(
                            context,
                            'productDetails.comment',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Spacing.sm),
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
          // Content area
          Expanded(child: _buildContent(context)),
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
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? Colors.black87 : Colors.grey.shade600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          if (isSelected)
            Container(
              height: 2,
              width: double.infinity,
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
          _buildSectionTitle(
            'Thin and light design, thin 5.9mm, soft rounded edges, elegant silver color',
          ),
          const SizedBox(height: Spacing.sm),
          _buildSectionText(
            'The Apple iPad Pro 11" (2020) Wifi 128Gb (Silver) features a sleek and lightweight design with a thickness of just 5.9mm. Weighing only 471g, it offers exceptional portability. The device measures 247.6 x 178.5 mm, making it perfect for on-the-go use. The elegant silver color and soft rounded edges provide a premium feel.',
          ),
          const SizedBox(height: Spacing.lg),
          _buildSectionTitle(
            '120Hz screen, 16 million colors, 11-inch IPS LCD panel',
          ),
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
          _buildSectionTitle(
            'Impressive performance when owning the A12Z Bionic chip',
          ),
          const SizedBox(height: Spacing.sm),
          _buildSectionText(
            'Powered by the 8-core A12Z Bionic chip, this iPad Pro delivers exceptional performance. The improved controller system enables seamless multitasking and smooth operation. Whether you\'re editing 4K videos or designing 3D images, the device handles it with ease. Choose between 128GB and 256GB internal memory options to suit your storage needs.',
          ),
          const SizedBox(height: Spacing.lg),
          _buildSectionTitle(
            'Improved rear camera system with LIDAR depth gauge',
          ),
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
          _buildSpecRow(
            'Display',
            '11-inch IPS LCD, 1668x2388 pixels, 120Hz ProMotion',
          ),
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
          // Review Section
          _buildSectionTitle('Review'),
          const SizedBox(height: Spacing.md),
          // Overall rating
          Row(
            children: <Widget>[
              Text(
                '4.5',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Text(
                '832 review',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          // Star rating visual
          _buildLargeStarRating(4.5),
          const SizedBox(height: Spacing.lg),
          // Rating breakdown
          _buildRatingBreakdown(5, 750, 832),
          const SizedBox(height: Spacing.sm),
          _buildRatingBreakdown(4, 52, 832),
          const SizedBox(height: Spacing.sm),
          _buildRatingBreakdown(3, 24, 832),
          const SizedBox(height: Spacing.sm),
          _buildRatingBreakdown(2, 6, 832),
          const SizedBox(height: Spacing.sm),
          _buildRatingBreakdown(1, 0, 832),
          const SizedBox(height: Spacing.xl),
          // Comment Section
          _buildSectionTitle('Comment'),
          const SizedBox(height: Spacing.md),
          _buildDetailedCommentItem(
            'Ralph Edwards',
            'October 20, 2020',
            'Gold color',
            'Watch the movie very loud, very sharp. Paper wrap - protect the environment. There is a stamp on fragile goods, but the more it is - the more the courier will throw ...: D',
            hasProfileImage: true,
          ),
          const SizedBox(height: Spacing.md),
          _buildDetailedCommentItem(
            'Savannah Nguyen',
            'September 3, 2020',
            'Sliver color',
            'I bought and used very well compared to the price range. It is advised that you should use Pockie\'s Fast Delivery service which will be faster and avoid more distortion than standard Delivery. Before, I bought it for my brother ipad 9.7 2018 Standard delivery, the box a lot distorted.',
            initials: 'SN',
          ),
          const SizedBox(height: Spacing.md),
          _buildDetailedCommentItem(
            'Cody Fisher',
            'September 3, 2020',
            'White color',
            'Venture to buy a valuable technology product online for the first time! I have to say chonhagiau CSKH is too good, I book on September 3, there is no fast delivery so 9/9 deadline is available, but there is a busy job so thanks to early delivery support, today 9/9 is in stock! Hope using no problem later ..',
            initials: 'CF',
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

  Widget _buildLargeStarRating(double rating) {
    return Row(
      children: List<Widget>.generate(5, (int index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, color: Colors.amber, size: 32);
        } else if (index < rating) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 32);
        } else {
          return const Icon(Icons.star_border, color: Colors.amber, size: 32);
        }
      }),
    );
  }

  Widget _buildRatingBreakdown(int stars, int count, int total) {
    final double percentage = total > 0 ? count / total : 0.0;
    return Row(
      children: <Widget>[
        // Star icons
        Row(
          children: List<Widget>.generate(5, (int index) {
            if (index < stars) {
              return const Icon(Icons.star, color: Colors.amber, size: 16);
            } else {
              return const Icon(
                Icons.star_border,
                color: Colors.grey,
                size: 16,
              );
            }
          }),
        ),
        const SizedBox(width: Spacing.sm),
        // Progress bar
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: Spacing.sm),
        // Count
        Text(
          '$count',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _buildDetailedCommentItem(
    String name,
    String date,
    String color,
    String comment, {
    bool hasProfileImage = false,
    String? initials,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Profile picture
            if (hasProfileImage)
              CircleAvatar(
                radius: 24,
                backgroundImage: null, // In real app, would load image
                backgroundColor: Colors.grey.shade300,
                child: const Icon(Icons.person, color: Colors.grey),
              )
            else
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.pink.shade100,
                child: Text(
                  initials ?? name.substring(0, 2).toUpperCase(),
                  style: TextStyle(
                    color: Colors.pink.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: Spacing.xs),
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.xs),
                  // Purchase info tags
                  Wrap(
                    spacing: Spacing.xs,
                    runSpacing: Spacing.xs,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Purchased by 247 supplier',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          color,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.xs),
                  // Star rating
                  Row(
                    children: List<Widget>.generate(5, (int index) {
                      return const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 16,
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        // Comment text
        Text(
          comment,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade800,
            height: 1.5,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        // Like and Reply actions
        Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.thumb_up_outlined, size: 18),
              color: Colors.grey.shade600,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {},
            ),
            const SizedBox(width: Spacing.xs),
            Text(
              'Like',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(width: Spacing.md),
            IconButton(
              icon: Icon(Icons.reply_outlined, size: 18),
              color: Colors.grey.shade600,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {},
            ),
            const SizedBox(width: Spacing.xs),
            Text(
              'Reply',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ],
    );
  }
}
