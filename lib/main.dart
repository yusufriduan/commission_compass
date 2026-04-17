import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  // Yusuf will we only have one page?
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Commission Compass',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Commission Compass",
                style: TextStyle(fontSize: 24),
            ),
            Transform.translate(
              offset: const Offset(3.0, 0.0), // Shifting 2 pixels to the left
              child: const Text("AI-powered commission decision assistant", style: TextStyle(fontSize: 12),),
            )
            // Text(
            //   "AI-powered commission decision assistant",
            //   style: TextStyle(fontSize: 12),
            // )
          ],
        ),
        leading: Center(
          child: Transform.translate(
            offset: const Offset(10.0, 0.0),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.blueAccent,
              ),
              
              
            ),
          )
          
        ),

        elevation: 10,
        shadowColor: Colors.black,
        backgroundColor: Colors.white,
      ),
    );
  }
}
