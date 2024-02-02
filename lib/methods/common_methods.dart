import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:users_app/global/global_var.dart';
import 'package:http/http.dart' as http;

class CommonMethods{
  checkConnectivity(BuildContext context)async{
    var connectionResult = await Connectivity().checkConnectivity();

    if(connectionResult != ConnectivityResult.mobile && connectionResult != ConnectivityResult.wifi){
        if(!context.mounted) return;
        displaySnackBar("Your internet is not working.Check your connection and try again.", context);
    }
  }
  displaySnackBar(String message,BuildContext context){
    var snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }


  static sendRequestToAPI(String apiUrl)async{
    http.Response responseFromApi = await http.get(Uri.parse(apiUrl));

    try{
      if(responseFromApi.statusCode == 200){
        String dataFromApi = responseFromApi.body;
        var dataDecoded = jsonDecode(dataFromApi);//get data as json format from String format using the jsonDecode() method
        return dataDecoded;
      }else{
        return "error";//if the correct desired data won't come from server then it will return the error as response
      }
    }catch(errorMsg){
      return "error";
    }

  }


  //here we will use reverse geocoding that converts the Latitude-Longitude into Human readable
  static Future<String> convertGeographicConOrdinatesIntoHumanReadable(Position position, BuildContext context) async{
      String apiGeoCodingUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$googleMapKey";
      String humanReadableAddress = "";

     var responseFromApi = await sendRequestToAPI(apiGeoCodingUrl);
     if(responseFromApi != "error"){
          humanReadableAddress = responseFromApi["results"][0]["formatted_address"];
          print('My current location is: $humanReadableAddress');
     }
     return humanReadableAddress;
  }
}