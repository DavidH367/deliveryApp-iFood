import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../global/global.dart';
import '../mainScreens/home_screen.dart';
import '../requestpermission/request_permission_controller.dart';
import '../requestpermission/request_permission_page.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/error_dialog.dart';
import '../widgets/loading_dialog.dart';
import 'package:delivery/requestpermission/request_permission_controller.dart';
import 'package:delivery/requestpermission/request_permission_controller.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);



  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}
TextEditingController locationController = TextEditingController();

getCurrentLocation() async {

  Position newPosition = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

  position = newPosition;

  placeMarks = await placemarkFromCoordinates(
    position!.latitude,
    position!.longitude,
  );

  Placemark pMark = placeMarks![0];

  completeAddress = '${pMark.subThoroughfare} ${pMark.thoroughfare}, ${pMark.subLocality} ${pMark.locality}, ${pMark.subAdministrativeArea}, ${pMark.administrativeArea} ${pMark.postalCode}, ${pMark.country}';

  locationController.text = completeAddress;
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _controller = RequestPermissionController(Permission.locationWhenInUse);
  late StreamSubscription _subscription;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();


  XFile? imageXFile;
  final ImagePicker _picker = ImagePicker();

  Position? position;
  List<Placemark>? placeMarks;

  String sellerImageUrl = "";
  String completeAddress = "";


  @override
  void initState(){
    super.initState();

  }



  Future<void> _getImage() async
  {
    imageXFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageXFile;
    });
  }

  requestperm()async {

    @override
    void initState(){
      super.initState();
      _controller.onStatusChanged.listen(
            (status){
          if(status == PermissionStatus.granted){
            Navigator.push(context, MaterialPageRoute(builder: (c)=> const RegisterScreen()));
          }
        },
      );
    }

    @override
    void dispose(){
      _subscription.cancel();
      _controller.dispose();
      super.dispose();
    }
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
            child: ElevatedButton(
              child: Text("Permitir"),
              onPressed: () { _controller.request(); },

            ),
          ) ,),
      );
    }


  }



  Future<void> formValidation() async
  {
    if(imageXFile == null)
    {
      showDialog(
        context: context,
        builder: (c)
        {
          return ErrorDialog(
            message: "Porfavor Seleccione una Imagen.",
          );
        }
      );
    }
    else
    {
      if(passwordController.text == confirmPasswordController.text)
      {
        if(confirmPasswordController.text.isNotEmpty && emailController.text.isNotEmpty && nameController.text.isNotEmpty && phoneController.text.isNotEmpty && locationController.text.isNotEmpty)
        {
          //start uploading image
          showDialog(
            context: context,
            builder: (c)
            {
              return LoadingDialog(
                message: "Registrando Cuenta",
              );
            }
          );

          String fileName = DateTime.now().millisecondsSinceEpoch.toString();
          fStorage.Reference reference = fStorage.FirebaseStorage.instance.ref().child("riders").child(fileName);
          fStorage.UploadTask uploadTask = reference.putFile(File(imageXFile!.path));
          fStorage.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
          await taskSnapshot.ref.getDownloadURL().then((url) {
            sellerImageUrl = url;

            //save info to firestore
            authenticateSellerAndSignUp();
          });
        }
        else
        {
          showDialog(
              context: context,
              builder: (c)
              {
                return ErrorDialog(
                  message: "Porfavor ingrese la informacion necesaria para Registrar.",
                );
              }
          );
        }
      }
      else
      {
        showDialog(
            context: context,
            builder: (c)
            {
              return ErrorDialog(
                message: "Las contraseñas no coinciden.",
              );
            }
        );
      }
    }
  }

  void authenticateSellerAndSignUp() async
  {
    User? currentUser;

    await firebaseAuth.createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    ).then((auth) {
      currentUser = auth.user;
    }).catchError((error){
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c)
          {
            return ErrorDialog(
              message: error.message.toString(),
            );
          }
      );
    });

    if(currentUser != null)
    {
      saveDataToFirestore(currentUser!).then((value) {
        Navigator.pop(context);
        //send user to homePage
      Route newRoute = MaterialPageRoute(builder: (c) => const HomeScreen());
       Navigator.pushReplacement(context, newRoute);
      });
    }
  }

  Future saveDataToFirestore(User currentUser) async
  {
    FirebaseFirestore.instance.collection("riders").doc(currentUser.uid).set({
      "riderUID": currentUser.uid,
      "riderEmail": currentUser.email,
      "riderName": nameController.text.trim(),
      "riderAvatarUrl": sellerImageUrl,
      "phone": phoneController.text.trim(),
      "address": completeAddress,
      "status": "approved",
      "earnings": 0.0,
      "lat": position!.latitude,
      "lng": position!.longitude,
    });

    //save data locally
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences!.setString("uid", currentUser.uid);
    await sharedPreferences!.setString("email", currentUser.email.toString());
    await sharedPreferences!.setString("name", nameController.text.trim());
    await sharedPreferences!.setString("photoUrl", sellerImageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(height: 10,),
            InkWell(
              onTap: ()
              {
                _getImage();
              },
              child: CircleAvatar(
                radius: MediaQuery.of(context).size.width * 0.20,
                backgroundColor: Colors.white,
                backgroundImage: imageXFile==null ? null : FileImage(File(imageXFile!.path)),
                child: imageXFile == null
                    ?
                Icon(
                  Icons.add_photo_alternate,
                  size: MediaQuery.of(context).size.width * 0.20,
                  color: Colors.grey,
                ) : null,
              ),
            ),
            const SizedBox(height: 10,),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    data: Icons.person,
                    controller: nameController,
                    hintText: "Nombre",
                    isObsecre: false,
                  ),
                  CustomTextField(
                    data: Icons.email,
                    controller: emailController,
                    hintText: "Correo",
                    isObsecre: false,
                  ),
                  CustomTextField(
                    data: Icons.lock,
                    controller: passwordController,
                    hintText: "Contraseña",
                    isObsecre: true,
                  ),
                  CustomTextField(
                    data: Icons.lock,
                    controller: confirmPasswordController,
                    hintText: "Confirmar Contraseña",
                    isObsecre: true,
                  ),
                  CustomTextField(
                    data: Icons.phone,
                    controller: phoneController,
                    hintText: "Telefono",
                    isObsecre: false,
                  ),
                  CustomTextField(
                    data: Icons.my_location,
                    controller: locationController,
                    hintText: "Mi direccion Actual",
                    isObsecre: false,
                    enabled: true,
                  ),
                  Container(
                    width: 400,
                    height: 40,
                    alignment: Alignment.center,
                    child: ElevatedButton.icon(
                      label: const Text(
                        "Obtener Mi Ubucacion Actual",
                        style: TextStyle(color: Colors.white),
                      ),
                      icon: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (c)=> const RequestPermissionPage()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30,),
            ElevatedButton(
              child: const Text(
                "Registrarse",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
              ),
              onPressed: ()
              {
                formValidation();
              },
            ),
             const SizedBox(height: 30,),
          ],
        ),
      ),
    );
  }
}
