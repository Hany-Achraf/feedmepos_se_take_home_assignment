import 'package:async/async.dart';

class Bot {
  CancelableOperation? _cancelableProcessOrder;

  void processOrder(Function callback) {
    _cancelableProcessOrder = CancelableOperation.fromFuture(
        Future.delayed(const Duration(seconds: 10)));

    _cancelableProcessOrder?.then((_) => callback());
  }

  void stopProcessingOrder(Function callback) =>
      _cancelableProcessOrder?.cancel().then((_) => callback());
}
