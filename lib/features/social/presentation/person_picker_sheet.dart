import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/user_avatar.dart';
import '../data/social_models.dart';
import '../data/social_repository.dart';

typedef PickedPerson = ({Person person, bool isSubstitute});

// A sheet to search for a player and pick one. With [askSubstitute] it also asks whether they come as a substitute.
Future<PickedPerson?> showPersonPicker(BuildContext context, {bool askSubstitute = false}) =>
    showModalBottomSheet<PickedPerson>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _PersonPicker(askSubstitute: askSubstitute),
    );

class _PersonPicker extends ConsumerStatefulWidget {
  const _PersonPicker({required this.askSubstitute});

  final bool askSubstitute;

  @override
  ConsumerState<_PersonPicker> createState() => _PersonPickerState();
}

class _PersonPickerState extends ConsumerState<_PersonPicker> {
  Timer? _debounce;
  List<Person> _results = const [];
  bool _loading = false;
  bool _substitute = false;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String text) {
    _debounce?.cancel();
    if (text.trim().length < 2) {
      setState(() => _results = const []);
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      setState(() => _loading = true);
      try {
        final found = await ref.read(socialRepositoryProvider).search(text.trim());
        if (mounted) setState(() => _results = found.users);
      } on ApiException {
        if (mounted) setState(() => _results = const []);
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.6,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
              child: TextField(
                autofocus: true,
                onChanged: _onChanged,
                decoration: InputDecoration(hintText: l10n.searchPlayers, prefixIcon: const Icon(Icons.search)),
              ),
            ),
            if (widget.askSubstitute)
              SwitchListTile(
                title: Text(l10n.inviteAsSubstitute),
                value: _substitute,
                onChanged: (value) => setState(() => _substitute = value),
              ),
            if (_loading) const LinearProgressIndicator(),
            Expanded(
              child: ListView(
                children: [
                  for (final person in _results)
                    ListTile(
                      leading: UserAvatar(name: person.fullName, url: person.avatarUrl),
                      title: Text(person.fullName),
                      onTap: () => Navigator.pop<PickedPerson>(context, (person: person, isSubstitute: _substitute)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
