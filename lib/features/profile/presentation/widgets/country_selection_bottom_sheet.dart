import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:commercepal/core/constants/country_currency_constants.dart';
import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/services/localization_service.dart';

class CountrySelectionBottomSheet extends StatefulWidget {
  const CountrySelectionBottomSheet({super.key});

  static Future<String?> show(BuildContext context) async {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => const CountrySelectionBottomSheet(),
    );
  }

  @override
  State<CountrySelectionBottomSheet> createState() => _CountrySelectionBottomSheetState();
}

class _CountrySelectionBottomSheetState extends State<CountrySelectionBottomSheet> with SingleTickerProviderStateMixin {
  late String _selectedCountryCode;
  final Storage _storage = Storage();
  bool _isLoading = true;
  String _searchQuery = '';
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadCurrentSelection();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentSelection() async {
    final currentCountry = await _storage.getSelectedCountry();
    setState(() {
      _selectedCountryCode = currentCountry;
      _isLoading = false;
    });
  }

  Future<void> _saveSelection(String countryCode) async {
    setState(() {
      _selectedCountryCode = countryCode;
    });
    
    await _storage.saveSelectedCountry(countryCode);
    HapticFeedback.mediumImpact();
    
    if (mounted) {
      // Small delay for visual feedback
      await Future.delayed(const Duration(milliseconds: 300));
      Navigator.of(context).pop(countryCode);
    }
  }

  List<CountryInfo> get _filteredCountries {
    if (_searchQuery.isEmpty) {
      return CountryCurrencyConstants.supportedCountries;
    }
    return CountryCurrencyConstants.supportedCountries
        .where((country) => country.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Container(
      height: screenHeight * 0.85,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: <Widget>[
            // Drag indicator
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: Spacing.md, bottom: Spacing.md),
                decoration: BoxDecoration(
                  color: scheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                   Text(
                    LocalizationService.t(context, 'profile.selectCountry'),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),
                  // Subtitle
                  Text(
                    LocalizationService.t(context, 'profile.chooseYourLocation'),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: Spacing.lg),
                  // Globe & Flags Illustration
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildGlobeFlagsIllustration(),
                  ),
                  const SizedBox(height: Spacing.lg),
                  // Search field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: LocalizationService.t(context, 'profile.searchCountries'),
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey.shade600,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(Spacing.md),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: Spacing.md),
                ],
              ),
            ),
            // Country list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredCountries.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: Spacing.md),
                              Text(
                                LocalizationService.t(context, 'profile.noCountriesFound'),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                          itemCount: _filteredCountries.length,
                          itemBuilder: (BuildContext context, int index) {
                            final country = _filteredCountries[index];
                            final isSelected = _selectedCountryCode == country.code;

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(bottom: Spacing.sm),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withOpacity(0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.grey.shade200,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: Spacing.md,
                                  vertical: Spacing.sm,
                                ),
                                leading: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      country.flagEmoji,
                                      style: const TextStyle(fontSize: 32),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  country.name,
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Text(
                                  country.code,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: AnimatedScale(
                                  scale: isSelected ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 200),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                onTap: () => _saveSelection(country.code),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobeFlagsIllustration() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade50,
            Colors.cyan.shade50,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: <Widget>[
          // Background decorative elements
          Positioned(
            top: 15,
            left: 20,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.blue.shade200,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 30,
            right: 25,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.cyan.shade200,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 30,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.blue.shade200,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Main globe in center
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Globe
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade400,
                        Colors.blue.shade600,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade200,
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: CustomPaint(
                    painter: _GlobePainter(),
                  ),
                ),
                // Location pin in center
                Icon(
                  Icons.location_on,
                  size: 40,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          // Orbiting flags
          Positioned(
            top: 30,
            left: 80,
            child: _buildFlagBubble('🇪🇹'),
          ),
          Positioned(
            top: 45,
            right: 70,
            child: _buildFlagBubble('🇺🇸'),
          ),
          Positioned(
            bottom: 35,
            left: 60,
            child: _buildFlagBubble('🇬🇧'),
          ),
          Positioned(
            bottom: 40,
            right: 80,
            child: _buildFlagBubble('🇨🇦'),
          ),
          // Airplane
          Positioned(
            top: 20,
            right: 40,
            child: Transform.rotate(
              angle: -0.5,
              child: Icon(
                Icons.flight,
                size: 24,
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlagBubble(String flag) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        flag,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}

class _GlobePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw latitude lines
    for (int i = 1; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Draw longitude lines (curved)
    for (int i = 1; i < 4; i++) {
      final x = size.width * i / 4;
      final path = Path();
      path.moveTo(x, 0);
      path.quadraticBezierTo(
        x + size.width * 0.1,
        size.height / 2,
        x,
        size.height,
      );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
