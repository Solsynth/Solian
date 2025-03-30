class ReactInfo {
  final String icon;
  final int attitude;

  const ReactInfo({required this.icon, required this.attitude});
}

const Map<String, ReactInfo> kTemplateReactions = {
  'thumb_up': ReactInfo(icon: '👍', attitude: 1),
  'thumb_down': ReactInfo(icon: '👎', attitude: 2),
  'just_okay': ReactInfo(icon: '😅', attitude: 0),
  'cry': ReactInfo(icon: '😭', attitude: 0),
  'confuse': ReactInfo(icon: '🧐', attitude: 0),
  'clap': ReactInfo(icon: '👏', attitude: 1),
  'laugh': ReactInfo(icon: '😂', attitude: 1),
  'angry': ReactInfo(icon: '😡', attitude: 2),
  'party': ReactInfo(icon: '🎉', attitude: 1),
  'joy': ReactInfo(icon: '🤣', attitude: 1),
  'pray': ReactInfo(icon: '🙏', attitude: 1),
  'heart': ReactInfo(icon: '❤️', attitude: 1),
};
