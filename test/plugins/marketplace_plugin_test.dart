import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:island/plugins/models/marketplace_plugin.dart';

const String _sample = '''
{
  "id": "4edb95d5-4948-4c8c-b343-c1760f49a961",
  "slug": "KeiPush",
  "plugin_id": "com.kaisar.keipush",
  "name": "KeiPush",
  "version": "1.2",
  "author": "龙渊不吃鱼",
  "description": "快速注册KeiPush推送服务",
  "entry_url": "",
  "icon": null,
  "background": null,
  "homepage": "",
  "package_url": "https://ma.solian.app/4edb95d5-4948-4c8c-b343-c1760f49a961/92ea36aa7cd346a296b025767f6199fd.zip",
  "package_storage_key": "4edb95d5-4948-4c8c-b343-c1760f49a961/92ea36aa7cd346a296b025767f6199fd.zip",
  "package_sha256": "55de75427d56482b6620aaa03c2f76a4d4273c94eb0793bfc5b625343deac96c",
  "package_size": 1982,
  "download_count": 0,
  "stage": 2,
  "manifest": {
    "id": "com.kaisar.keipush",
    "name": "KeiPush",
    "version": "1.2",
    "author": "CNlongY",
    "description": "快速注册KeiPush推送服务",
    "entry": "main.js",
    "permissions": ["solarNetworkApi", "networkInternet", "notify"],
    "background": false,
    "icon": "",
    "homepage": "",
    "entry_url": null
  },
  "project_id": "36b88c6e-9b01-4b0f-8e34-f91151204dad",
  "project": {
    "id": "36b88c6e-9b01-4b0f-8e34-f91151204dad",
    "slug": "Akatsuki",
    "name": "Akatsuki",
    "description": "萝卜子Akatsuki",
    "developer": {
      "id": "8a416168-5a2a-4a6f-a298-a4f8a54f7b38",
      "publisher_id": "e9eef3aa-6c60-4b52-b808-08178ef0c963",
      "publisher": {
        "id": "e9eef3aa-6c60-4b52-b808-08178ef0c963",
        "type": 0,
        "name": "CNlongY",
        "nick": "龙渊不吃鱼",
        "bio": "一切奇迹的起点",
        "picture": {
          "id": "25a3248b43d3412783ca5fdf640ecc36",
          "name": "1757213622575.gif",
          "mime_type": "image/gif",
          "status": 0,
          "url": null
        },
        "background": null,
        "verification": null,
        "meta": null,
        "account_id": "8792577d-407a-44f7-9720-8bad7efdc7a2",
        "account": null,
        "rating": 642,
        "rating_level": 2
      }
    }
  },
  "developer_id": "8a416168-5a2a-4a6f-a298-a4f8a54f7b38",
  "developer": {
    "id": "8a416168-5a2a-4a6f-a298-a4f8a54f7b38",
    "publisher_id": "e9eef3aa-6c60-4b52-b808-08178ef0c963",
    "publisher": {
      "id": "e9eef3aa-6c60-4b52-b808-08178ef0c963",
      "type": 0,
      "name": "CNlongY",
      "nick": "龙渊不吃鱼",
      "bio": "一切奇迹的起点",
      "picture": {
        "id": "25a3248b43d3412783ca5fdf640ecc36",
        "name": "1757213622575.gif",
        "mime_type": "image/gif",
        "status": 0,
        "url": null
      },
      "background": null,
      "verification": null,
      "meta": null,
      "account_id": "8792577d-407a-44f7-9720-8bad7efdc7a2",
      "account": null,
      "rating": 642,
      "rating_level": 2
    }
  }
}
''';

Map<String, dynamic> _parse() =>
    jsonDecode(_sample) as Map<String, dynamic>;

void main() {
  group('MarketplacePlugin full developer info', () {
    test('parses developer, publisher, avatar and verification', () {
      final plugin = MarketplacePlugin.fromJson(_parse());

      expect(plugin.id, '4edb95d5-4948-4c8c-b343-c1760f49a961');
      expect(plugin.pluginId, 'com.kaisar.keipush');
      expect(plugin.developerId, '8a416168-5a2a-4a6f-a298-a4f8a54f7b38');
      expect(plugin.publisherId, 'e9eef3aa-6c60-4b52-b808-08178ef0c963');
      expect(plugin.downloadCount, 0);

      final developer = plugin.developer;
      expect(developer, isNotNull);
      expect(developer!.id, '8a416168-5a2a-4a6f-a298-a4f8a54f7b38');
      expect(developer.publisherId, 'e9eef3aa-6c60-4b52-b808-08178ef0c963');

      final publisher = plugin.publisher;
      expect(publisher, isNotNull);
      expect(publisher!.nick, '龙渊不吃鱼');
      expect(publisher.name, 'CNlongY');
      expect(publisher.picture?.id, '25a3248b43d3412783ca5fdf640ecc36');
      expect(publisher.verification, isNull);

      // Avatar surface for the UI.
      expect(plugin.developerPicture?.id, '25a3248b43d3412783ca5fdf640ecc36');

      // AccountName view synthesizes from publisher when account is absent.
      final account = plugin.developerAccount;
      expect(account, isNotNull);
      expect(account!.nick, '龙渊不吃鱼');
      expect(account.name, 'CNlongY');
      expect(account.id, '8792577d-407a-44f7-9720-8bad7efdc7a2');
      expect(account.profile.picture?.id, '25a3248b43d3412783ca5fdf640ecc36');
      expect(account.profile.verification, isNull);
    });

    test('passes verification mark through to the account view', () {
      final json = _parse();
      final publisher = (json['developer'] as Map<String, dynamic>)['publisher']
          as Map<String, dynamic>;
      publisher['verification'] = {
        'type': 1,
        'title': 'Official developer',
        'description': 'Verified publisher',
        'verified_by': 'Solarian',
      };

      final plugin = MarketplacePlugin.fromJson(json);
      expect(plugin.publisher!.verification?.type, 1);
      expect(
        plugin.developerAccount!.profile.verification?.title,
        'Official developer',
      );
    });

    test('falls back to project.developer.publisher', () {
      final json = _parse()..remove('developer');

      final plugin = MarketplacePlugin.fromJson(json);
      expect(plugin.developer?.id, '8a416168-5a2a-4a6f-a298-a4f8a54f7b38');
      expect(plugin.publisher?.nick, '龙渊不吃鱼');
      expect(plugin.developerPicture?.id, '25a3248b43d3412783ca5fdf640ecc36');
      expect(plugin.developerAccount, isNotNull);
    });

    test('stays null-safe when developer info is absent', () {
      final json = _parse()
        ..remove('developer')
        ..remove('developer_id')
        ..remove('project')
        ..remove('author');
      (json['manifest'] as Map<String, dynamic>)['author'] = 'Legacy Author';

      final plugin = MarketplacePlugin.fromJson(json);
      expect(plugin.developer, isNull);
      expect(plugin.developerId, isNull);
      expect(plugin.publisher, isNull);
      expect(plugin.developerAccount, isNull);
      expect(plugin.developerPicture, isNull);
      expect(plugin.displayAuthor, 'Legacy Author');
    });
  });
}
