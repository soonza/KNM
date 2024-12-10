import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_list.dart'; // chat_list.dart 파일을 import

class MyChatPage extends StatefulWidget {
  final String productName;
  final String productId; // 게시글의 ID

  const MyChatPage(
      {Key? key, required this.productName, required this.productId})
      : super(key: key);

  @override
  _MyChatPageState createState() => _MyChatPageState();
}

class _MyChatPageState extends State<MyChatPage> {
  final _controller = TextEditingController();
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print("Logged in as: ${loggedInUser!.email}");
      }
    } catch (e) {
      print("Error retrieving user: $e");
    }
  }

  void _sendMessage() {
    final message = _controller.text.trim();
    if (message.isNotEmpty && loggedInUser != null) {
      FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.productId) // 게시글 ID로 채팅방을 구분
          .collection('messages')
          .add({
        'text': message,
        'sender': loggedInUser!.email,
        'timestamp': Timestamp.now(),
      });
      _controller.clear(); // 입력 필드 초기화
    } else if (loggedInUser == null) {
      print("사용자가 로그인되어 있지 않습니다.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.productName} 채팅'),
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () async {
              final chatRoom = FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.productId);
              await chatRoom.set({
                'productName': widget.productName,
                'productId': widget.productId,
              }, SetOptions(merge: true));
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatListPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              bool? confirmDelete = await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('채팅방 삭제'),
                    content: Text('채팅방을 삭제 하시겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text('취소'),
                      ),
                      TextButton(
                        onPressed: () {
                          // 채팅방 삭제 로직
                          FirebaseFirestore.instance
                              .collection('chats')
                              .doc(widget.productId)
                              .delete(); // 채팅방 삭제
                          Navigator.of(context).pop(true);
                        },
                        child: Text('삭제'),
                      ),
                    ],
                  );
                },
              );
              if (confirmDelete == true) {
                Navigator.pop(context); // 채팅방 삭제 후 이전 페이지로 돌아가기
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.productId) // 게시글 ID로 채팅방 구분
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                final chatDocs = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: chatDocs.length,
                  itemBuilder: (ctx, index) {
                    bool isMe =
                        chatDocs[index]['sender'] == loggedInUser!.email;
                    return Row(
                      mainAxisAlignment: isMe
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          margin:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.grey[300] : Colors.grey[500],
                            borderRadius: isMe
                                ? BorderRadius.only(
                                    topLeft: Radius.circular(14),
                                    topRight: Radius.circular(14),
                                    bottomLeft: Radius.circular(14),
                                  )
                                : BorderRadius.only(
                                    topLeft: Radius.circular(14),
                                    topRight: Radius.circular(14),
                                    bottomRight: Radius.circular(14),
                                  ),
                          ),
                          child: Text(
                            chatDocs[index]['text'],
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(labelText: '메시지 전송...'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
