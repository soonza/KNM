import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:project/constants.dart';
import 'package:project/item_basket_page.dart';
import 'package:project/models/product.dart';
import 'dart:ffi';
import 'dart:ui';

class ItemDetailsPage extends StatefulWidget {
  int? productNo;
  String productName;
  String productImageUrl;
  double price;
  ItemDetailsPage(
      {super.key,
      required this.productNo,
      required this.productName,
      required this.productImageUrl,
      required this.price});

  @override
  State<ItemDetailsPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemDetailsPage> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("제품 상세 페이지"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            productImageContainer(),
            productNameContainer(),
            productPriceContainer(),
            productQuantityContainer(),
            productTotalPriceContainer(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: FilledButton(
          onPressed: () {
            //! 임시 장바구니 변수 Map 선언 - 디스크에서 받아옴
            Map<String, dynamic> cartMap =
                json.decode(sharedPreferences.getString("cartMap") ?? "{}") ??
                    {};

            //! 장바구니에 해당 제품이 없을 시
            if (cartMap[widget.productNo.toString()] == null) {
              cartMap.addAll({widget.productNo.toString(): quantity});
            } else {
              //! 제품이 있을 시
              cartMap[widget.productNo.toString()] += quantity;
            }
            //! 디스크에서 다시 반영
            sharedPreferences.setString("cartMap", json.encode(cartMap));

            print(cartMap);

            //! 장바구니 페이지로 이동
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return const ItemBasketPage();
            }));
          },
          child: const Text("장바구니 담기"),
        ),
      ),
    );
  }

  Widget productImageContainer() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(15),
      child: CachedNetworkImage(
        width: MediaQuery.of(context).size.width * 0.8,
        imageUrl: widget.productImageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          );
        },
        errorWidget: (context, url, error) {
          return const Center(
            child: Text("오류 발생"),
          );
        },
      ),
    );
  }

  Widget productNameContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Text(
        widget.productName,
        textScaler: const TextScaler.linear(1.5),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget productPriceContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Text(
        "${numberFormat.format(widget.price)}원",
        textScaler: const TextScaler.linear(1.3),
      ),
    );
  }

  Widget productQuantityContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("수량: "),
          IconButton(
            onPressed: () {
              setState(() {
                if (quantity > 1) {
                  quantity--;
                }
              });
            },
            icon: const Icon(Icons.remove, size: 24),
          ),
          Text("$quantity"),
          IconButton(
            onPressed: () {
              setState(() {
                quantity++;
              });
            },
            icon: const Icon(Icons.add, size: 24),
          ),
        ],
      ),
    );
  }

  Widget productTotalPriceContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "총 상품금액: ",
            textScaler: TextScaler.linear(1.3),
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "${numberFormat.format(widget.price * quantity)}원",
            textScaler: const TextScaler.linear(1.3),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
