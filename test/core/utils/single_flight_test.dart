import 'dart:async';

import 'package:commercepal/core/utils/single_flight.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SingleFlight', () {
    test('parallel callers share one run', () async {
      final flight = SingleFlight();
      final gate = Completer<void>();
      var runs = 0;

      final futures = List<Future<void>>.generate(
        15,
        (_) => flight.run(() async {
          runs++;
          await gate.future;
        }),
      );

      expect(runs, 1, reason: 'a rotating refresh token may only be spent once');

      gate.complete();
      await Future.wait(futures);

      expect(runs, 1);
    });

    test('a later call starts a fresh run', () async {
      final flight = SingleFlight();
      var runs = 0;

      await flight.run(() async => runs++);
      await flight.run(() async => runs++);

      expect(runs, 2);
      expect(flight.isRunning, isFalse);
    });

    test('every joined caller sees the failure', () async {
      final flight = SingleFlight();
      final gate = Completer<void>();
      var runs = 0;

      final futures = List<Future<void>>.generate(
        3,
        (_) => flight.run(() async {
          runs++;
          await gate.future;
          throw StateError('refresh rejected');
        }),
      );

      gate.complete();

      for (final future in futures) {
        await expectLater(future, throwsStateError);
      }
      expect(runs, 1);
    });

    test('releases the slot after a failure', () async {
      final flight = SingleFlight();

      await expectLater(
        flight.run(() async => throw StateError('boom')),
        throwsStateError,
      );

      expect(flight.isRunning, isFalse);
      await flight.run(() async {});
    });
  });
}
