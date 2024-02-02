import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:users_app/authentication/login_screen.dart';
import 'package:users_app/global/global_var.dart';
import 'package:users_app/methods/common_methods.dart';
import 'package:users_app/pages/search_destination_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double searchContainerHeight = 276;
  double bottomMapPadding = 0;
  final Completer<GoogleMapController> googleMapCompleterController = Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  Position? currentPositionOfUser;
  
  CommonMethods commonMethods = CommonMethods();

  //to open the drawer we need a scaffoldKey
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();

  void updateMapTheme(GoogleMapController controller){
    getJsonFileFromThemes("themes/night_style.json").then((value) => setGoogleMapStyle(value,controller));
    
  }

  setGoogleMapStyle(String googleMapStyle, GoogleMapController controller){
      controller.setMapStyle(googleMapStyle);
  }

  //to set mapStyle we need to get the theme of google map from the address of "mapstyle.withgoogle.com" and then we need to convert them as byte form and then pass to google map
  Future<String> getJsonFileFromThemes(String mapStylePath) async{
    ByteData byteData = await rootBundle.load(mapStylePath);
    var list = byteData.buffer.asUint8List(byteData.offsetInBytes,byteData.lengthInBytes);
    return utf8.decode(list);
  }

  getCurrentLiveLocationOfUser()async{
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionOfUser = position;

   LatLng positionOfUser = LatLng(currentPositionOfUser!.latitude,currentPositionOfUser!.longitude);
   CameraPosition cameraPosition = CameraPosition(target: positionOfUser,zoom: 15);
   controllerGoogleMap!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

   await CommonMethods.convertGeographicConOrdinatesIntoHumanReadable(currentPositionOfUser!, context);

   await getUserInfoAndCheckBlockStatus();
    print('My name is: $userName');
  }

  getUserInfoAndCheckBlockStatus()async{
    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("users").child(FirebaseAuth.instance.currentUser!.uid);
    await usersRef.once().then((snap){
      if(snap.snapshot.value != null){
          if((snap.snapshot.value as Map)["blockStatus"]=="no"){
            //Without setState, the new userName value might be updated internally, but the UI wouldn't be aware of the change
            setState(() {
              userName = (snap.snapshot.value as Map)["name"].toString();

            });

          }else{
            FirebaseAuth.instance.signOut();
            Navigator.push(context, MaterialPageRoute(builder: (c)=>const LoginScreen()));
            commonMethods.displaySnackBar("You're blocked. Please contact with: bappimatubber1997@gmail.com", context);
          }
      }else{
        FirebaseAuth.instance.signOut();
        Navigator.push(context, MaterialPageRoute(builder: (c)=>const LoginScreen()));

      }
    });
    
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      key: sKey,
      drawer: Container(
        width: 255,
        color: Colors.black87,
        child: Drawer(
          backgroundColor: Colors.white10,
          child: ListView(
            children: [
              Container(
                color: Colors.black,
                height: 160,
                child:  DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.black
                  ),
                  child: Row(
                    children: [
                      //Icon(Icons.person,size: 60,),
                      Image.asset("assets/images/avatarwoman.webp",width: 60,height: 60,),
                      SizedBox(width: 16,),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(userName,style: TextStyle(fontSize: 16,color: Colors.white,fontWeight: FontWeight.bold,),),
                          Text("Profile",style: TextStyle(fontSize: 16,color: Colors.white),)

                        ],
                      )
                    ],
                  ),
                ),
              ),
              const Divider(
                height: 1,
                color: Colors.white,
                thickness: 1,
              ),
              SizedBox(height: 10,),
              //body
              ListTile(
                leading: IconButton(
                  onPressed: (){},
                  icon: Icon(Icons.info,color: Colors.grey,),
                ),
                title: Text("About",style: TextStyle(color: Colors.grey),),
              ),
              GestureDetector(
                onTap: (){
                  FirebaseAuth.instance.signOut();
                  Navigator.push(context, MaterialPageRoute(builder: (c)=>const LoginScreen()));
                },
                child: ListTile(
                  leading: IconButton(
                    onPressed: (){},
                    icon: Icon(Icons.logout,color: Colors.grey,),
                  ),
                  title: Text("Logout",style: TextStyle(color: Colors.grey),),
                ),
              )
            ],
          ),
        ),
      ),
      //here Stack widget is used to overlap one widget after like Google map and top is drawer menu
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(top: 30,bottom: bottomMapPadding),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: googlePlexCameraPosition,
            onMapCreated: (GoogleMapController mapController) {
              controllerGoogleMap = mapController;
              updateMapTheme(controllerGoogleMap!);
              googleMapCompleterController.complete(controllerGoogleMap);

              setState(() {
                bottomMapPadding = 100;
              });
              getCurrentLiveLocationOfUser();
            }
          ),

          //drawer button
          Positioned(top: 35,left: 18,child: GestureDetector(
            onTap: (){
              sKey.currentState!.openDrawer();
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow:const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    spreadRadius: 0.5,
                    offset: Offset(0.7,0.7)
                  )
                ]
              ),
              child: const CircleAvatar(
                backgroundColor: Colors.grey,
                radius: 20,
                child: Icon(
                  Icons.menu,
                  color: Colors.black87,
                ),
              ),
            ),
          ),),
          Positioned(left:0,right:0,bottom:-80,child: Container(
            height: searchContainerHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(style:ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  shape:const CircleBorder(),//this shape property will responsible for making the button as circle
                  padding: const EdgeInsets.all(24)
                ),onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (c)=>SearchDestinationPage()));
                }, child: const Icon(Icons.search)),
                ElevatedButton(style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(24)
                ),onPressed: (){}, child:const Icon(Icons.home)),
                ElevatedButton(style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(24)
                ),onPressed: (){}, child: const Icon(Icons.work))
              ],
            ),
          ))
        ],
      ),
    );
  }
}
