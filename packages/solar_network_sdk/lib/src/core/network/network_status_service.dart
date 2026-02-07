enum NetworkStatus { online, notReady, maintenance, offline }

class NetworkStatusService {
  NetworkStatus _status = NetworkStatus.online;

  NetworkStatus get currentStatus => _status;

  void setOnline() => _status = NetworkStatus.online;
  void setMaintenance() => _status = NetworkStatus.maintenance;
  void setNotReady() => _status = NetworkStatus.notReady;
  void setOffline() => _status = NetworkStatus.offline;
}
