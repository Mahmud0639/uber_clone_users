import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;


getInfoData(String data) async{
   http.Response responseData =await http.get(Uri.parse(data));
   try{
     if(responseData.statusCode==200){
       String res = responseData.body;
       var decodedData = jsonDecode(res);
       return decodedData;
     }else{
       return "error";
     }
   }catch(errorMsg){
     return "error";
   }

}

Future<String> convertGeographicCoordiateIntoHumanReadable(Position position,BuildContext context) async{
  String mapUri = "https://maps.googleapis.com/maps/api/geocode/json?${position.latitude},${position.longitude}&key=AIzaSyDuDxriw8CH8NbVLiXtKFQ2Nb64AoRSdyg";
  var myJson =  await getInfoData(mapUri);
  String myAddress = "";

  if(myJson != "error"){
     myAddress = myJson["results"][0]["formatted_address"];
    print('My current location is: $myAddress');
  }
  return myAddress;

}