import 'package:flutter/material.dart';
import 'package:feedmepos_se_take_home_assignment/models/bot.dart';
import 'package:feedmepos_se_take_home_assignment/models/order.dart';

class OrdersBotsManager extends ChangeNotifier {
  // Number of all orders, it's used to give incremental id to new orders.
  int _numOfOrders = 0;

  // Queues to store pending vip & normal orders, however pushing in front
  // is allowed to re-insert an order that is currently being processed by
  // a bot when it's shut down by the manager.
  final List<Order> _pendingVipOrders = [];
  final List<Order> _pendingNormalOrders = [];

  // Queue to store orders being processed, however removing the newest order is
  // allowed to handle the case when a bot is shut down while processing an order.
  final List<Order> _processingOrders = [];

  // List to store all completed orders.
  final List<Order> _completedOrders = [];

  // List of orders to be presented on the UI.
  List<Order> get allOrders => [
        ..._processingOrders,
        ..._pendingVipOrders,
        ..._pendingNormalOrders,
        ..._completedOrders
      ];

  void makeOrder({bool isVip = false}) {
    final Order newOrder = Order(id: _numOfOrders++, isVip: isVip);

    if (newOrder.isVip) {
      _pendingVipOrders.add(newOrder);
    } else {
      _pendingNormalOrders.add(newOrder);
    }

    // Update the UI the new added order.
    notifyListeners();

    // Trigger the function responsible for processing orders when a new order is made.
    processOrders();
  }

  // Stack to store all bots in the system.
  final List<Bot> _bots = [];

  // Total number of running bots.
  int get numOfBots => _bots.length;

  // Total number of bots that process orders.
  int get numOfBusyBots => _processingOrders.length;

  void addBot() {
    _bots.add(Bot());
    notifyListeners();

    // Trigger the function responsible for processing orders when a new bot is added.
    processOrders();
  }

  void removeBot() {
    // Don't operate when there's no any bots.
    if (numOfBots <= 0) return;

    // Handling the case when the bot being removed, is processing an order.
    if (numOfBots == numOfBusyBots) {
      // Fetch & remove the newest order in the _processingOrders queue.
      final Order newestProcessingOrder = _processingOrders.removeLast();

      // Command the bot to be removed from the queue to stop processing, then
      // re-push (in front) the the order into the respective pending queue.
      _bots.last.stopProcessingOrder(() {
        newestProcessingOrder.status = Status.PENDING;
        if (newestProcessingOrder.isVip) {
          _pendingVipOrders.insert(0, newestProcessingOrder);
        } else {
          _pendingNormalOrders.insert(0, newestProcessingOrder);
        }
      });
    }

    // Pop the last bot in the bots stack.
    _bots.removeLast();

    notifyListeners();
  }

  void processOrders() {
    // Keep iterating over the pending queues as long as they aren't empty.
    while (_pendingVipOrders.isNotEmpty || _pendingNormalOrders.isNotEmpty) {
      // Don't operate when all bots are busy.
      if (numOfBots == numOfBusyBots) return;

      // Pop an order from the pending queues, considering the priorities.
      Order poppedOrder = _pendingVipOrders.isNotEmpty
          ? _pendingVipOrders.removeAt(0)
          : _pendingNormalOrders.removeAt(0);

      // Push the popped order to the _processingOrders queue.
      poppedOrder.status = Status.PROCESSING;
      _processingOrders.add(poppedOrder);

      notifyListeners();

      // Command the first free bot in the bots queue to process the popped order.
      // Notably, the callback function will be executed only if the processing wasn't stopped.
      _bots[numOfBusyBots - 1].processOrder(() {
        // Remove the oldest/completed the order from the _processingOrders queue.
        // And add that completed order to the completed orders list after changing its status.
        _processingOrders.removeAt(0);
        poppedOrder.status = Status.COMPLETE;
        _completedOrders.insert(0, poppedOrder);
        notifyListeners();

        // Trigger the function responsible for processing orders when an order is completed.
        processOrders();
      });
    }
  }
}
