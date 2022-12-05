import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery/splashScreen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../assistanMethods/get_current_location.dart';
import '../global/global.dart';
import '../maps/map_utils.dart';

class ParcelDeliveringScreen extends StatefulWidget
{
String? purchaserId;
String? purchaserAddress;
double? purchaserLat;
double? purchaserLng;
String? sellerId;
String? getOrderId;


ParcelDeliveringScreen({
  this.purchaserId,
  this.purchaserAddress,
  this.purchaserLat,
  this.purchaserLng,
  this.sellerId,
  this.getOrderId,

});

  @override
  State<ParcelDeliveringScreen> createState() => _ParcelDeliveringScreenState();
}

class _ParcelDeliveringScreenState extends State<ParcelDeliveringScreen> {
String orderTotalAmount = "";


  confirmParcelHasBeenDelivered(getOrderId, sellerId, purchaserId, purchaserAddress, purchaserLat, purchaserLng) {
    String riderNewTotalEarningAmount = ((double.parse(previousRiderEarnings)) + (double.parse(perParcelDeliveryAmount))).toString();

    FirebaseFirestore.instance.collection("orders").doc(getOrderId).update({
      "status": "ended",
      "address": completeAddress,
      "lat": position!.latitude,
      "lng": position!.longitude,
      "earnings" : riderNewTotalEarningAmount,//pago por la entrega
    }).then((value){
      FirebaseFirestore.instance
          .collection("riders")
          .doc(sharedPreferences!.getString("uid"))
          .update({
        "earnings": perParcelDeliveryAmount, //total de ganancias de los motoristas
      });
    }).then((value){
      FirebaseFirestore.instance
          .collection("sellers")
          .doc(widget.sellerId)
          .update({
        "earnings": (double.parse(orderTotalAmount) + (double.parse(previousEarnings))).toString(), //total de ganancias de los vendedores
      });
    }).then((value) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(purchaserId)
          .collection("orders")
          .doc(getOrderId).update({
            "status": "ended",
            "riderUID": sharedPreferences!.getString("uid"),
          });
    });

    Navigator.push(context, MaterialPageRoute(builder: (c)=> const MySplashScreen()));
  }

  getOrderTotalAmount(){
    FirebaseFirestore.instance
        .collection("orders")
        .doc(widget.getOrderId)
        .get()
        .then((snap){
      orderTotalAmount = snap.data()!["totalAmount"].toString();
       widget.sellerId = snap.data()!["sellerUID"].toString();
    }).then((value){
      getSellerData();
    });
  }

  getSellerData(){
    FirebaseFirestore.instance
        .collection("orders")
        .doc(widget.getOrderId)
        .get()
        .then((snap){
       previousEarnings = snap.data()!["earnings"].toString();
    });
  }

  @override
  void initState(){
    super.initState();
    UserLocation uLocation = UserLocation();
    uLocation.getCurrentLocation();

    getOrderTotalAmount();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "Images/confirm2.png",
            //width: 350,
          ),
          const SizedBox(
            height: 5,
          ),
          GestureDetector(
            onTap: () {
              MapUtils.lauchMapFromSourceToDestination(position!.latitude, position!.longitude, widget.purchaserLat, widget.purchaserLng);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "images/restaurant.png",
                  width: 50,
                ),
                const SizedBox(
                  height: 7,
                ),
                Column(
                  children: const [
                    const SizedBox(
                      height: 13,
                    ),
                    Text(
                      "Ver ubicacion de entrega",
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: "Signatra",
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: InkWell(
                onTap: () {
                  // Navigator.push(
                  //    context,
                  //   MaterialPageRoute(
                  //     builder: (context) => const MySplashScreen()));
                  UserLocation uLocation = UserLocation();
                  uLocation.getCurrentLocation();

                  confirmParcelHasBeenDelivered(
                      widget.getOrderId,
                      widget.sellerId,
                      widget.purchaserId,
                      widget.purchaserAddress,
                      widget.purchaserLat,
                      widget.purchaserLng);
                },
                child: Container(
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.cyan,
                          Colors.amber,
                        ],
                        begin: FractionalOffset(0.0, 0.0),
                        end: FractionalOffset(1.0, 0.0),
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp,
                      )),
                  width: MediaQuery.of(context).size.width - 90,
                  height: 50,
                  child: const Center(
                    child: Text(
                      "El pedido ha sido Enviado",
                      style: TextStyle(color: Colors.white, fontSize: 15.0),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
