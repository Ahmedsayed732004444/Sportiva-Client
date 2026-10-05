import 'package:flutter/material.dart';

IconData notificationIcon(String type) {
  if (type.startsWith('Tournament')) return Icons.emoji_events_outlined;
  if (type.startsWith('Match')) return Icons.sports_soccer_outlined;
  if (type.contains('Booking')) return Icons.event_available_outlined;
  if (type.startsWith('Payment') || type.startsWith('Subscription')) return Icons.payments_outlined;
  if (type.startsWith('Membership') || type == 'StaffAdded') return Icons.storefront_outlined;
  if (type == 'NewMessage') return Icons.chat_bubble_outline;
  if (type == 'NewFollower') return Icons.person_add_alt_outlined;
  if (type.startsWith('Post') || type.startsWith('Comment')) return Icons.favorite_border;
  if (type == 'SecurityAlert' || type.startsWith('Account')) return Icons.shield_outlined;
  if (type == 'ReviewRequested') return Icons.star_border;
  return Icons.notifications_none;
}
