// Copyright (c) Solsynth
// Sensitive content categories for content warnings, in fixed order.

enum SensitiveCategory {
  language,
  sexualContent,
  violence,
  profanity,
  hateSpeech,
  racism,
  adultContent,
  drugAbuse,
  alcoholAbuse,
  gambling,
  selfHarm,
  childAbuse,
  other,
}

extension SensitiveCategoryI18n on SensitiveCategory {
  /// i18n key to look up localized label
  String get i18nKey => switch (this) {
    SensitiveCategory.language => 'sensitiveCategories.language',
    SensitiveCategory.sexualContent => 'sensitiveCategories.sexualContent',
    SensitiveCategory.violence => 'sensitiveCategories.violence',
    SensitiveCategory.profanity => 'sensitiveCategories.profanity',
    SensitiveCategory.hateSpeech => 'sensitiveCategories.hateSpeech',
    SensitiveCategory.racism => 'sensitiveCategories.racism',
    SensitiveCategory.adultContent => 'sensitiveCategories.adultContent',
    SensitiveCategory.drugAbuse => 'sensitiveCategories.drugAbuse',
    SensitiveCategory.alcoholAbuse => 'sensitiveCategories.alcoholAbuse',
    SensitiveCategory.gambling => 'sensitiveCategories.gambling',
    SensitiveCategory.selfHarm => 'sensitiveCategories.selfHarm',
    SensitiveCategory.childAbuse => 'sensitiveCategories.childAbuse',
    SensitiveCategory.other => 'sensitiveCategories.other',
  };

  /// Optional symbol you can use alongside the label in UI
  String get symbol => switch (this) {
    SensitiveCategory.language => '🌐',
    SensitiveCategory.sexualContent => '🔞',
    SensitiveCategory.violence => '⚠️',
    SensitiveCategory.profanity => '🗯️',
    SensitiveCategory.hateSpeech => '🚫',
    SensitiveCategory.racism => '✋',
    SensitiveCategory.adultContent => '🍑',
    SensitiveCategory.drugAbuse => '💊',
    SensitiveCategory.alcoholAbuse => '🍺',
    SensitiveCategory.gambling => '🎲',
    SensitiveCategory.selfHarm => '🆘',
    SensitiveCategory.childAbuse => '🛑',
    SensitiveCategory.other => '❗',
  };
}

/// Ordered list for UI consumption, matching enum declaration order.
const List<SensitiveCategory> kSensitiveCategoriesOrdered = [
  SensitiveCategory.language,
  SensitiveCategory.sexualContent,
  SensitiveCategory.violence,
  SensitiveCategory.profanity,
  SensitiveCategory.hateSpeech,
  SensitiveCategory.racism,
  SensitiveCategory.adultContent,
  SensitiveCategory.drugAbuse,
  SensitiveCategory.alcoholAbuse,
  SensitiveCategory.gambling,
  SensitiveCategory.selfHarm,
  SensitiveCategory.childAbuse,
  SensitiveCategory.other,
];
