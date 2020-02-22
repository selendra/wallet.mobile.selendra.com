import 'package:wallet_apps/src/http_request/rest_api.dart';
import 'package:wallet_apps/src/model/model_asset.dart';
import 'package:wallet_apps/src/model/model_login.dart';
import 'package:wallet_apps/src/model/model_signup.dart';
import 'package:wallet_apps/src/model/model_user_info.dart';
import 'package:wallet_apps/src/bloc/bloc_provider.dart';
import 'package:wallet_apps/src/screen/home_screen/profile_user_screen/activity_screen/activity.dart';
import 'package:wallet_apps/src/screen/home_screen/profile_user_screen/add_asset_screen/add_asset.dart';
import 'package:wallet_apps/src/screen/home_screen/profile_user_screen/change_password_screen/change_password.dart';
import 'package:wallet_apps/src/screen/home_screen/profile_user_screen/change_pin_screen/change_pin.dart';
import 'package:wallet_apps/src/screen/home_screen/profile_user_screen/private_key_dialog_screen/private_key_dialog.dart';
import 'package:wallet_apps/src/screen/home_screen/profile_user_screen/set_pin_code_dialog_screen/set_confirm_pin_code_dialog.dart';
import 'package:wallet_apps/src/screen/home_screen/profile_user_screen/set_pin_code_dialog_screen/set_pin_code_dialog.dart';
import 'package:wallet_apps/src/model/model_dashboard.dart';
import 'package:wallet_apps/src/screen/home_screen/transaction_history_screen/transaction_history_screen.dart';
import 'package:wallet_apps/src/screen/main_screen/sign_up_screen/user_info_screen/user_info.dart';
import 'package:wallet_apps/src/service/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
/* Directory of file */
import 'package:wallet_apps/src/provider/reuse_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wallet_apps/src/store_small_data/data_store.dart';
import './profile_user_body.dart';

class ProfileUser extends StatefulWidget{

  final Map<String, dynamic> _userData;

  ProfileUser(this._userData);

  @override
  State<StatefulWidget> createState() {
    return ProfileUserState();
  }
}

class ProfileUserState extends State<ProfileUser> {
  
  /* Variable */
  String error = '', _pin = '', _confirmPin = '';
  dynamic _result = ""; 
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final RefreshController _refreshController = RefreshController();
  ModelUserInfo _modelUserInfo = ModelUserInfo();
  Map<String, dynamic> _message;
  /* Login Inside Dialog */
  bool isProgress = false, isFetch = false, isTick = false, isSuccessPin = false, isHaveWallet = false;

  /* InitState */
  @override
  void initState() {
    setUserInfo();
    super.initState();
  }

  void setUserInfo() async {
    _modelUserInfo.userData = {
      "first_name": widget._userData['first_name'],
      "mid_name": widget._userData['mid_name'],
      "last_name": widget._userData['last_name'],
      "gender": widget._userData['gender'] == "M" ? "Male" : "Female",
      "label": "profile"
    };
    // _modelUserInfo.controlMidName.text = widget._userData['mid_name'];
    // _modelUserInfo.controlLastName.text = widget._userData['last_name'];
    // _modelUserInfo.genderLabel = widget._userData['gender'] == "M" ? "Male" : "Female";
    // _modelUserInfo.gender = widget._userData['gender'];
    await fetchData("user_token").then((_response){ /* Fetch Token To Concete Authorization Update Profile User Info */
      _modelUserInfo.token = _response['token'];
    });
  }

