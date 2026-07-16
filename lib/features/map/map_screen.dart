import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants/app_constants.dart';
import '../../core/layout/wild_space.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/wild_colors.dart';
import '../../domain/session.dart';
import '../../providers/providers.dart';
import '../session/session_detail_screen.dart';
import '../shared/wild_widgets.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  static final _defaultCenter = LatLng(
    AppConstants.defaultMapLatitudeDegrees,
    AppConstants.defaultMapLongitudeDegrees,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionsProvider);

    return ColoredBox(
      color: WildColors.voidBlack,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WildHeader(
              title: AppStrings.mapTitle,
              subtitle: AppStrings.mapSubtitle,
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                child: sessionsAsync.when(
                  loading: () => const WildLoading(key: ValueKey('loading')),
                  error: (error, stack) => WildStatusMessage(
                    key: const ValueKey('error'),
                    title: AppStrings.mapLoadErrorTitle,
                    body: AppStrings.mapLoadErrorBody,
                    actionLabel: AppStrings.retry,
                    onAction: () => ref.invalidate(sessionsProvider),
                  ),
                  data: (sessions) {
                    final pinned = sessions
                        .where((s) => s.hasMapPin)
                        .toList(growable: false);
                    final center = pinned.isNotEmpty
                        ? LatLng(pinned.first.latitude!, pinned.first.longitude!)
                        : _defaultCenter;

                    return Padding(
                      key: ValueKey('map-${pinned.length}'),
                      padding: const EdgeInsets.fromLTRB(
                        WildSpace.sm,
                        0,
                        WildSpace.sm,
                        WildSpace.scrollBottom,
                      ),
                      child: ClipRect(
                        child: Stack(
                          children: [
                            FlutterMap(
                              options: MapOptions(
                                initialCenter: center,
                                initialZoom: AppConstants.defaultMapZoom,
                                interactionOptions: const InteractionOptions(
                                  flags: InteractiveFlag.all &
                                      ~InteractiveFlag.rotate,
                                ),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      AppConstants.osmTileUrlTemplate,
                                  userAgentPackageName:
                                      AppConstants.osmUserAgentPackageName,
                                  tileBuilder: (context, tileWidget, tile) {
                                    return ColorFiltered(
                                      colorFilter: const ColorFilter.matrix(
                                        <double>[
                                          0.7, 0, 0, 0, 0,
                                          0, 0.85, 0, 0, 0,
                                          0, 0, 0.75, 0, 0,
                                          0, 0, 0, 1, 0,
                                        ],
                                      ),
                                      child: tileWidget,
                                    );
                                  },
                                ),
                                MarkerLayer(
                                  markers: [
                                    for (final s in pinned)
                                      Marker(
                                        point: LatLng(
                                          s.latitude!,
                                          s.longitude!,
                                        ),
                                        width: AppConstants.mapMarkerSizePx,
                                        height: AppConstants.mapMarkerSizePx,
                                        child: _ActivityMarker(
                                          session: s,
                                          onTap: () => Navigator.of(context)
                                              .push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  SessionDetailScreen(
                                                sessionId: s.id,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            Positioned(
                              left: WildSpace.sm,
                              right: WildSpace.sm,
                              bottom: WildSpace.sm,
                              child: FieldPanel(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: WildSpace.sm,
                                  vertical: WildSpace.sm,
                                ),
                                child: Text(
                                  pinned.isEmpty
                                      ? AppStrings.mapEmptyPins
                                      : AppStrings.mapPinCount(pinned.length),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityMarker extends StatelessWidget {
  const _ActivityMarker({required this.session, required this.onTap});

  final AdventureSession session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final type = session.activityType;
    return Semantics(
      button: true,
      label: AppStrings.mapMarkerSemantics(type.label, session.title),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: 1,
          duration: const Duration(milliseconds: 120),
          child: Container(
            decoration: BoxDecoration(
              color: WildColors.charcoal.withValues(alpha: 0.92),
              border: Border.all(color: type.color, width: 2),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: type.color.withValues(alpha: 0.35),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(type.icon, size: 20, color: type.color),
          ),
        ),
      ),
    );
  }
}
