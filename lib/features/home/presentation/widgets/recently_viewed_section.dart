import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/features/home/bloc/recently_viewed_bloc.dart';
import 'package:commercepal/features/home/presentation/widgets/home_product_rows.dart';
import 'package:commercepal/features/home/presentation/widgets/home_section_header.dart';
import 'package:commercepal/services/localization_service.dart';

/// "Recently viewed" row. Hidden entirely until there is something to show,
/// so first-time shoppers don't see an empty section.
class RecentlyViewedSection extends StatelessWidget {
  const RecentlyViewedSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecentlyViewedBloc, RecentlyViewedState>(
      builder: (context, state) {
        if (state is! RecentlyViewedLoaded || state.products.isEmpty) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: Spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                child: HomeSectionHeader(
                  title: context.tr('home.recentlyViewed.title'),
                ),
              ),
              const SizedBox(height: Spacing.xs),
              HomeProductRow(
                products: state.products,
                // Below the fold: load after discover rows.
                imagePriorityBase: 1000,
              ),
            ],
          ),
        );
      },
    );
  }
}
