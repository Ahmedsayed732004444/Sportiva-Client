import 'package:flutter/foundation.dart';

// A dialog keeps showing its text field while it animates away, after the code that opened it has its answer:
// disposing the controller right then breaks the page ("used after being disposed"). Wait for the animation.
void disposeSoon(ChangeNotifier notifier) => Future<void>.delayed(const Duration(milliseconds: 500), notifier.dispose);
