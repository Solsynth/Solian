import 'package:flutter/material.dart';

class BadgeInfo {
  final String type;
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  const BadgeInfo({
    required this.type,
    required this.name,
    required this.description,
    this.icon = Icons.star,
    this.color = Colors.blue,
  });
}

const Map<String, BadgeInfo> kBadgeTemplates = {
  'achievements.post.first': BadgeInfo(
    type: 'achievements.post.first',
    name: 'firstPostBadgeName',
    description: 'firstPostBadgeDescription',
    icon: Icons.create,
    color: Colors.green,
  ),
  'achievements.post.popular': BadgeInfo(
    type: 'achievements.post.popular',
    name: 'popularPostBadgeName',
    description: 'popularPostBadgeDescription',
    icon: Icons.trending_up,
    color: Colors.orange,
  ),
  'achievements.post.viral': BadgeInfo(
    type: 'achievements.post.viral',
    name: 'viralPostBadgeName',
    description: 'viralPostBadgeDescription',
    icon: Icons.whatshot,
    color: Colors.red,
  ),
  'achievements.comment.helpful': BadgeInfo(
    type: 'achievements.comment.helpful',
    name: 'helpfulCommentBadgeName',
    description: 'helpfulCommentBadgeDescription',
    icon: Icons.thumb_up,
    color: Colors.lightBlue,
  ),
  'ranks.newcomer': BadgeInfo(
    type: 'ranks.newcomer',
    name: 'newcomerBadgeName',
    description: 'newcomerBadgeDescription',
    icon: Icons.person_outline,
    color: Colors.blue,
  ),
  'ranks.contributor': BadgeInfo(
    type: 'ranks.contributor',
    name: 'contributorBadgeName',
    description: 'contributorBadgeDescription',
    icon: Icons.stars,
    color: Colors.purple,
  ),
  'ranks.expert': BadgeInfo(
    type: 'ranks.expert',
    name: 'expertBadgeName',
    description: 'expertBadgeDescription',
    icon: Icons.workspace_premium,
    color: Colors.amber,
  ),
  'event.founder': BadgeInfo(
    type: 'event.founder',
    name: 'founderBadgeName',
    description: 'founderBadgeDescription',
    icon: Icons.foundation,
    color: Colors.deepPurple,
  ),
  'event.beta.tester': BadgeInfo(
    type: 'event.beta.tester',
    name: 'betaTesterBadgeName',
    description: 'betaTesterBadgeDescription',
    icon: Icons.bug_report,
    color: Colors.teal,
  ),
  'special.moderator': BadgeInfo(
    type: 'special.moderator',
    name: 'moderatorBadgeName',
    description: 'moderatorBadgeDescription',
    icon: Icons.construction,
    color: Colors.indigo,
  ),
  'special.developer': BadgeInfo(
    type: 'special.developer',
    name: 'developerBadgeName',
    description: 'developerBadgeDescription',
    icon: Icons.code,
    color: Colors.indigo,
  ),
  'special.translator': BadgeInfo(
    type: 'special.translator',
    name: 'translatorBadgeName',
    description: 'translatorBadgeDescription',
    icon: Icons.code,
    color: Colors.grey,
  ),
};
