/// Small, dependency-free date-math helpers shared by the energy logic and
/// seed data. Nothing here depends on Flutter.
library;

/// Strips the time-of-day component, returning midnight on the same date.
DateTime dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

/// Whether [a] and [b] fall on the same calendar date (ignoring time).
bool isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

/// [date] shifted by [days] calendar days (negative to go backward).
DateTime addCalendarDays(DateTime date, int days) {
  return DateTime(date.year, date.month, date.day + days);
}
