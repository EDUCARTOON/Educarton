import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_3/core/app_constant.dart';
import 'package:flutter_application_3/core/app_shared_variables.dart';
import 'package:flutter_application_3/core/cache_helper.dart';
import 'package:flutter_application_3/features/auth/data/models/sign_up_model.dart';

abstract class IAuthDatasource {
  Future<String> signIn({required email, required password});
  Future<RegisterModel> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String image,
  });
  Future<RegisterModel> getUserData({required String uid});
}

class RemoteDataSource implements IAuthDatasource {
  final user = FirebaseAuth.instance;

  @override
  Future<String> signIn({required email, required password}) async {
    log("email $email password $password");
    String? token;
    await user
        .signInWithEmailAndPassword(email: email, password: password)
        .then((value) {
      token = value.user?.uid;
      //  CacheHelper.saveData(key: 'UID', value:value.user?.uid);
    });
    return token ?? '';
  }

  @override
  Future<RegisterModel> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String image,
  }) async {
    RegisterModel? registerModel;
    await user
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((value) {
      log('user id --------------${value.user?.uid}');
      registerModel = RegisterModel(
          firstName: firstName,
          lastName: lastName,
          email: email,
          uId: uid,
          image: image,
          );
      uid = value.user?.uid ?? '';
      createUser(
        uId: value.user?.uid ?? '',
        registerModel: registerModel!,
      );
    });
    return registerModel!;
  }

  void createUser(
      {required String uId, required RegisterModel registerModel}) async {
        log('uid $uId  ---- $registerModel -- -- ${registerModel}');
    await FirebaseFirestore.instance
        .collection(AppConstant.kUsers)
        .doc(uId)
        .set(registerModel.toMap());
    // await FirebaseFirestore.instance
    //     .collection(AppConstant.kUsers)
    //     .doc(uId)
    //     .update({'uid': uId});
  }

  @override
  Future<RegisterModel> getUserData({required uid}) async {
    RegisterModel? userData;
    await FirebaseFirestore.instance
        .collection(AppConstant.kUsers)
        .doc(uid)
        .get()
        .then((value) {
      userData = RegisterModel.fromJson(json: value.data());
      userImage = userData?.image ?? '';
    });
    return userData!;
  }
}
