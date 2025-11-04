// import 'package:get/get.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class ProductController extends GetxController {
//   final supabase = Supabase.instance.client;

//   var products = <ProductModel>[].obs;
//   var isLoading = false.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     fetchProducts();
//   }

//   Future<void> fetchProducts() async {
//     try {
//       isLoading(true);
//       final response = await supabase
//           .from('products')
//           .select('id, name, image_url, price')
//           .order('name', ascending: true);

//       if (response != null && response is List) {
//         products.assignAll(
//           response.map((e) => ProductModel.fromJson(e)).toList(),
//         );
//       } else {
//         _addDummyData();
//       }
//     } catch (e) {
//       print('Error fetching products: $e');
//       _addDummyData();
//     } finally {
//       isLoading(false);
//     }
//   }

//   void _addDummyData() {
//     products.assignAll([
//       ProductModel(
//         id: '1',
//         name: 'Apple iPhone 15',
//         imageUrl: 'https://macstoreonline.com.mx/img/sku/iphone735_FZ.jpg',
//         price: 999.99,
//       ),
//       ProductModel(
//         id: '2',
//         name: 'Samsung Galaxy S25',
//         imageUrl:
//             'https://m.media-amazon.com/images/I/51VfGGh7quL._UF894,1000_QL80_.jpg',
//         price: 899.99,
//       ),
//       ProductModel(
//         id: '3',
//         name: 'Sony Headphones',
//         imageUrl:
//             'https://m.media-amazon.com/images/I/510cs9VwjUL._UF1000,1000_QL80_.jpg',
//         price: 199.99,
//       ),
//     ]);
//   }
// }
