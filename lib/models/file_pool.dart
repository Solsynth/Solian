class FilePool {
  final String id;
  final String name;
  final String? description;
  final Map<String, dynamic> storageConfig;
  final Map<String, dynamic> billingConfig;
  final Map<String, dynamic> policyConfig;
  final bool isHidden;

  FilePool({
    required this.id,
    required this.name,
    this.description,
    required this.storageConfig,
    required this.billingConfig,
    required this.policyConfig,
    required this.isHidden,
  });

  factory FilePool.fromJson(Map<String, dynamic> json) {
    return FilePool(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      storageConfig: json['storage_config'] as Map<String, dynamic>,
      billingConfig: json['billing_config'] as Map<String, dynamic>,
      policyConfig: json['policy_config'] as Map<String, dynamic>,
      isHidden: json['is_hidden'] as bool,
    );
  }

  static List<FilePool> listFromResponse(dynamic data) {
    final parsed = data as List<dynamic>;
    return parsed.map((e) => FilePool.fromJson(e)).toList();
  }
}
