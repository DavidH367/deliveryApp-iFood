import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery/mainScreens/history_screen.dart';
import 'package:delivery/mainScreens/not_yet_delivered_screen.dart';
import 'package:delivery/mainScreens/parcel_in_progress_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../assistanMethods/assistant_methods.dart';
import '../assistanMethods/get_current_location.dart';
import '../authentication/auth_screen.dart';
import '../global/global.dart';
import '../splashScreen/splash_screen.dart';
import 'earnings_screen.dart';
import 'new_orders_screen.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}



class _HomeScreenState extends State<HomeScreen> {

  Card makeDashboardItem(String title, IconData iconData,int index ){

    return Card(
      elevation:2,
      margin: const EdgeInsets.all(8),
      child: Container(
          decoration: index == 0 || index == 3  || index == 4
              ? const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.amber,
                  Colors.cyan,
                ],
                begin:  FractionalOffset(0.0, 0.0),
                end:  FractionalOffset(1.0, 0.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp,
              )
          )
              : const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.redAccent,
                  Colors.amber,
                ],
                begin:  FractionalOffset(0.0, 0.0),
                end:  FractionalOffset(1.0, 0.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp,
              )
          ),
        child: InkWell(
          onTap: (){
            if(index == 0){
              //ordenes nuevas
              Navigator.push(context, MaterialPageRoute(builder:(c)=>  NewOrdersScreen()));
            }
            if(index == 1){
              //ordenes en progreso
              Navigator.push(context, MaterialPageRoute(builder:(c)=>  ParcelInProgressScreen()));
            }
            if(index == 2){
              //No entregados
              Navigator.push(context, MaterialPageRoute(builder:(c)=>  NotYetDeliveredScreen()));
            }
            if(index == 3){
              //hostorial de pedidos realizados
              Navigator.push(context, MaterialPageRoute(builder:(c)=>  HistoryScreen()));

            }
            if(index == 4){
              //Ganancias
              Navigator.push(context, MaterialPageRoute(builder:(c)=>  EarningsScreen()));
            }
            if(index == 5){
              //Cerrar Sesion
              firebaseAuth.signOut().then((value){
                Navigator.push(context, MaterialPageRoute(builder:(c)=> const AuthScreen()));
              });
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            verticalDirection: VerticalDirection.down,
            children:[
              const SizedBox(height: 50.0),
              Center(
                child: Icon(
                  iconData,
                  size:4,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10.0),
              Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ]
          ),
        ),
      ),
    );
  }

  restrictBlockedRidersFromUsingApp() async{
    await FirebaseFirestore.instance.collection("riders")
        .doc(firebaseAuth.currentUser!.uid)
        .get().then((snapshot){
      if(snapshot.data()!["status"] != "approved"){
        Fluttertoast.showToast(msg: "Ha sido bloqueado.");
        firebaseAuth.signOut();
        Navigator.push(context, MaterialPageRoute(builder: (c)=> MySplashScreen()));
      }else{
        UserLocation uLocation= UserLocation();
        uLocation.getCurrentLocation();
        getPerParcelDeliveryAmount();
        getRiderPreviousEarnings();
      }
    });
  }

  @override
  void initState() {

    super.initState();
    restrictBlockedRidersFromUsingApp();
  }

  getRiderPreviousEarnings(){
    FirebaseFirestore.instance
        .collection("riders")
        .doc(sharedPreferences!.getString("uid"))
        .get().then((snap){
      previousRiderEarnings = snap.data()!["earnings"].toString();
    });
  }

  getPerParcelDeliveryAmount(){
    FirebaseFirestore.instance
        .collection("perDelivery")
        .doc("proceso001")
        .get().then((snap){
          perParcelDeliveryAmount = snap.data()!["amount"].toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.cyan,
                  Colors.amber,
                ],
                begin:  FractionalOffset(0.0, 0.0),
                end:  FractionalOffset(1.0, 0.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp,
              )
          ),
        ),
        title: Text(
          "Bienvenido "+
          sharedPreferences!.getString("name")!,
    style: const TextStyle(
    fontSize: 25,
    color: Colors.black54,
    fontFamily: "Signatra",
    letterSpacing: 2,
        ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 1),
        child: GridView.count(
               crossAxisCount: 2,
          padding: const EdgeInsets.all(2),
            children: [
              makeDashboardItem("Nuevos pedidos disponibles", Icons.assessment, 0),
              makeDashboardItem("Paquete en Curso", Icons.airport_shuttle, 1),
              makeDashboardItem("Nuevos pedidos disponibles", Icons.location_history, 2),
              makeDashboardItem("Historial", Icons.done_all, 3),
              makeDashboardItem("Total Ganancias", Icons.monetization_on, 4),
              makeDashboardItem("Cerrar Sesion", Icons.logout, 5),
            ],

        ),
      ),
    );
  }
}
