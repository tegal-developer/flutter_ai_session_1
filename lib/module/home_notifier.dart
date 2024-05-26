import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

import '../models/chat_model.dart';

class HomeNotifier extends ChangeNotifier {
  final BuildContext context;

  HomeNotifier({required this.context}) {
    // getData();
  }

  final Gemini gemini = Gemini.instance;

  List<String> chats = [];
  TextEditingController chat = TextEditingController();
  var no = 1;
  sendMessage() {
    no++;
    ChatModel chatModel = ChatModel(
        id: no,
        posisi: "kanan",
        chat: chat.text,
        createdDate: DateTime.now().toString(),
        type: "text",
        status: "receive");
    listChat = [chatModel, ...listChat];
    try {
      gemini.streamGenerateContent(chat.text).listen((event) {
        String response = event.content!.parts
                ?.fold("", (before, after) => "$before ${after.text}") ??
            '';
        ChatModel chatGemini = ChatModel(
            id: no,
            posisi: "kiri",
            chat: response,
            createdDate: DateTime.now().toString(),
            type: "text",
            status: "receive");

        // listMessage.add(resultMessage);
        listChat = [chatGemini, ...listChat];
        notifyListeners();
      });
    } catch (e) {
      print(e);
    }
    chat.clear();
    notifyListeners();
  }

  List<ChatModel> listChat = [];
  getData() async {
    Dio dio = Dio();
    final response = await dio.get("https://tegaldev.metimes.id/chat-sample");
    final results = jsonDecode(response.data);
    for (Map<String, dynamic> i in results['data']) {
      listChat.add(ChatModel.fromJson(i));
    }
    notifyListeners();
    print(listChat.length);
  }
}
