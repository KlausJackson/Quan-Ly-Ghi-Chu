import 'package:flutter/material.dart';
import 'package:notes/core/presentation/widget/app_drawer.dart';

class CustomerListDrawer extends StatefulWidget{
  const CustomerListDrawer({super.key});
  @override
  State<CustomerListDrawer> createState() => _CustomerListDrawerState();

}
  class _CustomerListDrawerState extends State<CustomerListDrawer>{

    @override
    Widget build(BuildContext context){
      return Scaffold(
        appBar: AppBar(
          title: const Text("Customer List Drawer"),
        ),
        body: const Center(
          child: Text("Customer List Drawer Page"),
        ),
        drawer: const AppDrawer(),
      );
  }
  }