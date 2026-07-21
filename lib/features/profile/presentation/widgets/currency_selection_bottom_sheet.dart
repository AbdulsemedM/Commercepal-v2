import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:commercepal/core/constants/country_currency_constants.dart';
import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/theme/app_decorations.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/services/localization_service.dart';

class CurrencySelectionBottomSheet extends StatefulWidget {
  const CurrencySelectionBottomSheet({super.key});

  static Future<String?> show(BuildContext context) async {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => const CurrencySelectionBottomSheet(),
    );
  }

  @override
  State<CurrencySelectionBottomSheet> createState() => _CurrencySelectionBottomSheetState();
}

class _CurrencySelectionBottomSheetState extends State<CurrencySelectionBottomSheet> with SingleTickerProviderStateMixin {
  late String _selectedCurrencyCode;
  final Storage _storage = Storage();
  bool _isLoading = true;
  String _searchQuery = '';
  late AnimationController _animationController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _loadCurrentSelection();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _floatAnimation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentSelection() async {
    final currentCurrency = await _storage.getSelectedCurrency();
    setState(() {
      _selectedCurrencyCode = currentCurrency;
      _isLoading = false;
    });
  }

  Future<void> _saveSelection(String currencyCode) async {
    setState(() {
      _selectedCurrencyCode = currencyCode;
    });
    
    await _storage.saveSelectedCurrency(currencyCode);
    HapticFeedback.mediumImpact();
    
    if (mounted) {
      // Small delay for visual feedback
      await Future.delayed(const Duration(milliseconds: 300));
      Navigator.of(context).pop(currencyCode);
    }
  }

  List<CurrencyInfo> get _filteredCurrencies {
    if (_searchQuery.isEmpty) {
      return CountryCurrencyConstants.supportedCurrencies;
    }
    return CountryCurrencyConstants.supportedCurrencies
        .where((currency) =>
            currency.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            currency.code.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            currency.symbol.contains(_searchQuery))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Container(
      height: screenHeight * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
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
                    LocalizationService.t(context, 'profile.selectCurrency'),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),
                  // Subtitle
                  Text(
                    LocalizationService.t(context, 'profile.chooseYourCurrency'),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: Spacing.lg),
                  // Money & Exchange Illustration
                  _buildMoneyExchangeIllustration(),
                  const SizedBox(height: Spacing.lg),
                  // Search field
                  Container(
                    decoration: BoxDecoration(
                      color: AppDecorations.softCream,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: LocalizationService.t(context, 'profile.searchCurrencies'),
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
            // Currency list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredCurrencies.isEmpty
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
                                LocalizationService.t(context, 'profile.noCurrenciesFound'),
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
                          itemCount: _filteredCurrencies.length,
                          itemBuilder: (BuildContext context, int index) {
                            final currency = _filteredCurrencies[index];
                            final isSelected = _selectedCurrencyCode == currency.code;

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(bottom: Spacing.sm),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withOpacity(0.1)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.grey.shade200,
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: isSelected
                                    ? null
                                    : AppDecorations.softCardShadow(),
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
                                    gradient: LinearGradient(
                                      colors: isSelected
                                          ? [
                                              AppColors.pink,
                                              AppColors.primary,
                                            ]
                                          : [
                                              AppDecorations.softCream,
                                              Colors.grey.shade200,
                                            ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: AppColors.pink
                                                  .withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      currency.symbol,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  currency.name,
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Text(
                                  currency.code,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
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
                                onTap: () => _saveSelection(currency.code),
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

  Widget _buildMoneyExchangeIllustration() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade50,
            Colors.amber.shade50,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: <Widget>[
          // Background decorative coins
          Positioned(
            top: 20,
            left: 25,
            child: _buildCoin(Colors.amber.shade300, 30),
          ),
          Positioned(
            top: 35,
            right: 30,
            child: _buildCoin(Colors.amber.shade400, 25),
          ),
          Positioned(
            bottom: 25,
            left: 35,
            child: _buildCoin(Colors.amber.shade300, 28),
          ),
          Positioned(
            bottom: 30,
            right: 25,
            child: _buildCoin(Colors.amber.shade400, 32),
          ),
          // Central exchange concept
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Floating currency symbols with exchange arrows
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _floatAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _floatAnimation.value),
                          child: _buildCurrencyBubble('\$', Colors.green),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.swap_horiz,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedBuilder(
                      animation: _floatAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, -_floatAnimation.value),
                          child: _buildCurrencyBubble('€', Colors.blue),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Second row of currencies
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _floatAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, -_floatAnimation.value * 0.7),
                          child: _buildCurrencyBubble('£', Colors.purple),
                        );
                      },
                    ),
                    const SizedBox(width: 40),
                    AnimatedBuilder(
                      animation: _floatAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _floatAnimation.value * 0.7),
                          child: _buildCurrencyBubble('¥', Colors.orange),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Wallet icon
          Positioned(
            bottom: 20,
            right: 70,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.account_balance_wallet,
                color: Colors.green.shade600,
                size: 24,
              ),
            ),
          ),
          // Trending chart
          Positioned(
            top: 20,
            left: 70,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    color: Colors.green.shade600,
                    size: 16,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '1.23',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
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

  Widget _buildCurrencyBubble(String symbol, Color color) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.8),
            color,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          symbol,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildCoin(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.6,
          height: size * 0.6,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
