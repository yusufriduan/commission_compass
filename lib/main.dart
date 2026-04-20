import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
      home: const CommissionCompassPage(),
    );
  }
}

class CommissionCompassBody extends StatelessWidget {
  const CommissionCompassBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 15,
      children: [
        Column(
          children: [
            Text("How can I help you decide?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            Text("Ask me about any freelance commission or opportunity"),
          ]
        ),

        Row(
          spacing: 15,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 250,
              child: TextField(
                obscureText: false,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            FilledButton.icon(
              onPressed: () {},
              icon: Icon(Icons.send),
              label: Text("Send"),
              style: IconButton.styleFrom(
              backgroundColor: Colors.grey[400],
              foregroundColor: Colors.black,
              padding: EdgeInsets.all(16)
            ),)
          ],
        )

      ],
    );
  }
}

class CommissionCompassPage extends StatelessWidget {
  const CommissionCompassPage({super.key});

  double returnFontSize(){
    if (kIsWeb){
      return 22;
    } else {
      return 18;
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Commission Compass",
                style: TextStyle(
                  fontSize: returnFontSize(),
                  fontWeight: FontWeight(800)),
            ),
            Transform.translate(
              offset: const Offset(3.0, 0.0), // Shifting 2 pixels to the left
              child: const Text("AI-powered commission decision assistant", style: TextStyle(fontSize: 10),),
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
                color: Colors.grey[400],
              ),
              
              
            ),
          )
        ),

        actions: [
          Transform.translate(
            offset: Offset(-15, 0),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                width: 100,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[400]
                ),
                alignment: Alignment.center,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("New chat", style: TextStyle(fontSize: 12)),
                    Transform.translate(
                      offset: Offset(5, 0),
                      child: SvgPicture.asset(
                        'assets/message-plus.svg',
                        width: 30,
                        height: 30,
                        semanticsLabel: 'New Chat',
                      )
                    )
                  ]
                )
              )
            )
          )
        ],

        elevation: 10,
        shadowColor: Colors.black,
        backgroundColor: Colors.white,
      ),
      body: Center(child: CommissionCompassBody()),
    );
  }
}
