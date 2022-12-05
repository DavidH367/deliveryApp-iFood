import 'package:flutter/material.dart';

class ShipmentScreen extends StatefulWidget {

  String? purchaserId;
  String? sellerId;
  String? getOrderID;
  String? purchaserAddress;
  double? purchaserLat;
  double? purchaserLng;

  ShipmentScreen({
    this.purchaserId,
    this.sellerId,
    this.getOrderID,
    this.purchaserAddress,
    this.purchaserLat,
    this.purchaserLng,
});

  @override
  State<ShipmentScreen> createState() => _ShipmentScreenState();
}

class _ShipmentScreenState extends State<ShipmentScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Image.asset(
      "images/confirm1.png",
        width: 350,
      ),

          const SizedBox(height: 5,),

          GestureDetector(
            onTap: (){
              },
            child : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/restaurant.png',
                    width: 50,
                  ),

                  const SizedBox(width: 7,),

                  Column(
                    children: const [
                       SizedBox(height: 12,),

                       Text(
                          "Mostrar ubicacion de restaurante/cafe",
                        style: TextStyle(
                          fontFamily: "Signatra",
                          fontSize: 18,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ),
        ],
      ),
    );
  }
}
