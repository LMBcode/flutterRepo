import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../food_viewmodel.dart';
import '../foods_list.dart';

class OrderPage extends StatelessWidget {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CounterViewModel(),
      child: const OrderPageWrapper(),
    );
  }
}

class OrderPageWrapper extends StatefulWidget {
  const OrderPageWrapper({super.key});

  @override
  State<OrderPageWrapper> createState() => _OrderPageStateWrapper();
}

class _OrderPageStateWrapper extends State<OrderPageWrapper> {
  List<String> itemList = [];
  late SharedPreferences pref;
  late Future<SharedPreferences> _prefsFuture;

@override
  void initState() {
    super.initState();
    _prefsFuture = _initSharedPreferences(); // Initialize _prefsFuture here
  }

    int getSubtotal() {
    int subtotal = 0;
    for (String itemName in itemList) {
      subtotal += pref.getInt("itemTotalPrice_${itemName}") ?? 0;
    }
    return subtotal;
  }


  Future<SharedPreferences> _initSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    pref = prefs;
    setState(() {
      itemList = pref.getStringList("itemListKey") ?? [];
    });
    return prefs;
  }

  Widget itemRow(MenuItem menuItem) {
    return ItemRow(menuItem: menuItem, pref: pref,onQuantityChanged: () => setState(() {}),
);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: _prefsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          pref = snapshot.data!;
          itemList = pref.getStringList("itemListKey") ?? [];
          final counterViewModel = Provider.of<CounterViewModel>(context);


          int taxRate = 10;
          int subtotal = getSubtotal();
          double taxes =
              double.parse((subtotal * (taxRate / 100)).toStringAsFixed(2));


          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text(
                      "My Order",
                      style: TextStyle(
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.normal,
                          fontSize: 20.0),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 12.0),
                      child: Text(
                        "Take out",
                        style: TextStyle(
                            fontFamily: "Montserrat",
                            fontWeight: FontWeight.normal,
                            fontSize: 12.0),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: itemList.length,
                        itemBuilder: (context, index) {
                          MenuItem menuItem = getMenuByName(itemList[index]);
                          return itemRow(menuItem);
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Subtotal",
                          style: TextStyle(fontSize: 8),
                        ),
                        Text(" \$ $subtotal")
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Taxes",
                          style: TextStyle(fontSize: 8),
                        ),
                        Text(" \$ ${taxes}")
                      ],
                    ),
                    Text(
                        "------------------------------------------------------------------------"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total",
                          style: TextStyle(fontSize: 8),
                        ),
                        Text(
                            " \$ ${double.parse((subtotal + taxes).toStringAsFixed(2))}")
                      ],
                    ),
                    SizedBox(
                      height: 55,
                      width: double.infinity,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          onPressed: () {
                            setState(() {
                              itemList.clear();
                              pref.setStringList("itemListKey", itemList);
                              pref.remove(("totalPriceKey"));
                            });
                          },
                          child: Text("Button")),
                    )
                  ],
                ),
              ),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  MenuItem getMenuByName(String name) {
    return menuItems.firstWhere((menuItem) => menuItem.name == name);
  }
}

class ItemRow extends StatefulWidget {
  MenuItem menuItem;
  final SharedPreferences pref;final VoidCallback onQuantityChanged;
  ItemRow({required this.menuItem, required this.pref, required this.onQuantityChanged});


  @override
  State<ItemRow> createState() => _ItemRowState();
}

class _ItemRowState extends State<ItemRow> {
  int item_quantity = 1;
  int itemPrice = 0;

  @override
  void initState() {
    super.initState();
      item_quantity = widget.pref.getInt("quantity_${widget.menuItem.name}") ?? 1;
    itemPrice = widget.pref.getInt("itemTotalPrice_${widget.menuItem.name}") ?? widget.menuItem.price;
  }

    void updateQuantity(int newQuantity) {
      int oldQuantity = item_quantity;
      int oldItemTotalPrice = itemPrice * oldQuantity;
      int newItemTotalPrice = widget.menuItem.price * newQuantity;

      setState(() {
        item_quantity = newQuantity;
        widget.pref.setInt("quantity_${widget.menuItem.name}", newQuantity);
        widget.pref.setInt("itemTotalPrice_${widget.menuItem.name}", newItemTotalPrice);
      });

        widget.onQuantityChanged(); 

    }

    


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.grey[300], borderRadius: BorderRadius.circular(15)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              SizedBox(
                width: 100,
                height: 100,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:
                      Image.asset(widget.menuItem.image, width: 50, height: 50),
                ),
              ),
              Column(
                children: [
                  Text(
                    widget.menuItem.name,
                    style: const TextStyle(
                        fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
                  ),
                  Text(
                   "\$ ${widget.pref.getInt("itemTotalPrice_${widget.menuItem.name}") ?? itemPrice}",
                    style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.normal,
                        color: Colors.red),
                  ),
                ],
              )
            ]),
            Row(
              children: [
                IconButton(
                    onPressed: () {
                      if (item_quantity > 1) {
                        updateQuantity(--item_quantity);
                      }
                    },
                    icon: const Icon(Icons.remove)),
                Center(
                  child: Text(item_quantity.toString()),
                ),
                IconButton(
                    onPressed: () {
                      updateQuantity(++item_quantity);
                    },
                    icon: const Icon(Icons.add)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
