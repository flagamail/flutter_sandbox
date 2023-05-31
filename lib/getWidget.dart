import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/home',
    defaultTransition: Transition.fade,
    getPages: [
      GetPage(
        name: '/home',
        page: () => const HomePage(),
      ),
      GetPage(
        name: '/shop',
        page: () => ShopPage(),
        binding: ShopBinding(),
      ),
    ],
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HOME')),
      body: Center(
        child: ElevatedButton(
      //    color: Colors.blue,
          onPressed: () => Get.toNamed('/shop'),
          child: const Text(
            'Go to Shop',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }
}

class ShopBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ShopController());
    Get.create(() => ShopItemController());
  }
}

class ShopController extends GetxController {
  final total = 0.obs;
  final list = ['item 1', 'item 2', 'item 3'].obs;
  void increment() => total.value += 1;
  void addLista() => list.add('item ${(list.length + 1).toString()}');
}

class ShopPage extends GetView<ShopController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SHOP')),
      body: Column(
        children: [
          Obx(() => Text('Total: ${controller.total}')),
          Flexible(
            child: Obx(
                  () => ListView.builder(
                itemCount: controller.list.length,
                itemBuilder: (context, item) {
                  String produto = controller.list[item];
               //   return ShopItem(produto: produto);
                  return Text(produto);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          controller.addLista();
        },
      ),
    );
  }
}

class ShopItemController extends GetxController {
  final quantity = 0.obs;
  ShopController shop = Get.find<ShopController>();
  void increment() {
    quantity.value += 1;
    shop.total.value += 1;
  }

  @override
  void onInit() {
    super.onInit();
    print('ShopItemController ${quantity.value}');
  }
}

class ShopItem extends GetWidget<ShopItemController> {
  ShopItem({Key? key, required this.produto}) : super(key: key);

  final String produto;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(produto),
        SizedBox(width: 10),
        Obx(() => Text('Qty: ${controller.quantity.toString()}')),
        SizedBox(width: 10),
        ElevatedButton.icon(
          onPressed: () => controller.increment(),
          icon: Icon(Icons.add),
          label: Text('add'),
        )
      ],
    );
  }
}