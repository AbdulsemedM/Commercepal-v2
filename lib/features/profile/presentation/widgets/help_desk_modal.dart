import 'package:flutter/material.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/theme/app_decorations.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/services/localization_service.dart';

class HelpDeskModal extends StatefulWidget {
  const HelpDeskModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => const HelpDeskModal(),
    );
  }

  @override
  State<HelpDeskModal> createState() => _HelpDeskModalState();
}

class _HelpDeskModalState extends State<HelpDeskModal> {
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Drag indicator
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: Spacing.md),
                  decoration: BoxDecoration(
                    color: scheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Title
              Text(
                LocalizationService.t(context, 'profile.helpDesk'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: Spacing.sm),
              // Description
              Text(
                LocalizationService.t(context, 'profile.helpDeskSubtitle'),
                style: TextStyle(
                  fontSize: 14,
                  color: scheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: Spacing.lg),
              // Illustration
              _buildIllustration(),
              const SizedBox(height: Spacing.xl),
              // Description label
              Text(
                LocalizationService.t(context, 'profile.description'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: Spacing.sm),
              // Text area
              Container(
                decoration: BoxDecoration(
                  color: AppDecorations.softCream,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: LocalizationService.t(context, 'profile.writeSomething'),
                    hintStyle: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(Spacing.md),
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: Spacing.xl),
              // Send Message button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: AppDecorations.primaryCtaGradient,
                    borderRadius: BorderRadius.all(Radius.circular(28)),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // Handle send message
                        Navigator.of(context).pop();
                      },
                      borderRadius: BorderRadius.circular(28),
                      child: Center(
                        child: Text(
                          LocalizationService.t(context, 'profile.sendMessage'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppDecorations.softCream,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: <Widget>[
          // Desk
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
            ),
          ),
          // Person with headphones
          Positioned(
            bottom: 60,
            left: 40,
            child: Column(
              children: <Widget>[
                // Headphones
                Container(
                  width: 60,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                const SizedBox(height: 4),
                // Head
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.brown,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 4),
                // Body
                Container(
                  width: 50,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 4),
                // Pants
                Container(
                  width: 50,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Laptop
          Positioned(
            bottom: 80,
            left: 100,
            child: Container(
              width: 80,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.35),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Container(
                  width: 60,
                  height: 35,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
          // Mouse
          Positioned(
            bottom: 75,
            left: 190,
            child: Container(
              width: 30,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.35),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          // Plant
          Positioned(
            bottom: 60,
            right: 40,
            child: Container(
              width: 30,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.green.shade300,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          // Speech bubbles
          Positioned(
            top: 20,
            left: 120,
            child: Container(
              width: 40,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: AppDecorations.softCardShadow(),
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 20,
                color: AppColors.primary,
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 60,
            child: Container(
              width: 40,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: AppDecorations.softCardShadow(),
              ),
              child: const Icon(
                Icons.help_outline,
                size: 20,
                color: AppColors.pink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

