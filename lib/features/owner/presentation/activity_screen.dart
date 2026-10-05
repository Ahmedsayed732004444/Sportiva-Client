import 'package:flutter/material.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../../core/localization/relative_time.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/paged_list_view.dart';
import '../application/owner_controllers.dart';
import '../data/owner_club_models.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.activityLog)),
      body: PagedListView<ActivityEntry>(
        state: activityProvider,
        actions: activityProvider.notifier,
        emptyMessage: l10n.noActivity,
        emptyIcon: Icons.history,
        itemBuilder: (context, entry) => ListTile(
          title: Text('${entry.action} · ${entry.entityType}', style: AppTextStyles.body1Semibold),
          subtitle: Text([entry.userName, if (entry.details != null) entry.details!].join(' · ')),
          trailing: Text(relativeTime(l10n, entry.createdAt), style: AppTextStyles.caption),
        ),
      ),
    );
  }
}
