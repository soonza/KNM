import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'market_post_page.dart'; // 글쓰기 페이지 임포트
import 'market_post_detail_page.dart'; // 상세 페이지를 임포트합니다.
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuth 임포트

class FreeMarketPage extends StatefulWidget {
  const FreeMarketPage({super.key});

  @override
  State<FreeMarketPage> createState() => _FreeMarketPageState();
}

class _FreeMarketPageState extends State<FreeMarketPage> {
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    // 현재 로그인한 사용자의 ID를 가져옵니다.
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _currentUserId = user?.uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("자유시장"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data!.docs;

          if (posts.isEmpty) {
            return const Center(child: Text("게시물이 없습니다."));
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index].data() as Map<String, dynamic>;
              final imageUrl = (post['images'] != null &&
                      post['images'] is List &&
                      post['images'].isNotEmpty)
                  ? post['images'][0]
                  : '';

              // 작성자 여부 확인
              final isAuthor = post['authorId'] == _currentUserId;

              return GestureDetector(
                onTap: () {
                  final documentId = posts[index].id; // documentId 가져오기

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MarketPostDetailPage(
                        productName: post['productName'] ?? '',
                        productDetail: post['productDetail'] ?? '',
                        price: post['price']?.toString() ?? '0',
                        imageUrl: imageUrl,
                        isAuthor: isAuthor, // isAuthor 전달
                        userId: post['authorId'] ?? '', // userId 전달
                        documentId: documentId, // documentId 전달
                        productId: documentId,
                      ),
                    ),
                  );
                },
                child: Card(
                  child: ListTile(
                    leading: (imageUrl.isNotEmpty)
                        ? Image.network(imageUrl,
                            width: 50, height: 50, fit: BoxFit.cover)
                        : const Icon(Icons.image, size: 50),
                    title: Text(post['productName'] ?? ''),
                    subtitle: Text(post['productDetail'] ?? ''),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // MarketPostPage에서 새 글을 작성하고 반환받음
          final newPost = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MarketPostPage(),
            ),
          );
          if (newPost != null) {
            setState(() {}); // StreamBuilder가 자동으로 새 데이터를 가져옴
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
