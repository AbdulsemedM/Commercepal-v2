/// Collapses concurrent calls into a single in-flight operation.
///
/// Callers that arrive while an operation is running await that same operation
/// instead of starting their own. Used for token refresh, where a rotating
/// refresh token may only be spent once: parallel requests that each started
/// their own refresh would invalidate each other's credentials.
class SingleFlight {
  Future<void>? _inFlight;

  /// True while an operation is running.
  bool get isRunning => _inFlight != null;

  /// Runs [action], or joins the run already in progress.
  ///
  /// The slot is released once the operation settles, so a later call starts a
  /// fresh run. Failures propagate to every joined caller.
  Future<void> run(Future<void> Function() action) {
    return _inFlight ??= action().whenComplete(() {
      _inFlight = null;
    });
  }
}
