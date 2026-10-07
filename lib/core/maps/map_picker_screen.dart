import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../localization/l10n_extension.dart';
import '../location/location_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import 'places_service.dart';

class PickedLocation {
  const PickedLocation({required this.latitude, required this.longitude, this.address});

  final double latitude;
  final double longitude;
  final String? address;

  // The link the API reads the coordinates from.
  String get mapUrl => 'https://www.google.com/maps?q=${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}';

  static PickedLocation? fromMapUrl(String? url) {
    final match = RegExp(r'(-?\d{1,2}\.\d+)\s*,\s*(-?\d{1,3}\.\d+)').firstMatch(url ?? '');
    if (match == null) return null;
    return PickedLocation(latitude: double.parse(match.group(1)!), longitude: double.parse(match.group(2)!));
  }
}

// A full-screen map with a pin in the middle: search for a place or move the map, then "Use this location".
class MapPickerScreen extends ConsumerStatefulWidget {
  const MapPickerScreen({super.key, this.initial});

  final PickedLocation? initial;

  @override
  ConsumerState<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends ConsumerState<MapPickerScreen> {
  static const _cairo = LatLng(30.0444, 31.2357);

  final _places = PlacesService();
  final _query = TextEditingController();
  GoogleMapController? _map;
  late LatLng _center;
  List<PlaceHit> _hits = const [];
  bool _searching = false;
  bool _picking = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    final here = ref.read(locationProvider).valueOrNull?.position;
    _center = initial != null
        ? LatLng(initial.latitude, initial.longitude)
        : here != null
        ? LatLng(here.latitude, here.longitude)
        : _cairo;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    _map?.dispose();
    super.dispose();
  }

  void _typed(String text) {
    _debounce?.cancel();
    if (text.trim().length < 2) {
      setState(() => _hits = const []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () => _search(text));
  }

  Future<void> _search(String text) async {
    setState(() => _searching = true);
    final hits = await _places.search(text, language: Localizations.localeOf(context).languageCode);
    if (!mounted) return;
    setState(() {
      _hits = hits;
      _searching = false;
    });
    if (hits.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(context.l10n.noPlaceFound)));
    }
  }

  Future<void> _go(PlaceHit hit) async {
    FocusScope.of(context).unfocus();
    _query.text = hit.name;
    setState(() => _hits = const []);
    final target = LatLng(hit.latitude, hit.longitude);
    _center = target;
    await _map?.animateCamera(CameraUpdate.newLatLngZoom(target, 16));
  }

  Future<void> _use() async {
    setState(() => _picking = true);
    final address = await _places.addressOf(
      _center.latitude,
      _center.longitude,
      language: Localizations.localeOf(context).languageCode,
    );
    if (!mounted) return;
    Navigator.of(
      context,
    ).pop(PickedLocation(latitude: _center.latitude, longitude: _center.longitude, address: address));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pickOnMap)),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _center, zoom: widget.initial == null ? 13 : 16),
            onMapCreated: (controller) => _map = controller,
            onCameraMove: (position) => _center = position.target,
            myLocationEnabled: ref.read(locationProvider).valueOrNull?.position != null,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
          ),
          // The pin stays in the middle; the map moves under it.
          IgnorePointer(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Icon(Icons.location_on, size: 48, color: AppColors.error),
              ),
            ),
          ),
          Positioned(
            top: AppSpacing.s,
            left: AppSpacing.s,
            right: AppSpacing.s,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(28),
              color: AppColors.surface,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _query,
                    onChanged: _typed,
                    onSubmitted: _search,
                    textInputAction: TextInputAction.search,
                    style: AppTextStyles.body1,
                    decoration: InputDecoration(
                      hintText: l10n.mapSearchHint,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searching
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                            )
                          : null,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                  if (_hits.isNotEmpty)
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 280),
                      child: ListView(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        children: [
                          for (final hit in _hits)
                            ListTile(
                              leading: Icon(Icons.place_outlined, color: AppColors.primary),
                              title: Text(hit.name, style: AppTextStyles.body1Semibold),
                              subtitle: Text(
                                hit.address,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.caption,
                              ),
                              onTap: () => _go(hit),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.screenPadding,
            right: AppSpacing.screenPadding,
            bottom: AppSpacing.l,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(l10n.dragMapHint, textAlign: TextAlign.center, style: AppTextStyles.caption),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  AppButton(label: l10n.useThisLocation, icon: Icons.check, isLoading: _picking, onPressed: _use),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
