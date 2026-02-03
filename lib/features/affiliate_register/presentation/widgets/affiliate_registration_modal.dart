import 'package:flutter/material.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/services/localization_service.dart';
import 'package:commercepal/core/utils/device_id_utils.dart';
import 'package:commercepal/core/utils/platform_utils.dart';
import 'package:commercepal/features/affiliate/data/repository/affiliate_repository.dart';

class AffiliateRegistrationModal extends StatefulWidget {
  const AffiliateRegistrationModal({
    super.key,
    required this.onRegistrationComplete,
  });

  final VoidCallback onRegistrationComplete;

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onRegistrationComplete,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => AffiliateRegistrationModal(
        onRegistrationComplete: onRegistrationComplete,
      ),
    );
  }

  @override
  State<AffiliateRegistrationModal> createState() =>
      _AffiliateRegistrationModalState();
}

class _AffiliateRegistrationModalState
    extends State<AffiliateRegistrationModal> {
  final TextEditingController _referralCodeController = TextEditingController();
  final AffiliateRepository _repository = AffiliateRepository();
  String _selectedCommissionType = 'Percentage';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _referralCodeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      final deviceId = await DeviceIdUtils.getDeviceId();

      await _repository.registerFromCustomer(
        commissionType: _selectedCommissionType.toUpperCase(),
        referralCode: _referralCodeController.text.trim(),
        registrationChannel: PlatformUtils.getChannel(),
        deviceId: deviceId,
      );

      if (mounted) {
        widget.onRegistrationComplete();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e is Exception
              ? e.toString().replaceFirst('Exception: ', '')
              : 'Registration failed. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: Spacing.lg,
        right: Spacing.lg,
        top: Spacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + Spacing.lg,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: Spacing.lg),
            Text(
              LocalizationService.t(context, 'affiliate.modalTitle'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              LocalizationService.t(context, 'affiliate.modalSubtitle'),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: Spacing.lg),
            Text(
              LocalizationService.t(context, 'affiliate.commissionType'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Row(
              children: <Widget>[
                _buildCommissionOption(
                  'Percentage',
                  LocalizationService.t(context, 'affiliate.percentage'),
                ),
                const SizedBox(width: Spacing.md),
                _buildCommissionOption(
                  'Fixed',
                  LocalizationService.t(context, 'affiliate.fixed'),
                ),
              ],
            ),
            const SizedBox(height: Spacing.lg),
            Text(
              LocalizationService.t(context, 'affiliate.referralCode'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            TextField(
              controller: _referralCodeController,
              decoration: InputDecoration(
                hintText: LocalizationService.t(
                  context,
                  'affiliate.referralCodeHint',
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.md,
                ),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: Spacing.sm),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ],
            const SizedBox(height: Spacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isLoading ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        LocalizationService.t(
                          context,
                          'affiliate.registerButton',
                        ),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommissionOption(String type, String displayLabel) {
    final isSelected = _selectedCommissionType == type;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedCommissionType = type;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: Spacing.md,
            horizontal: Spacing.sm,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.1)
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              displayLabel,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : Colors.grey[700],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
