import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() {
  runApp(const MyApp());
}

class MessageBoxClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double tipHeight = 10.0;
    
    // Draw the main rectangle body
    path.addRRect(RRect.fromLTRBR(0, 0, size.width, size.height - tipHeight, Radius.circular(12)));
    
    // Draw the triangular tail at the bottom
    path.moveTo((3*size.width)/4 + 10, size.height - tipHeight);
    path.lineTo((3*size.width)/4 + 20, size.height);
    path.lineTo((3*size.width)/4 + 30, size.height - tipHeight);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class LineSeparator extends CustomClipper<Path>{
  @override
  Path getClip(Size size){
    Path path = Path();

    path.addRRect(RRect.fromLTRBR(0, 0, size.width, size.height, Radius.circular(0)));

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
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
    return(
      SingleChildScrollView(
        child: 
        Padding(
          padding: EdgeInsets.only(top: 40, bottom: 40), 
          child: Column(
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
            ),
            
            AIResponse(userPrompt: "Yusuf or Elsa", keyReasoningContent: "bla baadadasdandjand", prosList: ["yusuf", "jason"], consList: ["shawn"], quantifiableImpactContent: "bla vla bla bla m,arcus", suggestionsContent: "we are one team fr fr") 
          ],
        ))
      )
    ); 
  }
}
// each sub section of the ai response (after the final decision section)
class ResponseSection extends StatelessWidget{
  final String header;
  final dynamic response;

  const ResponseSection({super.key, required this.header, required this.response});

  dynamic responseBody(){
    if(response is String){
      return(
        Padding(
          padding: EdgeInsets.only(left: 10, top: 10, bottom: 20),
          child: Text(response, style: TextStyle(fontSize: 16))
        )
      );
    }
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10, top: 20),
            child: Text(header, style: TextStyle(fontSize: 20, fontWeight: FontWeight(600)),)
          ),

          responseBody(),

          ClipPath(
            clipper: LineSeparator(),
            child: 
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 1,
                color: Colors.grey[300]
              ),
            )
          ),
        ],
      )
    );
  }
}

// main class of the ai response
// add more parameters later on for AI responses
class AIResponse extends StatelessWidget{
  final String userPrompt;
  final String keyReasoningContent;
  final List<String> prosList;
  final List<String> consList;
  final String quantifiableImpactContent;
  final String suggestionsContent;

  const AIResponse({
    super.key, 
    required this.userPrompt, 
    required this.keyReasoningContent, 
    required this.prosList,
    required this.consList,
    required this.quantifiableImpactContent,
    required this.suggestionsContent
  });

  TableRow prosAndConsList(){
    String prosString = "";
    String consString = "";
    for (var pros in prosList) {
      prosString += '\u2022 $pros\n';
    }

    for (var cons in consList){
      consString += '\u2022 $cons\n';
    }
    
    return TableRow(
      children: [
        Center(child: Text(prosString)),
        Center(child: Text(consString))
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return(
      Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // user's prompt
            Padding(
              padding: const EdgeInsets.only(right: 10, top: 40),
              child: Align(
                alignment: Alignment.centerRight,
                child: ClipPath(
                  clipper: MessageBoxClipper(),
                  child: Container(
                    width: 180,
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 26),
                    color: Colors.blue,
                    child: Text(userPrompt),
                  ),
                )
              ),
            ),
            
            // AI response
            Padding(
              padding: EdgeInsets.only(left: 10, top: 40, bottom: 20),
              child: Text("Final Decision: Decision B! 🔥", style: TextStyle(fontSize: 22, fontWeight: FontWeight(800)),)
            ),

            ClipPath(
              clipper: LineSeparator(),
              child: 
              Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 1,
                  color: Colors.grey[300]
                ),
              )
            ),

            ResponseSection(header: "Key Reasoning 💻", response: "bla bla bla bla bla"),
            ResponseSection(
              header: "Pros and Cons 🥶", 
              response: Padding(
                padding: EdgeInsets.only(left: 10, top: 10, bottom: 20),
                child: Table(
                  defaultColumnWidth: FixedColumnWidth(150), 
                  // columnWidths: const {
                  //   0: FlexColumnWidth(1),
                  //   1: FlexColumnWidth(1),
                  // },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle, 
                  border: TableBorder.all(color: Colors.black, width: 1),
                  children: [
                    TableRow(
                      children: [
                        Center(child: Text("Pros")),
                        Center(child: Text("Cons"))
                      ]
                    ),

                    prosAndConsList()
                  ],
                )
              ),
            ),
            ResponseSection(header: "Quantifiable Impacts on You 🫵", response: "bla bla bla bla bla"),
            ResponseSection(header: "Suggestions 🤑", response: "bla bla bla bla bla")
          ],
        )
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
      backgroundColor: const Color(0xFFEFF6FF),
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
              offset: const Offset(1.0, 0.0),
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
            offset: Offset(-17, 0),
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
