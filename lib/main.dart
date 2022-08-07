import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:feedmepos_se_take_home_assignment/providers/orders_bots_manager.dart';
import 'package:feedmepos_se_take_home_assignment/screens/home/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "McDonald's",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        appBarTheme: const AppBarTheme(
          foregroundColor: Colors.amber,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          foregroundColor: Colors.amber,
        ),
      ),
      // Wrap the HomeScreen widget by OrdersBotsManager provider, so it can consume its data.
      home: ChangeNotifierProvider<OrdersBotsManager>(
        create: (context) => OrdersBotsManager(),
        child: const HomeScreen(title: "McDonald's"),
      ),
    );
  }
}
