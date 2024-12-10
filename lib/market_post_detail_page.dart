import 'package:flutter/material.dart';
import 'my_chat_page.dart'; // 채팅 기능을 위한 페이지
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore를 사용하여 게시글 삭제 기능 추가할 때 필요

class MarketPostDetailPage extends StatelessWidget {
  final String productName;
  final String productDetail;
  final String price;
  final String imageUrl;
  final bool isAuthor; // 작성자인지 여부를 나타내는 변수 추가
  final String userId; // 글쓴이의 사용자 ID 추가
  final String productId; // productId로 이름 변경
  final String documentId; // documentId 추가

  const MarketPostDetailPage({
    Key? key,
    required this.productName,
    required this.productDetail,
    required this.price,
    required this.imageUrl,
    required this.isAuthor, // 작성자인지 여부를 인자로 받음
    required this.userId, // 글쓴이의 사용자 ID를 인자로 받음
    required this.documentId, // documentId를 인자로 받음
    required this.productId, // 추가된 productId
  }) : super(key: key);

  Future<void> deletePost() async {
    // Firestore에서 삭제 로직 구현
    try {
      // Firestore에서 특정 documentId에 해당하는 게시글 삭제
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(documentId)
          .delete();
      print('게시글이 삭제되었습니다.');
    } catch (e) {
      print('게시글 삭제 중 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Text(
                productName,
                style: TextStyle(fontSize: 18),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(' | $userId'), // 글쓴이의 사용자 ID 표시
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (isAuthor) // 작성자인 경우에만 삭제 버튼 표시
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                final confirm = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('삭제 확인'),
                      content: Text('정말로 이 게시글을 삭제하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text('취소'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text('삭제'),
                        ),
                      ],
                    );
                  },
                );
                if (confirm) {
                  await deletePost(); // documentId를 인자로 전달할 필요 없음
                  Navigator.of(context).pop(); // 삭제 후 이전 화면으로 이동
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: double.infinity,
                    height: 300,
                    color: Colors.grey[300],
                    child:
                        Icon(Icons.image, size: 100, color: Colors.grey[600]),
                  ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          productName,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // my_chat_page로 이동
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyChatPage(
                                // 필요한 인자 전달
                                productName: productName,
                                productId: productId,
                              ),
                            ),
                          );
                        },
                        child: Text('채팅하기'),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '가격: $price원',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '제품 설명:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    productDetail,
                    style: TextStyle(fontSize: 16),
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