  Future<void> dialogBox(BuildContext context) async { /* Set PIN Dialog */
    _result = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: 
      _pin == '' ? /* If PIN Not Yet Set */
      (BuildContext context) {
        return Material(
          color: Colors.transparent,
          child: SetPinDialog(error)
        );
      } :
      _confirmPin == '' ? /* Set PIN Done And Then Set Confirm Pin */
      (BuildContext context) {
        return Material(
          color: Colors.transparent,
          child: SetConfirmPin(_pin),
        );
      } :
      (BuildContext context) { /* Comfirm PIN Success Shower Dialog Of Private Key */
        return Material(
          color: Colors.transparent,
          child: PrivateKeyDialog(_message),
        );
      }
    );
    /* From Set PIN Widget */
    if (_result != null) {
      if (_result['widget'] == 'Pin'){
        _pin = _result['pin'];
        /* CallBack */
        dialogBox(context);
      } else 
      /* From Set Confirm PIN Widget */
      if (_result['widget'] == 'confirmPin'){
        if (_result['compare'] == false) {
          _pin = '';
          error = "PIN does not match"; /* Set Error */
          dialogBox(context); /* CallBack */
        } else if (_result["compare"] == true){
          _confirmPin = _result['confirm_pin'];
          _message = _result;
          await Future.delayed(Duration(milliseconds: 200), () { /* Wait A Bit and Call DialogBox Function Again */
            dialogBox(context); /* CallBack */
          });
        }
      } else { /* Success Set PIN And Push SnackBar */
        _pin = ""; /* Reset Pin Confirm PIN And Result To Empty */
        _confirmPin = "";
        snackBar(_result['message']); /* Copy Private Key Success And Show Message From Bottom */
      }
    } else {
      _pin = ""; /* Reset Pin Confirm PIN And Result To Empty */
      _confirmPin = "";
    }
  }
  
  /* Function */
  void navigateEditProfile(){
    Navigator.pop(context, '');
    Navigator.push(context, transitionRoute(UserInfo(_modelUserInfo.userData)));
  } 

  void navigateTrxHistory() {
    Navigator.pop(context, '');
    Navigator.push(context, transitionRoute(TransactionHistoryWidget(widget._userData['wallet'])));
  }

  void navigateAcivity() { 
    Navigator.pop(context, '');
    Navigator.push(context, transitionRoute(Activity()));
  }

  void navigateGetWallet() async {
    await dialogBox(context); 
  }

  void navigateChangePIN() { 
    Navigator.push(context, transitionRoute(ChangePIN()));
  }

  void navigateChangePass() {
    Navigator.push(context, transitionRoute(ChangePassword()));
  }

  void navigateAddAssets() async {
    _result = await Navigator.push(context, transitionRoute(AddAsset()));
  }
  
  void signOut() async {
    dialogLoading(context);
    clearStorage();
    await Future.delayed(Duration(seconds: 1), () {
      Navigator.pop(context); /* Close Dialog Loading */
    });
    Navigator.pop(context, ''); /* Close Profile Screen */
    await Future.delayed(Duration(milliseconds: 100), () {
      Navigator.pushReplacementNamed(context, '/');
    });
  }

  /* ----------------------Side Bar -------------------------*/

  /* Trigger Snack Bar Function */
  void snackBar(String contents) {
    final snackbar = SnackBar(
      duration: Duration(seconds: 2),
      content: Text(contents),
    );
    _scaffoldKey.currentState.showSnackBar(snackbar);
  }
  
  void _reFresh() async {
    await Provider.fetchUserIds();
    _refreshController.refreshCompleted();
  }

  void popScreen() {
    Navigator.pop(context, _result);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      key: _scaffoldKey,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
        children: <Widget>[
          profileUserBodyWidget(
            isHaveWallet, 
            context, 
            _modelUserInfo.userData, 
            widget._userData['wallet'], 
            navigateEditProfile, navigateTrxHistory,
            navigateAcivity, navigateGetWallet, 
            navigateChangePIN, navigateChangePass,
            navigateAddAssets, signOut, 
            snackBar,  dialogBox, popScreen
          )
          // Expanded(
          //   child: SingleChildScrollView(
          //     child: 
          //     // SmartRefresher(
          //     //   physics: BouncingScrollPhysics(),
          //     //   controller: _refreshController,
          //     //   onRefresh: _reFresh,
          //     //   child: 
          //     // ),
          //   ),
          //   )
        ],
      ),
    ),
      );
  }
}