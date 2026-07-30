import 'dart:async';

import 'package:flutter/scheduler.dart';

/// Waits until the current frame has finished painting and disposing routes.
///
/// Use after [Navigator.pop] from a dialog so callers do not rebuild the tree
/// while the dialog route is still tearing down its inherited dependencies.
Future<void> waitForNextFrame() {
  final completer = Completer<void>();
  SchedulerBinding.instance.addPostFrameCallback((_) {
    if (!completer.isCompleted) completer.complete();
  });
  return completer.future;
}
