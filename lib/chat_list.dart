import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'my_chat_page.dart'; // MyChatPage 클래스가 정의된 파일을 임포트

class ChatListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('채팅 목록'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('chats').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final chatDocs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: chatDocs.length,
            itemBuilder: (ctx, index) {
              return ListTile(
                title: Text(chatDocs[index]['productName']), // 게시글 이름 표시
                subtitle: Text('채팅방 ID: ${chatDocs[index].id}'), // 채팅방 ID 표시
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyChatPage(
                        productName: chatDocs[index]['productName'],
                        productId: chatDocs[index].id, // 채팅방 ID 전달
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
