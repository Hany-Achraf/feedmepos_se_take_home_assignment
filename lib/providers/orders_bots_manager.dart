import 'package:flutter/material.dart';
import 'package:feedmepos_se_take_home_assignment/models/bot.dart';
import 'package:feedmepos_se_take_home_assignment/models/order.dart';

class OrdersBotsManager extends ChangeNotifier {
  // Total number of all orders, it's used to give incremental id to new orders.
  int _numOfOrders = 0;

  // Queues to store pending vip & normal orders, however random insertion
  // is allowed to re-insert an order that is currently being processed by
  // a bot when it's shut down by the manager.
  final List<Order> _pendingVipOrders = [];
  final List<Order> _pendingNormalOrders = [];

  // List to store orders that are processed
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

  int get numOfBots => _bots.length;

  // Total number of bots that process orders.
  int get numOfBusyBots => _bots.where((bot) => bot.isBusy).length;

  void addBot() {
    _bots.add(Bot(id: _bots.length));
    notifyListeners();

    // Trigger the function responsible for processing orders when a new bot is added.
    processOrders();
  }

  void removeBot() {
    if (_bots.isEmpty) return;

    // Handling the case when the bot being removed, is processing an order.
    if (_bots.last.isBusy) {
      // lookup the order that is currently processed by last added bot
      final Order orderToCancel = _processingOrders
          .firstWhere((order) => order.processingBotId == _bots.last.id);

      // change order's state, remove it from _processingOrders list, & re-insert into pending Q.
      orderToCancel.status = Status.PENDING;
      orderToCancel.processingBotId = null;
      _processingOrders.removeWhere((order) => order.processingBotId == null);

      if (orderToCancel.isVip) {
        if (_pendingVipOrders.isEmpty ||
            _pendingVipOrders.last.id < orderToCancel.id) {
          _pendingVipOrders.add(orderToCancel);
        } else {
          _pendingVipOrders.insert(
              _pendingVipOrders.indexOf(_pendingVipOrders
                  .firstWhere((order) => order.id > orderToCancel.id)),
              orderToCancel);
        }
      } else {
        if (_pendingNormalOrders.isEmpty ||
            _pendingNormalOrders.last.id < orderToCancel.id) {
          _pendingNormalOrders.add(orderToCancel);
        } else {
          _pendingNormalOrders.insert(
              _pendingNormalOrders.indexOf(_pendingNormalOrders
                  .firstWhere((order) => order.id > orderToCancel.id)),
              orderToCancel);
        }
      }

      // cancel/stop the processing operation
      _bots.last.stopProcessingOrder();
    }

    _bots.removeLast();

    notifyListeners();
  }

  void processOrders() {
    // Keep iterating over the pending queues as long as they aren't empty.
    while (_pendingVipOrders.isNotEmpty || _pendingNormalOrders.isNotEmpty) {
      // Don't operate when all bots are busy.
      if (_bots.length == numOfBusyBots) return;

      // Pop an order from the pending queues, considering the priorities.
      Order poppedOrder = _pendingVipOrders.isNotEmpty
          ? _pendingVipOrders.removeAt(0)
          : _pendingNormalOrders.removeAt(0);

      // Assign order to free bot & push the popped order to the _processingOrders list.
      final Bot handlerBot = _bots.firstWhere((bot) => !bot.isBusy);
      handlerBot.isBusy = true;

      poppedOrder.status = Status.PROCESSING;
      poppedOrder.processingBotId = handlerBot.id;
      _processingOrders.add(poppedOrder);

      // start processing the order. NOTE: the callback function will be executed only if the processing wasn't stopped.
      handlerBot.processOrder(() {
        // Remove the popped/completed the order from the _processingOrders list.
        _processingOrders.removeWhere((order) => order.id == poppedOrder.id);

        // And add that completed order to the completed orders list after changing its status.
        poppedOrder.status = Status.COMPLETE;
        _completedOrders.insert(0, poppedOrder);

        // change handler bot's status from busy to free
        handlerBot.isBusy = false;

        // update UI
        notifyListeners();

        // Trigger the function responsible for processing orders when an order is completed.
        processOrders();
      });
    }
  }
}
