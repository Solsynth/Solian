// Copyright (c) Solsynth
// Coarse content marks for warnings (sensitive, spoiler, etc.).
//
// Indices are client-defined and stored as ints on the server.
// **Never reorder or insert into the middle of this enum** — only append.

import 'package:easy_localization/easy_localization.dart';

/// Broad content marks. Enum index is the persisted mark value.
///
/// Intentionally coarse — for spoilers, CW, NSFW, and similar flags,
/// not fine-grained taxonomy.
enum SensitiveCategory {
  nsfw, // 0 — mature / sexual / nudity
  violence, // 1 — violence / gore / weapons
  language, // 2 — strong language
  spoiler, // 3 — plot spoilers
  flashing, // 4 — flashing lights / seizure risk
  hate, // 5 — hate / discrimination
  substances, // 6 — drugs / alcohol / smoking / gambling
  sensitive, // 7 — other sensitive topics (mental health, politics, …)
  other, // 8
}

extension SensitiveCategoryI18n on SensitiveCategory {
  String get i18nKey => 'sensitiveCategories.$name';

  String get symbol => switch (this) {
    SensitiveCategory.nsfw => '🔞',
    SensitiveCategory.violence => '⚠️',
    SensitiveCategory.language => '💬',
    SensitiveCategory.spoiler => '🙈',
    SensitiveCategory.flashing => '⚡',
    SensitiveCategory.hate => '🚫',
    SensitiveCategory.substances => '💊',
    SensitiveCategory.sensitive => '👁️',
    SensitiveCategory.other => '❗',
  };
}

/// All marks in declaration (index) order.
const List<SensitiveCategory> kSensitiveCategoriesOrdered =
    SensitiveCategory.values;

/// Safe label for a stored mark index (unknown → Other).
String sensitiveCategoryLabel(int index) {
  if (index < 0 || index >= SensitiveCategory.values.length) {
    return SensitiveCategory.other.i18nKey.tr();
  }
  return SensitiveCategory.values[index].i18nKey.tr();
}

/// Safe symbol for a stored mark index.
String sensitiveCategorySymbol(int index) {
  if (index < 0 || index >= SensitiveCategory.values.length) {
    return SensitiveCategory.other.symbol;
  }
  return SensitiveCategory.values[index].symbol;
}
