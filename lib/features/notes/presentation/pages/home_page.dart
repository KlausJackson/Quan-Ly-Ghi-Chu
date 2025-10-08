import 'package:flutter/material.dart';
import 'package:notes/core/presentation/widget/app_drawer.dart';

class HomePage extends StatefulWidget{
    const HomePage({super.key});
    @override
    State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage>{
    @override
    Widget build(BuildContext context){
        return Scaffold(
            appBar: AppBar(
                title: const Text("Home Page"),
            ),
            body: const Center(
                child: Text("Welcome to the Home Page!"),
            ),
            drawer: const AppDrawer(),
        );
    }
}
