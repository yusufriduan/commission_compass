import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
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

  final bool showResponse;
  final bool hasResponse;

  const CommissionCompassBody({super.key, required this.controller, required this.onSend, required this.showResponse, required this.hasResponse});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 15,
        children: [
          Column(
            children: [
              Visibility(
                visible: showResponse ? false : true,
                child: Text("How can I help you decide?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
              ),
              Visibility(
                visible: showResponse ? false : true,
                child: Text("Ask me about any freelance commission or opportunity"),
              ),
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
                onPressed: !showResponse ? onSend : (hasResponse ? onSend : null),
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
      ),
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

  Widget buildProConColumn(String title, List<String> items, Color themeColor, Color bgColor){
    return Container(
      decoration: BoxDecoration(
        color:bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical:8, horizontal:12),
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, color: themeColor, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsetsGeometry.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((item) => Padding(
                padding: EdgeInsetsGeometry.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("• ",
                      style: TextStyle(fontWeight: FontWeight.bold, color: themeColor, fontSize: 16)
                    ),
                    Expanded(child: Text(item, style: TextStyle(fontSize: 14, height: 1.3))),
                  ],
                ),
              )).toList(),
            ),
          )
        ],
      ),
    );
  }

  Widget buildSuggestionsList(String text) {
    List<String> items;
    if (text.contains('\n')) {
      items = text.split('\n');
    } else {
      items = text.split(RegExp(r'(?=\d+\.\s)'));
    }

    items = items.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    return Padding(padding: EdgeInsetsGeometry.only(left: 10, right: 10, top: 10, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) {
          return Padding(
            padding: EdgeInsetsGeometry.only(bottom: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(fontSize: 15, height: 1.4),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return(
      Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            if(prosList.isNotEmpty && consList.isNotEmpty)
              ResponseSection(
                header: "Pros and Cons 🥶", 
                response: Padding(
                  padding: EdgeInsets.only(left: 10, top: 10, bottom: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: buildProConColumn("Pros", prosList, Colors.green[700]!, Colors.green[50]!)),
                      SizedBox(width: 12),
                      Expanded(child: buildProConColumn("Cons", consList, Colors.red[700]!, Colors.red[50]!)),
                    ],
                  )
                ),
              ),
            
            if (quantifiableImpactContent != "N/A" && quantifiableImpactContent.isNotEmpty)
              ResponseSection(header: "Quantifiable Impacts on You 🫵", response: quantifiableImpactContent),

            if(suggestionsContent.length > 1)
              ResponseSection(header: "Suggestions 🤑", response: buildSuggestionsList(suggestionsContent))
          ],
        )
    );
  }
}

class APIFetchFormat{
  final String decision;
  final String keyReasoningContent;
  final List<String> prosList;
  final List<String> consList;
  final String quantifiableImpactContent;
  final String suggestionsContent;

  const APIFetchFormat({ 
    required this.decision,
    required this.keyReasoningContent, 
    required this.prosList,
    required this.consList,
    required this.quantifiableImpactContent,
    required this.suggestionsContent
  });
}

class CommissionCompassPage extends StatefulWidget {
  const CommissionCompassPage({super.key});

  @override
  State<CommissionCompassPage> createState() => _CommissionCompassPageState();
}

class _CommissionCompassPageState extends State<CommissionCompassPage> {
  bool _showResponse = false;
  bool _hasResponse = false;
  String curPrompt = "";

  List<Map<String, dynamic>> _messageContent = [];

  final TextEditingController _promptController = TextEditingController();

  double returnFontSize(){
    if (kIsWeb){
      return 22;
    } else {
      return 18;
    }
  }

  Future<Map<String, dynamic>> getDecision(String userInput) async {
    String baseUrl;
    if (kIsWeb) {
      baseUrl = "http://10.0.2.2:8000";
    } else {
      // Change this IP address to your device's IP address for physical device testing or http://10.0.2.2:8000 for Android Studio uses
      baseUrl = "http://192.168.0.13:8000";
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/decision'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_input": userInput}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Connection Failed: $e");
    }
  }

  Future<APIFetchFormat> apiFetch(String prompt) async {
    Map<String, dynamic> res = await getDecision(prompt);

    return APIFetchFormat(
      decision: res["decision"],
      keyReasoningContent: res["keyReasoningContent"],
      prosList: List<String>.from(res["prosList"] ?? []),
      consList: List<String>.from(res["consList"] ?? []),
      quantifiableImpactContent: res["quantifiableImpactContent"],
      suggestionsContent: res["suggestionsContent"],
    );
  }
  void sendPrompt() async {
      if (_promptController.text.isNotEmpty) {
      
      setState(() {
        _hasResponse = false;
        _showResponse = true;
        curPrompt = _promptController.text;
        _promptController.clear();
      });

      APIFetchFormat newResponse = await apiFetch(curPrompt);
      // await Future.delayed(const Duration(seconds: 5));

      setState(() {
        _messageContent.add({
          "message": curPrompt,
          "decision": newResponse.decision,
          "keyReasoningContent": newResponse.keyReasoningContent,
          "prosList": newResponse.prosList,
          "consList": newResponse.consList,
          "quantifiableImpactContent": newResponse.quantifiableImpactContent,
          "suggestionsContent": newResponse.suggestionsContent
        });
        _hasResponse = true;
      });
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
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
                    _messageContent = [];
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

      body: SafeArea(
          child: Stack(
              children: [
                if (_showResponse)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 120.0),
                    child: ListView(
                      padding: EdgeInsets.all(16.0),
                      children: [
                        for(var res in  _messageContent) ...[
                          MessageBox(userPrompt: res["message"]),
                          AIResponse(decision: res["decision"], keyReasoningContent: res["keyReasoningContent"], prosList: res["prosList"], consList: res["consList"], quantifiableImpactContent: res["quantifiableImpactContent"], suggestionsContent: res["suggestionsContent"])
                        ],

                        if(!_hasResponse)...[
                          MessageBox(userPrompt: curPrompt),
                          const Padding(
                            padding: EdgeInsets.only(top: 40, left: 10),
                            child: Align(alignment: Alignment.centerLeft, child: Text("Thinking...", style: TextStyle(fontSize: 18))),
                          )
                        ],
                      ],
                    ),
                  ),

                  AnimatedAlign(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    alignment: _showResponse ? Alignment.bottomCenter : Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CommissionCompassBody(controller: _promptController, onSend: sendPrompt, showResponse: _showResponse, hasResponse: _hasResponse),

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
              ],
          ),
      ),

    );
  }
}

