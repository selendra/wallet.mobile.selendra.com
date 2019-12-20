import 'package:flutter/material.dart';
import 'package:wallet_apps/src/model/model_signup.dart';
import 'package:wallet_apps/src/provider/reuse_widget.dart';

Widget createPasswordBodyWidget(
  BuildContext context,
  ModelSignUp _modelSignUp,
  Function onChanged, Function popScreen, Function changeFocus, Function navigatePage
) {
  return Container(
    child: Column(
      children: <Widget>[
        containerAppBar( /* AppBar */
          context, 
          Row(
            children: <Widget>[
              iconAppBar( /* Arrow Back Button */
                Icon(Icons.arrow_back, color: Colors.white,),
                Alignment.centerLeft,
                EdgeInsets.all(0),
                popScreen,
              ),
              containerTitleAppBar("Create Password")
            ],
          )
        ),
        Expanded( /* Body */
          child: Container(
            margin: EdgeInsets.only(left: 27.0, right: 27.0,top: 27.0),
            child: Column(
              children: <Widget>[
                Container( /* Password Field */
                  margin: EdgeInsets.only(bottom: 12.0),
                  child: inputField(
                    _modelSignUp.bloc, 
                    context, "Password", null, "createPasswordScreen", 
                    true, 
                    TextInputType.text, TextInputAction.next, 
                    _modelSignUp.controlPasswords, 
                    _modelSignUp.nodePassword, 
                    onChanged, 
                    changeFocus
                  ),
                ),
                Container( /* Confirm Password Field */
                  margin: EdgeInsets.only(bottom: 12.0),
                  child: inputField(
                    _modelSignUp.bloc, 
                    context, "Confirm Password", null, "createPasswordScreen", 
                    true, 
                    TextInputType.text, TextInputAction.done, 
                    _modelSignUp.controlConfirmPasswords, 
                    _modelSignUp.nodeConfirmPasswords, 
                    onChanged, 
                    null
                  ),
                ),
                _modelSignUp.isMatch == false ? Container() : Text("Confirm password not match !", style: TextStyle(fontSize: 18.0, color: Colors.red),),
                customFlatButton( /* Button Request Code */
                  _modelSignUp.bloc,
                  context,
                  "Create Now", "signUpFirstScreen", greenColor,
                  FontWeight.normal,
                  size18,
                  EdgeInsets.only(top: size10, bottom: size10),
                  EdgeInsets.only(top: size15, bottom: size15),
                  BoxShadow(
                    color: Color.fromRGBO(0,0,0,0.54),
                    blurRadius: 5.0
                  ),
                  navigatePage
                )
              ],
            ),
          ),
        )
      ],
    ),
  );
}