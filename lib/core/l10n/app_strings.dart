/// User-facing copy in one place so French (or other) localization is additive.
///
/// Keep English as the default locale for the portfolio demo.
abstract final class AppStrings {
  static const appTitle = 'Wild Log';

  // Shell
  static const tabSummit = 'Summit';
  static const tabLog = 'Log';
  static const tabMap = 'Map';
  static const logADay = 'Log a day';
  static const warmingFieldKit = 'Warming up the field kit…';
  static const shellLoadErrorTitle = 'Could not open your log just now.';
  static const shellLoadErrorBody = 'Close the app and open it again.';
  static const loggedSuccess = 'Logged. Good work getting outside.';

  // Summit
  static const summitTitle = 'Summit';
  static const summitSubtitle = 'How you have been showing up outside.';
  static const dayStreak = 'Day streak';
  static const coldStreakHint =
      'No active streak — log today to start one again.';
  static String hotStreakHint(int longestDays) =>
      'On a roll. Longest run: $longestDays days.';
  static const sessionsLabel = 'Sessions';
  static const elevationLabel = 'Elevation';
  static const distanceLabel = 'Distance';
  static const unitMeters = 'm';
  static const unitKilometers = 'km';
  static const quickLog = 'Quick log';
  static const byActivity = 'By activity';
  static const chartEmpty = 'Your chart fills in as you log.';
  static const personalBests = 'Personal bests';
  static const upNext = 'Up next';
  static const summitLoadErrorTitle = 'Could not load Summit.';
  static const summitLoadErrorBody =
      'Your sessions are still on device. Tap retry.';
  static const retry = 'Retry';
  static const pullingFieldNotes = 'Pulling up your field notes…';

  // Logbook
  static const logbookTitle = 'Logbook';
  static const logbookSubtitle = 'Your days outside, in one place.';
  static const filterAll = 'All';
  static const logbookLoadErrorTitle = 'Could not load the logbook.';
  static const logbookLoadErrorBody =
      'Your notes are still on device. Tap retry.';
  static const logbookEmptyTitle = 'No sessions yet.';
  static String logbookEmptyFilterTitle(String activity) =>
      'Nothing for $activity yet.';
  static const logbookEmptyBody = 'Tap Log a day when you are back.';

  // Map
  static const mapTitle = 'Map';
  static const mapSubtitle = 'Places you pinned from the log.';
  static const mapLoadErrorTitle = 'Map could not load.';
  static const mapLoadErrorBody = 'Check the network, then tap retry.';
  static const mapEmptyPins =
      'No pins yet. Turn on Pin on the map when you log a day.';
  static String mapPinCount(int count) =>
      '$count places — tap a marker to open';
  static String mapMarkerSemantics(String activity, String title) =>
      '$activity session: $title';

  // Session form
  static const formNewTitle = 'Log a day';
  static const formEditTitle = 'Edit session';
  static const formWhatDoing = 'What were you doing?';
  static const formNameDay = 'Name this day';
  static const formNameHint = 'Optional — e.g. Morning ridge push';
  static const formNameHelper = 'Leave blank and the app will name it.';
  static const formWhen = 'When';
  static const formDuration = 'How long (minutes)';
  static const formHowHard = 'How hard was it?';
  static const formWhere = 'Where (optional)';
  static const formWhereHint = 'Trailhead, resort, range…';
  static const formNotes = 'What mattered out there?';
  static const formNotesHint = 'A sentence is enough.';
  static const formPinMap = 'Pin on the map';
  static const formPinMapSubtitle =
      'Only if you want this day on the Map tab.';
  static const formLatitude = 'Latitude';
  static const formLongitude = 'Longitude';
  static const formShowDetails = 'Add distance and details';
  static const formHideDetails = 'Hide details';
  static const formElevation = 'Elevation (m)';
  static const formDistance = 'Distance (km)';
  static const formSaveNew = 'Save to log';
  static const formSaveEdit = 'Save changes';
  static const formSaveError = 'Could not save. Try again.';
  static const formTitleNeeded =
      'Add a short name, or leave it blank for an automatic one.';
  static const formLatInvalid = 'Latitude must be between -90 and 90.';
  static const formLngInvalid = 'Longitude must be between -180 and 180.';
  static const formPinNeedsBoth =
      'Add both latitude and longitude, or turn the pin off.';
  static const formDateHelp = 'When were you out?';
  static const formTimeHelp = 'About what time?';
  static String formAutoTitle(String activity, String dateLabel) =>
      '$activity · $dateLabel';

  // Session detail
  static const sessionTitle = 'Session';
  static const sessionOpening = 'Opening that day…';
  static const sessionLoadErrorTitle = 'Could not open this session.';
  static const sessionLoadErrorBody = 'Go back and try another entry.';
  static const sessionMissingTitle = 'That session is not here anymore.';
  static const sessionMissingBody = 'It may have been deleted.';
  static const durationLabel = 'Duration';
  static const difficultyLabel = 'Difficulty';
  static const detailsLabel = 'Details';
  static const notesLabel = 'Notes';
  static const editTooltip = 'Edit';
  static const deleteTooltip = 'Delete';
  static const deleteConfirmTitle = 'Remove this day?';
  static const deleteConfirmBody =
      'It will leave the log and the map. This cannot be undone.';
  static const keepIt = 'Keep it';
  static const remove = 'Remove';
  static const removedSnack = 'Removed from the log.';
  static const updatedSnack = 'Updated.';
  static String difficultySemantics(int value) =>
      'Difficulty $value of $maxDifficultyLabel';
  static const maxDifficultyLabel = '5';

  // Shared status
  static const genericLoadErrorTitle = 'Something snagged while loading.';
  static const genericLoadErrorBody = 'Tap retry, or reopen the app.';

  // Milestones / records (domain-facing defaults)
  static const firstWaypointTitle = 'First waypoint';
  static const firstWaypointDetail =
      'The log is quiet — tap Log a day when you get back outside.';
  static String sessionsMilestoneTitle(int target) =>
      '$target days in the book';
  static String sessionsMilestoneDetail(int total) =>
      'You are at $total. The next entry still counts.';
  static const weekStreakTitle = 'A full week outside';
  static const weekStreakCold =
      'Start today — tomorrow will thank you.';
  static const weekStreakWarm = 'Solid rhythm. A few more days makes a week.';
  static const keepFireTitle = 'Keep the fire';
  static const keepFireDetail =
      'You have a real practice now. What place still intimidates you a little?';
  static const recordHighestGain = 'Highest gain';
  static const recordLongestDistance = 'Longest distance';
  static const recordHardest = 'Hardest session';
  static const recordDiffUnit = 'diff';
}
