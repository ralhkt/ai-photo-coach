/// Whether live scene analysis should yield to camera / UI activity.
bool isLiveSceneCameraBusy({
  required bool bursting,
  required bool timerActive,
  required bool capturing,
  required bool switching,
  required bool uiInteractionPaused,
  required bool manual,
}) {
  if (bursting || timerActive || capturing || switching) {
    return true;
  }
  if (!manual && uiInteractionPaused) {
    return true;
  }
  return false;
}