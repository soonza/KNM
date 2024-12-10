import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/chat_List.dart';
import 'package:project/constants.dart';
import 'package:project/item_basket_page.dart';
import 'package:project/item_details_page.dart';
import 'package:project/my_order_list_page.dart';
import 'package:project/models/product.dart';
import 'package:project/freemarket_page.dart';

class ItemListPage extends StatefulWidget {
  const ItemListPage({super.key});

  @override
  State<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  final productListRef = FirebaseFirestore.instance
      .collection("products")
      .withConverter(
          fromFirestore: (snapshot, _) => Product.fromJson(snapshot.data()!),
          toFirestore: (product, _) => product.toJson());

  ScrollController _scrollController = ScrollController();
  int _currentIndex = 0;
  String _selectedSort = "즐겨찾기 순"; // 기본 정렬 기준

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("제품 리스트"),
        centerTitle: true,
        actions: [
          DropdownButton<String>(
            value: _selectedSort,
            underline: const SizedBox(),
            icon: const Icon(Icons.sort, color: Colors.white),
            dropdownColor: Colors.blue,
            items: const [
              DropdownMenuItem(
                value: "즐겨찾기 순",
                child: Text("즐겨찾기 순", style: TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: "가격순",
                child: Text("가격순", style: TextStyle(color: Colors.white)),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedSort = value!;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const MyOrderListPage(),
              ));
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const ItemBasketPage(),
              ));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: (_selectedSort == "가격순")
                  ? productListRef.orderBy("price", descending: true).snapshots()
                  : productListRef.orderBy("productNo").snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return GridView(
                    controller: _scrollController,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                    ),
                    children: snapshot.data!.docs.map((document) {
                      return productContainer(
                        productNo: document.data().productNo ?? 0,
                        productName: document.data().productName ?? "",
                        productImageUrl: document.data().productImageUrl ?? "",
                        price: document.data().price ?? 0,
                      );
                    }).toList(),
                  );
                } else if (snapshot.hasError) {
                  return const Center(child: Text("오류가 발생했습니다."));
                } else {
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          if (index == 1) {
            // 자유시장 페이지로 이동
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const FreeMarketPage(),
            ));
          } else if (index == 2) {
            // 마이페이지로 이동 (추후 추가)
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ChatListPage(),
            ));
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: '자유시장',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '마이페이지',
          ),
        ],
      ),
    );
  }

  Widget productContainer({
    required int productNo,
    required String productName,
    required String productImageUrl,
    required double price,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ItemDetailsPage(
            productNo: productNo,
            productName: productName,
            productImageUrl: productImageUrl,
            price: price,
          ),
        ));
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            CachedNetworkImage(
              height: 150,
              fit: BoxFit.cover,
              imageUrl: productImageUrl,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              errorWidget: (context, url, error) => const Center(
                child: Text("오류 발생"),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              child: Text(
                productName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              child: Text("${numberFormat.format(price)}원"),
            ),
          ],
        ),
      ),
    );
  }
}
