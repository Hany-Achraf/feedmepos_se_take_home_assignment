import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:feedmepos_se_take_home_assignment/providers/orders_bots_manager.dart';
import 'package:feedmepos_se_take_home_assignment/screens/home/widgets/order_card.dart';
import 'package:feedmepos_se_take_home_assignment/models/order.dart';

class HomeScreen extends StatefulWidget {
  final String title;

  const HomeScreen({Key? key, required this.title}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final OrdersBotsManager ordersBotsManagerProvider =
        Provider.of<OrdersBotsManager>(context, listen: true);

    // Get an updated list of all orders
    final List<Order> ordersList = ordersBotsManagerProvider.allOrders;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: InkWell(
                    onTap: () =>
                        Provider.of<OrdersBotsManager>(context, listen: false)
                            .makeOrder(),
                    splashColor: Colors.grey, // splash color
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("Make Normal Order"),
                        Icon(Icons.add),
                      ],
                    ),
                  ),
                ),
                PopupMenuItem(
                  child: InkWell(
                    onTap: () =>
                        Provider.of<OrdersBotsManager>(context, listen: false)
                            .makeOrder(isVip: true),
                    splashColor: Colors.grey, // splash color
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("Make VIP Order"),
                        Icon(Icons.add),
                      ],
                    ),
                  ),
                ),
              ];
            },
          )
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(8),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(0, 4, 0, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Number of Bots: ${ordersBotsManagerProvider.numOfBots}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Number of Busy Bots: ${ordersBotsManagerProvider.numOfBusyBots}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            ordersList.isEmpty
                ? const Text('No Orders!')
                : Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: ordersList.length,
                      itemBuilder: (context, index) {
                        return OrderCard(order: ordersList[index]);
                      },
                    ),
                  ),
          ],
        ),
      ),
      floatingActionButton: Wrap(
        direction: Axis.vertical,
        children: [
          Container(
            margin: const EdgeInsets.all(5),
            child: FloatingActionButton(
              onPressed: () =>
                  Provider.of<OrdersBotsManager>(context, listen: false)
                      .addBot(),
              tooltip: 'Increment',
              child: const Text(
                '+ Bot',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(5),
            child: FloatingActionButton(
              onPressed: () =>
                  Provider.of<OrdersBotsManager>(context, listen: false)
                      .removeBot(),
              tooltip: 'Increment',
              child: const Text(
                '- Bot',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
