import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:feedmepos_se_take_home_assignment/models/order.dart';

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: order.status == Status.PENDING
              ? Colors.red[200]
              : order.status == Status.PROCESSING
                  ? Colors.blue[200]
                  : Colors.green[200]),
      child: ListTile(
        leading: const Icon(Icons.assistant_rounded),
        title: Text('Order# ${order.id} ${order.isVip ? "(VIP)" : ""}'),
        subtitle: Text(order.processingBotId != null
            ? 'Handled by Bot #${order.processingBotId}'
            : 'Unhandled'),
        trailing: Text(
          order.status.toString().split('.')[1],
        ),
      ),
    );
  }
}
