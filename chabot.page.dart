import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';




class Chatbot extends StatefulWidget {
  Chatbot({super.key});
  @override
  State<Chatbot> createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> {
  String get _apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  var messages = [
    {"role": "user", "content": "Bonjour"},
    {"role": "assistant", "content": "Que puis-je faire?"}
  ];

  TextEditingController userController = TextEditingController();
  ScrollController scrollController = ScrollController();
 

  get _apikey => null; bool isLoading = false; // Pour afficher un indicateur de chargement

  @override
  Widget build(BuildContext context) {
    print("Build ............");
    return Scaffold(
      appBar: AppBar(
        title: Text(" Chatbot",
            style: TextStyle(color: Theme.of(context).indicatorColor)
        ),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(onPressed: (){
            Navigator.of(context).pop();
            Navigator.pushNamed(context, "/");
          }, icon: Icon(Icons.logout,
            color: Theme.of(context).indicatorColor ,))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index){
                return Column(
                  children: [
                    Row(
                      children: [
                        messages[index]['role']=='user'
                            ? SizedBox(width: 80,)
                            : SizedBox(width: 0,),
                        Expanded(
                          child: Card.outlined(
                            margin: EdgeInsets.all(6),
                            color: messages[index]['role']=='user'
                                ? Color.fromARGB(30, 0, 255, 0)
                                : Colors.white,
                            child: Container(
                              child: ListTile(
                                title: Text("${messages[index]['content']}"),
                              ),
                            ),
                          ),
                        ),
                        messages[index]['role']=='assistant'
                            ? SizedBox(width: 80,)
                            : SizedBox(width: 0,),
                      ],
                    ),
                    Divider()
                  ],
                );
              },
            ),
          ),
          // Indicateur de chargement
          if (isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: userController,
                    decoration: InputDecoration(
                      hintText: "Votre message......",
                      suffixIcon: userController.text.isNotEmpty
                          ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            userController.clear();
                          });
                        },
                      )
                          : Icon(Icons.message),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          width: 1,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {}); // Pour mettre à jour l'icône
                    },
                    onFieldSubmitted: (value) {
                      // Envoyer le message quand on appuie sur Entrée
                      if (value.trim().isNotEmpty && !isLoading) {
                        _sendMessage();
                      }
                    },
                  ),
                ),
                IconButton(
                  onPressed: userController.text.trim().isNotEmpty && !isLoading
                      ? _sendMessage
                      : null, // Désactive le bouton si le champ est vide ou en cours de chargement
                  icon: Icon(Icons.send),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    String question = userController.text.trim();

    if (question.isEmpty) return;

    // Vider immédiatement le champ de saisie
    userController.clear();

    // Ajouter le message de l'utilisateur
    setState(() {
      messages.add({"role": "user", "content": question});
      isLoading = true;
    });

    // Faire défiler vers le bas
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    try {
      Uri uri = Uri.parse("https://api.openai.com/v1/chat/completions");


      var headers = {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $_apiKey',




      };
      var body = {
        "model": "gpt-4o",
        "messages": [
          {
            "role": "user",
            "content": question
          }
        ]
      };

      final response = await http.post(uri, headers: headers, body: json.encode(body));

      if (response.statusCode == 200) {
        var aiResponse = json.decode(response.body);
        String answer = aiResponse['choices'][0]['message']['content'];

        setState(() {
          messages.add({"role": "assistant", "content": answer});
          isLoading = false;
        });
      } else {
        setState(() {
          messages.add({"role": "assistant", "content": "Erreur: ${response.statusCode}"});
          isLoading = false;
        });
      }
    } catch (err) {
      print(err);
      setState(() {
        messages.add({"role": "assistant", "content": "Erreur de connexion"});
        isLoading = false;
      });
    }

    // Faire défiler vers le bas après avoir reçu la réponse
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    userController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}