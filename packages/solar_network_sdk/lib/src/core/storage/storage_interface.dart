abstract class StorageInterface {
  dynamic get(String key);
  Future<bool> set(String key, dynamic value);
  Future<bool> remove(String key);
  Set<String> getKeys();
}
