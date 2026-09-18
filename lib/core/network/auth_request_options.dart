/// When true on [RequestOptions.extra], [AuthInterceptor] attaches `X-Session-Id`
/// even if an access token is present (e.g. POST /api/cart/merge).
const String kIncludeGuestSessionExtra = 'includeGuestSession';

/// When true, [AuthInterceptor] omits Bearer auth and uses guest session only
/// (e.g. cart add fallback after a rejected access token).
const String kForceGuestSessionExtra = 'forceGuestSession';

/// Returns whether `X-Session-Id` should be sent on a request.
///
/// Matches commercepal.com web cart headers: authenticated cart calls use Bearer
/// auth only; guest session id is added for guests or explicit merge flows.
bool shouldAttachGuestSessionId({
  required bool hasAccessToken,
  required bool includeGuestSession,
  bool forceGuestSession = false,
}) {
  if (forceGuestSession) return true;
  return !hasAccessToken || includeGuestSession;
}
