import 'package:local_auth/local_auth.dart';
import 'package:wallet_apps/index.dart';

class FingerPrint extends StatefulWidget {
  
  FingerPrint();
  @override
  _FingerPrintState createState() => _FingerPrintState();
}

class _FingerPrintState extends State<FingerPrint> {

  Widget screen = Welcome();

  GetRequest _getRequest = GetRequest();

  Backend _backend = Backend();

  final localAuth = LocalAuthentication();

  bool _hasFingerPrint = false;

  String authorNot = 'Not Authenticate';

  List<BiometricType> _availableBio = List<BiometricType>();

  @override
  void initState() {
    checkExpiredToken();
    authenticate();
    super.initState();
  }

  Future<void> checkBioSupport() async {
    bool hasFingerPrint = false;
    try{
      hasFingerPrint = await localAuth.canCheckBiometrics;
    } on  PlatformException catch (e){
      print (e);
    }
    if (!mounted) return;
    setState(() {
      _hasFingerPrint = hasFingerPrint;
    });
  }

  Future<void> getBioList() async {
    List<BiometricType> availableBio = List<BiometricType>();
    try{
      availableBio = await localAuth.getAvailableBiometrics();
    } on  PlatformException catch (e){
      print (e);
    }
    if (!mounted) return;
    setState(() {
      _availableBio = availableBio;
    });
  }

  Future<void> authenticate() async {
    
    bool authenticate = false;

    try {
      authenticate = await localAuth.authenticateWithBiometrics(
        localizedReason: '',
        useErrorDialogs: true,
        stickyAuth: true
      );
    } on PlatformException catch (e){ }

    if (authenticate) {
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => screen)
      );
    }

  }

  void checkExpiredToken() async { /* Check For Previous Login */
    try {
      _backend.response = await _getRequest.checkExpiredToken();
      // Convert String To Object
      _backend.mapData = json.decode(_backend.response.body);
      // Check Expired Token
      if (_backend.response.statusCode == 200) {
        screen = Dashboard();
      } 
      // Reset isLoggedIn True -> False Cause Token Expired
      else if (_backend.response.statusCode== 401) {
        await dialog(context, Text('${_backend.mapData['message']}'), Text("Message"));
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => Login())
        );
      }
    } catch (err) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: scaffoldBGDecoration(
        top: 0.0, left: 0.0, right: 0.0, bottom: 0.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.lock, color: Colors.white),
            Text("Authentication Required")
          ],
        )
      )
    );
  }
}
