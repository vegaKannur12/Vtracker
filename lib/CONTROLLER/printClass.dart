import 'dart:async';

import 'package:flutter/material.dart';
import 'package:location2/COMPONENTS/custom_snackbar.dart';
import 'package:location2/COMPONENTS/external_dir.dart';
import 'package:location2/COMPONENTS/network_connectivity.dart';
import 'package:location2/MODAL/registration_model.dart';
import 'package:location2/authentication/login.dart';
import 'package:location2/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PrintController extends ChangeNotifier {
  List label_list = [];
  List config_data = [];
  List detail_data = [];
  String dynamic_code = "";
  bool isprofileLoading = false;

  var isScanning = false;
  var isBle = true;
  var isConnected = false;
  bool connectLoading = false;
  bool isLoginLoading = false;
  String label_name = "";

  String comname = "CFC KANNUR";

  String profile_string = '';
  bool isdownloaded = false;
  String seldeviceName = "";
  //variables for reg & login
  String? fp;
  String? cid;
  ExternalDir externalDir = ExternalDir();
  String? sof;
  bool isLoading = false;
  String? appType;
  String? cname;
  List<CD> cD = [];
  List locHistryList = [];
  bool histryLoad = false;

  Future<RegistrationData?> postRegistration(
      String companyCode,
      String? fingerprints,
      String phoneno,
      String deviceinfo,
      BuildContext context) async {
    // NetConnection.networkConnection(context).then((value) async {
    // ignore: avoid_print
    print("Text fp...$fingerprints---$companyCode---$phoneno---$deviceinfo");
    // ignore: prefer_is_empty
    if (companyCode.length >= 0) {
      appType = companyCode.substring(10, 12);
    }
    // if (value == true) {
    try {
      print("hai");
      Uri url = Uri.parse("https://trafiqerp.in/order/fj/get_registration.php");
      Map body = {
        'company_code': companyCode,
        'fcode': fingerprints,
        'deviceinfo': deviceinfo,
        'phoneno': phoneno
      };
      // ignore: avoid_print
      print("register body----$body");
      isLoading = true;
      notifyListeners();
      http.Response response = await http.post(
        url,
        body: body,
      );
      // print("body $body");
      var map = jsonDecode(response.body);
      // ignore: avoid_print
      print("regsiter map----$map");
      RegistrationData regModel = RegistrationData.fromJson(map);

      sof = regModel.sof;
      fp = regModel.fp;
      String? msg = regModel.msg;

      if (sof == "1") {
        if (appType == 'TQ') {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          /////////////// insert into local db /////////////////////
          String? fp1 = regModel.fp;

          // ignore: avoid_print
          print("fingerprint......$fp1");
          prefs.setString("fp", fp!);
          if (map["os"] == null || map["os"].isEmpty) {
            isLoading = false;
            notifyListeners();
            CustomSnackbar snackbar = CustomSnackbar();
            snackbar.showSnackbar(context, "Series is Missing", "");
          } else {
            cid = regModel.cid;
            prefs.setString("cid", cid!);

            cname = regModel.c_d![0].cnme;

            prefs.setString("cname", cname!);
            prefs.setString("os", regModel.os!);

            // ignore: avoid_print
            print("cid----cname-----$cid---$cname");
            notifyListeners();

            await externalDir.fileWrite(fp1!);

            // ignore: duplicate_ignore
            for (var item in regModel.c_d!) {
              // ignore: avoid_print
              print("ciddddddddd......$item");
              cD.add(item);
            }
            // verifyRegistration(context, "");

            isLoading = false;
            notifyListeners();

            // await JeminiBorma.instance.deleteFromTableCommonQuery("companyRegistrationTable", "");                // ignore: use_build_context_synchronously
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          }
        } else {
          isLoading = false;
          notifyListeners();
          CustomSnackbar snackbar = CustomSnackbar();
          // ignore: use_build_context_synchronously
          snackbar.showSnackbar(context, "Invalid Apk Key", "");
        }
      }
      /////////////////////////////////////////////////////
      if (sof == "0") {
        isLoading = false;
        notifyListeners();
        CustomSnackbar snackbar = CustomSnackbar();
        // ignore: use_build_context_synchronously
        snackbar.showSnackbar(context, msg.toString(), "");
      }

      notifyListeners();
    } catch (e) {
      // ignore: avoid_print
      print(e);
      return null;
    }
    // }
    // else
    // {
    //   print("erroooooooooo");
    // }
    // });
    return null;
  }

  getLogin(String userName, String password, BuildContext context) async {
    try {
      isLoginLoading = true;
      notifyListeners();
      SharedPreferences prefs = await SharedPreferences.getInstance();

      if (userName == "" || password == "") {
        CustomSnackbar snackbar = CustomSnackbar();
        // ignore: use_build_context_synchronously
        snackbar.showSnackbar(context, "Enter Username or Password", "");
        isLoginLoading = false;
        notifyListeners();
      } else {
        prefs.setString("st_uname", userName);
        prefs.setString("st_pwd", password);
        // ignore: use_build_context_synchronously
        // initDb(context, "from login");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      }
      isLoginLoading = false;
      notifyListeners();
    } catch (e) {
      // ignore: avoid_print
      print(e);
      return null;
    }
  }

  location(String place, String datetime, String datetoday,String street,String local,String post,String adminarea,String cntry,String hash,
  String isocode,String name,String subadmin,String sublocal,String lati,String longi,String activity,
      BuildContext context) async {
    // NetConnection.networkConnection(context).then((value) async {
    //   if (value == true) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? fp = prefs.getString("fp");
    String? uid = prefs.getString("st_uname");

    try {
      Uri url = Uri.parse("https://trafiqerp.in/rapi/save_loct.php");
      Map body = {
        'location_info': place,
        'user_id': uid,
        'device_info': fp,
        'l_date': datetime,
        'Street':street,
        'Locality':local,
        'PostalCode':post,
        'AdministrativeArea':adminarea,
        'Country':cntry,
        'HashCode':hash,
        'ISOCountryCode':isocode,
        'Name':name,
        'SubAdministrativeArea':subadmin,
        'SubLocality':sublocal,
        'latitude':lati,
        'longitude':longi,
        'activity':activity,
        
      };
      // ignore: avoid_print
      print("loc body----$body");
      isLoading = true;
      notifyListeners();
      http.Response response = await http.post(
        url,
        body: body,
      );
      // print("body $body");
      var map = jsonDecode(response.body);
      // ignore: avoid_print
      print("location map----$map");
      await locationHistory(datetoday, context);
      notifyListeners();
    } 
    catch (e) {
      // ignore: avoid_print
      print(e);
      return null;
    }
  }

  locationHistory(String date, BuildContext context) async {
    // NetConnection.networkConnection(context).then((value) async {
    //   if (value == true) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? fp = prefs.getString("fp");
    String? uid = prefs.getString("st_uname");
    locHistryList.clear();
    notifyListeners();
    try {
      histryLoad = true;
      notifyListeners();
      Uri url = Uri.parse("https://trafiqerp.in/rapi/get_loct.php");
      Map body = {
        'l_date': date,
        'fp': fp
        // '25-04-2024'
      };
      // ignore: avoid_print
      print("lochistry body----$body");
      isLoading = true;
      notifyListeners();
      http.Response response = await http.post(
        url,
        body: body,
      );
      // print("body $body");
      var map = jsonDecode(response.body);
      // ignore: avoid_print
      print("lochistry map----$map");
      for (var item in map) {
        locHistryList.add(item);
      }
      histryLoad = false;
      notifyListeners();
    } catch (e) {
      // ignore: avoid_print
      print(e);
      return null;
    }
  }
  //   });
  //   return null;
  // }

  ///////////////////////////////////////////////////////////////////////////
}
