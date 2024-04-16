import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(child: SnappingList()),
    );
  }
}

class SnappingList extends StatefulWidget {
  const SnappingList({Key? key}) : super(key: key);

  @override
  _SnappingListState createState() => _SnappingListState();
}

class Product {
  final String imagePath;
  final String title;
  final double cost;
  final int reviewCount;
  final Marker marker;

  Product(this.imagePath, this.title, this.cost, this.reviewCount, this.marker);
}

class _SnappingListState extends State<SnappingList> {
  int selectedIndex = -1; // Track selected card index
  List<Product> productList = [
    Product(
      'assets/images/black_chair.jpg',
      'Black Chair',
      90,
      15,
      Marker(
        point: LatLng(33.8869, 9.5375),
        child: Icon(
          Icons.place,
          color: Colors.green,
          size: 50,
        ),
      ),
    ),
    Product(
      'assets/images/blue_sofa.jpg',
      'Awesome Sofa',
      100,
      10,
      Marker(
        point: LatLng(33.8869, 15.5375),
        width: 80,
        height: 80,
        child: Icon(
          Icons.place,
          color: Colors.green,
          size: 50,
        ),
      ),
    ),
    // ... Add more products with their details and marker locations
  ];

  List<Marker> get markers => productList
      .map((product) => product.marker)
      .toList(); // Generate markers from products
  MyMapController mapController = MyMapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Listview with Snapping Effect"),
        ),
        body: Stack(children: [
          FlutterMap(
            mapController: mapController.mapController,
            options: const MapOptions(
              initialCenter: LatLng(33.8869, 9.5375),
              initialZoom: 7.0,
              // interactiveFlags: InteractiveFlag.none,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(markers: markers),
              // selectedIndex != -1 ? MarkerLayer(markers: markers) : Container(),
              // Show marker only if selected
            ],
          ),
          SizedBox(
            height: 250,
            child: ScrollSnapList(
              itemBuilder: _buildListItem,
              itemCount: productList.length,
              itemSize: 150,
              onItemFocus: (index) => setState(() {
                selectedIndex = index;
                mapController.moveTo(productList[selectedIndex].marker.point, 7.0);
              }),
              // Update selected index on focus
              dynamicItemSize: true,
            ),
          ),
        ]));
  }

  Widget _buildListItem(BuildContext context, int index) {
    Product product = productList[index];
    return GestureDetector(
      onTap: () {
        // Implement logic to show a bigger card here (e.g., navigate to a new screen)
        print("Card clicked at index: $index");
      },
      child: SizedBox(
        width: 150,
        height: 300,
        child: Card(
          elevation: 12,
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: Column(
              children: [
                Image.asset(
                  product.imagePath,
                  fit: BoxFit.cover,
                  width: 150,
                  height: 180,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  product.title,
                  style: const TextStyle(fontSize: 15),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.cost}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${product.reviewCount} Reviews',
                        style: const TextStyle(color: Colors.blue),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyMapController {
  MapController mapController = MapController();

  void moveTo(LatLng point, double zoom) {
    mapController.move(point, zoom);
  }
}
