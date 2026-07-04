import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          toolbarHeight: 140,
          title: Column(
            children: [
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: "Search...",
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(text: "Photos"),
                    Tab(text: "Albums"),
                    Tab(text: "Users"),
                  ],
                ),
              ),
            ],
          ),
        ),

        body: const TabBarView(
          children: [
            Center(child: Text("Photos Content")),
            Center(child: Text("Albums Content")),
            Center(child: Text("Users Content")),
          ],
        ),
      ),
    );
  }
}
