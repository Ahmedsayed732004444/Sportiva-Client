import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/location/location_controller.dart';
import '../../core/location/location_service.dart';
import '../../core/localization/l10n_extension.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/submit_mixin.dart';

// Shown once, before the home: asks for the location so the home can show what is nearest.
class LocationGateScreen extends ConsumerStatefulWidget {
  const LocationGateScreen({super.key});

  @override
  ConsumerState<LocationGateScreen> createState() => _LocationGateScreenState();
}

class _LocationGateScreenState extends ConsumerState<LocationGateScreen> with SubmitMixin {
  Future<void> _allow() async {
    await submit(ref.read(locationProvider.notifier).allow);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final access = ref.watch(locationProvider).valueOrNull?.access ?? LocationAccess.denied;

    final (message, actionLabel) = switch (access) {
      LocationAccess.deniedForever => (l10n.locationDeniedForever, l10n.openSettings),
      LocationAccess.serviceOff => (l10n.locationServiceOff, l10n.turnOnLocation),
      _ => (l10n.locationBody, l10n.allowLocation),
    };

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Container(
                width: 120,
                height: 120,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.location_on_outlined, size: 64, color: AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.l),
              Text(l10n.locationTitle, textAlign: TextAlign.center, style: AppTextStyles.header),
              const SizedBox(height: AppSpacing.s),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.paragraph.copyWith(color: AppColors.black600),
              ),
              const Spacer(),
              AppButton(label: actionLabel, onPressed: _allow, isLoading: isSubmitting),
              const SizedBox(height: AppSpacing.xs),
              TextButton(
                onPressed: ref.read(locationProvider.notifier).skip,
                child: Text(l10n.notNow, style: AppTextStyles.body1.copyWith(color: AppColors.black600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
