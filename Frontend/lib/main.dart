import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Commission Compass',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      home: const CommissionCompassPage(),
    );
  }
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

class CommissionCompassBody extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const CommissionCompassBody({super.key, required this.controller, required this.onSend});

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
                    controller: controller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: onSend,
                  icon: Icon(Icons.send),
                  label: Text("Send"),
                  style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[400],
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.all(16)
                ),)
              ],
            ),
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

class MessageBox extends StatelessWidget{
  final String userPrompt;

  const MessageBox({super.key, required this.userPrompt});

  @override
  Widget build(BuildContext context){
    return(
      Column(
        children: [
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
          )
        ]
      )
    );
  }
}

// main class of the ai response
// add more parameters later on for AI responses
class AIResponse extends StatelessWidget{
  final String decision;
  final String keyReasoningContent;
  final List<String> prosList;
  final List<String> consList;
  final String quantifiableImpactContent;
  final String suggestionsContent;

  const AIResponse({
    super.key,  
    required this.decision,
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
            // Padding(
            //   padding: const EdgeInsets.only(right: 10, top: 40),
            //   child: Align(
            //     alignment: Alignment.centerRight,
            //     child: ClipPath(
            //       clipper: MessageBoxClipper(),
            //       child: Container(
            //         width: 180,
            //         padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 26),
            //         color: Colors.blue,
            //         child: Text(userPrompt),
            //       ),
            //     )
            //   ),
            // ),
            
            // AI response
            Padding(
              padding: EdgeInsets.only(left: 10, top: 40, bottom: 20),
              child: Text('Final Decision: $decision! 🔥', style: TextStyle(fontSize: 22, fontWeight: FontWeight(800)),)
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

            ResponseSection(header: "Key Reasoning 💻", response: keyReasoningContent),
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
            ResponseSection(header: "Quantifiable Impacts on You 🫵", response: quantifiableImpactContent),
            ResponseSection(header: "Suggestions 🤑", response: suggestionsContent)
          ],
        )
    );
  }
}

class CommissionCompassPage extends StatefulWidget {
  const CommissionCompassPage({super.key});

  @override
  State<CommissionCompassPage> createState() => _CommissionCompassPageState();
}

class _CommissionCompassPageState extends State<CommissionCompassPage> {
  bool _showResponse = false;
  bool _hasResponse = false;
  final TextEditingController _promptController = TextEditingController();

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
        // leading: Center(
        //   child: Transform.translate(
        //     offset: const Offset(10.0, 0.0),
        //     child: Container(
        //       width: 40,
        //       height: 40,
        //       decoration: BoxDecoration(
        //         borderRadius: BorderRadius.circular(10),
        //         color: Colors.grey[400],
        //       ),
              
              
        //     ),
        //   )
        // ),

        actions: [
          Transform.translate(
            offset: Offset(-17, 0),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque, 
                child: FilledButton.icon(
                  onPressed: () {
                  setState(() {
                    _showResponse = false;
                    _hasResponse = false;
                    _promptController.clear();
                  });
                },
                  icon: Icon(Icons.add_comment_rounded),
                  label: Text("New Chat"),
                  style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[400],
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.all(16)
                ),)
              )
            )
          )
        ],

        elevation: 10,
        shadowColor: Colors.black,
        backgroundColor: Colors.white,
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              // Set minimum height to the screen height
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight( // Allows Column to expand properly inside scroll view
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_showResponse)
                      Column(
                        children: [
                          MessageBox(userPrompt: _promptController.text),
                          _hasResponse 
                            ? AIResponse(decision: "Marcus should pay Shawn", keyReasoningContent: "Based on your input...", prosList: const ["shawn", "jason"], consList: const ["yusuf", "yusuf"], quantifiableImpactContent: "67 67 67 67 67", suggestionsContent: "elsa is here") 
                            : const Padding(
                                padding: EdgeInsets.only(top: 40, left: 10),
                                child: Align(alignment: Alignment.centerLeft, child: Text("Thinking...", style: TextStyle(fontSize: 18))),
                              ),
                        ],
                      )
                    else
                      Expanded(
                        child: Center(
                          child: CommissionCompassBody(
                            controller: _promptController, 
                            onSend: () async {
                               if (_promptController.text.isNotEmpty) {
                                // don't forget to query backend
                                setState(() => _showResponse = true);

                                await Future.delayed(const Duration(seconds: 5));

                                // 4. Update state to show the AIResponse
                                setState(() {
                                  _hasResponse = true;
                                });
                              }
                            }
                          ),
                        ),
                      ),

                    // 3. BOTTOM SECTION: Pushed to the very bottom
                    if (_showResponse) const Spacer(), // Pushes text down when content is short
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Powered by z.ai ILMU-GLM-5.1", 
                        style: TextStyle(fontSize: 12), 
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),

    );
  }
}
