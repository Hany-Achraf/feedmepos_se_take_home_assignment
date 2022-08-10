import 'dart:async';

class Bot {
  int id;
  bool isBusy = false;
  Timer? _timer;

  Bot({required this.id});

  void processOrder(Function callback) =>
      _timer = Timer(const Duration(seconds: 10), () => callback());

  void stopProcessingOrder() => _timer?.cancel();
}
