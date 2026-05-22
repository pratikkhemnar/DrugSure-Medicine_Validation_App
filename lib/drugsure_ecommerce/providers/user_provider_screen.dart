import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drugsuremva/drugsure_ecommerce/providers/userViweModel.dart';
import 'package:flutter/cupertino.dart';

import '../models/user_model.dart';

class UserProvider extends ChangeNotifier{

  UserViewModel userViewModel = UserViewModel();

  StreamSubscription<DocumentSnapshot>? userStreamSubscription;

  String nameOfUser = "";
  String emailOfUser = "";
  String addressOfUser = "";
  String phoneNumberOfUser = "";

  UserProvider(){
    getUserData();
  }

  getUserData(){
    userStreamSubscription?.cancel();

    userStreamSubscription = userViewModel.retrieveUserData().listen((dataSnapshot){
      final UserModel userData = UserModel.fromJson(dataSnapshot.data() as Map<String , dynamic >);
      nameOfUser = userData.name;
      emailOfUser = userData.email;
      addressOfUser = userData.address;
      phoneNumberOfUser = userData.phone;

      notifyListeners();
    });
  }

  declineProvider(){
    userStreamSubscription?.cancel();

     nameOfUser = "";
     emailOfUser = "";
     addressOfUser = "";
     phoneNumberOfUser = "";

     notifyListeners();
  }

  @override
  void dispose(){
    userStreamSubscription?.cancel();

    super.dispose();
  }

}
