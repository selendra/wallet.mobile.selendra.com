import 'package:wallet_apps/index.dart';

class MySplashScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return MySplashScreenState();
  }
}

class MySplashScreenState extends State<MySplashScreen>{

  GetRequest _getRequest = GetRequest();

  Backend _backend = Backend();

  FlareControls _flareControls = FlareControls();

  @override
  initState(){
    checkBiometric();
    checkExpiredToken();
    super.initState();
  }

  void checkBiometric() async {
    try{
      await StorageServices.fetchData('biometric').then((value) {
        print(value);
        // value == null whenever User Not Yet Login Or User Logged Out
        if (value != null){
          if (value['bio'] == true){
            Navigator.pushReplacement(
              context, 
              MaterialPageRoute(builder: (context) => FingerPrint())
            );
          }
        } 
        else {
          navigator();
        }
      });
    } catch (e) {
      await dialog(context, Text("$e", textAlign: TextAlign.center), "Message");
    }
  }

  // Check For Previous Login
  void checkExpiredToken() async { 
    try {
      _backend.mapData = await StorageServices.fetchData("user_token");
    } catch (err) {}
  }

  Future<void> navigator() async {
    if (_backend.mapData != null) {
      // Get Request To Check Expired Token
      _backend.response = await _getRequest.checkExpiredToken();
      _backend.mapData = json.decode(_backend.response.body);
      // Check Expired Token
      if (_backend.response.statusCode == 200) { 
        await Future.delayed(Duration(seconds: 4), (){
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (context) => Dashboard())
          );
        });
      }
      // Reset isLoggedIn True -> False Cause Token Expired 
      else if (_backend.response.statusCode == 401) {
        await dialog(context, Text("${_backend.mapData['message']}"), Text("Message"));
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => Login())
        );
      }
    } else {
      // No Previous Login Or Token Expired
      await Future.delayed(Duration(seconds: 4), (){
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => Welcome())
        );
      });
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getHexaColor(AppColors.bgdColor),
      body: Align(
        alignment: Alignment.center,
        child: Container(
          width: 200.0,
          height: 200.0,
          child: Image.asset('assets/images/sld_logo.png', color: Colors.white,)
          // CustomAnimation.flareAnimation(_flareControls, "assets/animation/splash_screen.flr", "splash_screen"),
        )
      )
    );
  }
}
