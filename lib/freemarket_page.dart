import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'market_post_page.dart'; // 글쓰기 페이지 임포트
import 'market_post_detail_page.dart'; // 상세 페이지를 임포트합니다.

class FreeMarketPage extends StatefulWidget {
  const FreeMarketPage({super.key});

  @override
  State<FreeMarketPage> createState() => _FreeMarketPageState();
}

class _FreeMarketPageState extends State<FreeMarketPage> {
  // 게시글 리스트
  List<DocumentSnapshot> _posts = [];

  @override
  void initState() {
    super.initState();
    // Firestore에서 데이터 가져오기
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .get();
    setState(() {
      _posts = snapshot.docs; // 가져온 문서를 _posts에 저장
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("자유시장"),
        centerTitle: true,
      ),
      body: _posts.isEmpty
          ? const Center(child: Text("게시물이 없습니다.")) // 게시물이 없을 때
          : ListView.builder(
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index].data() as Map<String, dynamic>;
                final imageUrl = (post['images'] != null &&
                        post['images'] is List &&
                        post['images'].isNotEmpty)
                    ? post['images'][0] // 이미지 리스트가 있을 경우 첫 번째 이미지
                    : ''; // 이미지가 없을 경우 빈 문자열

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MarketPostDetailPage(
                          productName: post['productName'] ?? '',
                          productDetail: post['productDetail'] ?? '',
                          price: post['price']?.toString() ?? '0',
                          imageUrl: imageUrl,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    child: ListTile(
                      leading: (imageUrl.isNotEmpty)
                          ? Image.network(imageUrl,
                              width: 50, height: 50, fit: BoxFit.cover)
                          : Icon(Icons.image, size: 50), // 이미지가 없을 경우 기본 아이콘 표시
                      title: Text(post['productName'] ?? ''),
                      subtitle: Text(post['productDetail'] ?? ''),
                    ),
                  ),
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
            await _fetchPosts(); // 새 게시물 작성 후 게시글 리스트를 다시 가져오기
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
