import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io'; // File 클래스 사용
import 'package:path/path.dart' as path; // 패키지에 별칭 추가

class MarketPostPage extends StatefulWidget {
  @override
  _MarketPostPageState createState() => _MarketPostPageState();
}

class _MarketPostPageState extends State<MarketPostPage> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productDetailController =
      TextEditingController();
  final TextEditingController _productPriceController =
      TextEditingController(); // 가격 입력을 위한 컨트롤러
  List<File> _selectedImages = []; // 선택된 이미지 목록
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    // 사용자에게 사진 촬영 또는 갤러리 선택 옵션을 제공하는 다이얼로그
    final pickedOption = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('이미지 선택'),
        actions: [
          TextButton(
            child: Text('촬영하기'),
            onPressed: () {
              Navigator.pop(context, ImageSource.camera); // 카메라 선택
            },
          ),
          TextButton(
            child: Text('갤러리에서 선택하기'),
            onPressed: () {
              Navigator.pop(context, ImageSource.gallery); // 갤러리 선택
            },
          ),
          TextButton(
            child: Text('취소'),
            onPressed: () {
              Navigator.pop(context); // 다이얼로그 닫기
            },
          ),
        ],
      ),
    );

    // 사용자가 선택한 옵션에 따라 이미지 피커 실행
    if (pickedOption != null) {
      final pickedFile =
          await picker.pickImage(source: pickedOption); // 선택한 소스 사용
      if (pickedFile != null) {
        setState(() {
          _selectedImages.add(File(pickedFile.path)); // 이미지 선택 시 리스트에 추가
        });
      }
    }
  }

  Future<void> _submitPost() async {
    String productName = _productNameController.text;
    String productDetail = _productDetailController.text;
    String productPrice = _productPriceController.text; // 가격 입력 필드 값

    if (productName.isEmpty || productDetail.isEmpty || productPrice.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('제목, 내용 및 가격을 입력해주세요.')),
      );
      return;
    }

    List<String> imageUrls = []; // 이미지 URL을 저장할 리스트

    try {
      // 선택된 이미지가 있으면 모든 이미지를 업로드하고 URL 가져오기
      for (var image in _selectedImages) {
        var ref = FirebaseStorage.instance
            .ref('products/${path.basename(image.path)}');
        var uploadTask = ref.putFile(image);

        // 업로드 완료 후 URL 가져오기
        var snapshot = await uploadTask.whenComplete(() => {});
        String imageUrl = await ref.getDownloadURL(); // 이미지 URL 저장
        imageUrls.add(imageUrl); // URL 리스트에 추가
      }

      // Firestore에 데이터 추가 (userName 필드 제거)
      await FirebaseFirestore.instance.collection('posts').add({
        'productName': productName,
        'productDetail': productDetail,
        'price': num.tryParse(productPrice), // 가격을 숫자로 변환하여 저장
        'images': imageUrls, // 이미지 URL 리스트 저장
        'createdAt': FieldValue.serverTimestamp(), // 현재 시간 저장
      });

      // 업로드 후 초기화
      _productNameController.clear();
      _productDetailController.clear();
      _productPriceController.clear();
      setState(() {
        _selectedImages.clear();
      });

      // FreeMarketPage로 돌아가기
      Navigator.pop(context);
    } catch (e) {
      // 전체적인 오류 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류 발생: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('제품 판매'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _productNameController,
              decoration: InputDecoration(labelText: '제품명'),
            ),
            TextField(
              controller: _productDetailController,
              decoration: InputDecoration(labelText: '제품 상세'),
              maxLines: 3,
            ),
            TextField(
              controller: _productPriceController,
              decoration: InputDecoration(labelText: '가격'), // 가격 입력 필드
              keyboardType: TextInputType.number, // 숫자 키패드 표시
            ),
            SizedBox(height: 20),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.camera_alt),
                  onPressed: _pickImage, // 이미지 선택 기능
                ),
                Text('${_selectedImages.length}/10'), // 선택된 이미지 개수 표시
              ],
            ),
            SizedBox(height: 10),
            _selectedImages.isEmpty
                ? Text('이미지가 선택되지 않았습니다.')
                : Row(
                    children: _selectedImages
                        .map((image) =>
                            Image.file(image, width: 100, height: 100))
                        .toList(),
                  ),
            Spacer(),
            ElevatedButton(
              onPressed: _submitPost, // 게시글 제출
              child: Text('DONE'),
            ),
          ],
        ),
      ),
    );
  }
}
