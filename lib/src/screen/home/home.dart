import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wallet_apps/index.dart';

class Home extends StatefulWidget {
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> with TickerProviderStateMixin {
  
  MenuModel menuModel = MenuModel();

  HomeModel _homeModel = HomeModel();
  
  PostRequest _postRequest = PostRequest();

  GetRequest _getRequest = GetRequest();

  Backend _backend = Backend();

  PackageInfo _packageInfo;

  PortfolioM _portfolio = PortfolioM();

  // FlareControls _flareControls = FlareControls();

  String action = "no_action";

  @override
  initState() { /* Initialize State */
    if(mounted) {
      _homeModel.result = {};
      _homeModel.globalKey = GlobalKey<ScaffoldState>();
      _homeModel.total = 0;
      _homeModel.circularChart = [
        CircularSegmentEntry(_homeModel.emptyChartData, hexaCodeToColor(AppColors.cardColor))
      ];
      AppServices.noInternetConnection(_homeModel.globalKey);
      _homeModel.userData = {};
      /* User Profile */
      // getUserData();
      // fetchPortfolio();
      triggerDeviceInfo();
      if (Platform.isAndroid) appPermission();
      // fabsAnimation();
    }

    menuModel.result.addAll({
      "pin": '',
      "confirm": '',
      "error": ''
    });

    super.initState();
  }

  void login() async {
    _backend.response = await _postRequest.loginByPhone("15894139", "123456");

    _backend.mapData = json.decode(_backend.response.body);

    await StorageServices.setData(_backend.mapData, 'user_token');

    setState(() {
      
    });
  }

  // Initialize Fabs Animation
  void fabsAnimation(){ 
    _homeModel.animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    _homeModel.degOneTranslationAnimation = Tween(begin: 0.0, end: 1.0).animate(_homeModel.animationController);
    setState((){});
    _homeModel.animationController.addListener(() {
      setState(() {
        
      });
    });
  }

  void opacityController(bool visible){
    setState(() {
      if (visible){ 
        _homeModel.visible = false;
      } else  if (visible == false) {
        _homeModel.visible = true;
      }
    });
  }

  Future<void> appPermission() async { 
    await AndroidPlatform.checkPermission().then((value) async {
      if (value == false){
        await Component.messagePermission(
          context: context,
          content: "We suggest you to enable permission on apps",
          method: () async {
            await AndroidPlatform.writePermission();
            Navigator.pop(context);
          }
        );
      }
    });
  }

  /* ---------------------------Rest Api--------------------------- */
  Future<void> getUserData() async { /* Fetch User Data From Memory */
    await _getRequest.getUserProfile().then((data) {
      setState(() {
        if (data == null)
          _homeModel.userData = {};
        else
          _homeModel.userData = data;
      });
    });
  }

  void triggerDeviceInfo() async {
    _packageInfo = await PackageInfo.fromPlatform();
    setState(() {});
  }

  /* Fetch Portofolio */
  Future<void> fetchPortfolio() async { 

    _portfolio.list = [];
    
    await Future.delayed(Duration(milliseconds: 10),(){
      setState(() {
        _homeModel.portfolioList = [];
      });
    });

    try {
      /* Get Response Data */
      _backend.response = await _getRequest.getPortfolio();

      /* Covert String To Objects */
      await _portfolio.extractData(_backend.response);
      print(_backend.response.runtimeType);
      
      // Error Handling
      if (_portfolio.list[0].containsKey('error')){
        throw AssertionError(_portfolio.list[0]['error']['message']);
      }

      setState(() {
        _homeModel.portfolioList = _portfolio.list;
      });
      StorageServices.setData(_homeModel.portfolioList, 'portfolio'); /* Set Portfolio To Local Storage */
      resetDataPieChart(_homeModel.portfolioList); 
    } catch (e){
      await dialog(
        context, 
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 10.0),
              child: textAlignCenter(text: "${e.message}")
            ),
          ],
        ), 
        warningTitleDialog()
      );
      print("Null");
      setState(() {
        _homeModel.portfolioList = null; /* Set Portfolio Equal Null To Close Loading Process */
      });
    }
  }

  /* ------------------------Method------------------------ */

  void resetDataPieChart(List<dynamic> portfolio){
    
    if (_homeModel.portfolioList.length != 0){
      
      _homeModel.total = 0.0;

      _homeModel.circularChart.clear(); // Clear Pie Data

      for (int i = 0; i < _homeModel.portfolioList.length; i++){
        // Add Total
        _homeModel.total += json.decode(_homeModel.portfolioList[i]['balance']);
        
        _homeModel.circularChart.add( //Add More Data Follow Portfolio
          CircularSegmentEntry(
            json.decode(_homeModel.portfolioList[i]['balance']),
            hexaCodeToColor(AppColors.secondary)
          )
        );
      }
      _homeModel.emptyChartData -= _homeModel.total;
      _homeModel.circularChart.add( // Add Remain Empty Data
        CircularSegmentEntry(
          _homeModel.emptyChartData,
          hexaCodeToColor(AppColors.cardColor)
        )
      );

      _homeModel.chartKey.currentState.updateData([
        CircularStackEntry(_homeModel.circularChart)
      ]);

      _homeModel.emptyChartData = 100.0; // Reset Remain Pie Data
    }
  }
  
  void menuCallBack(Map<String, dynamic> result) async {

    if (result != null){
      _backend.mapData = await StorageServices.fetchData("getWallet");

      if (result.isNotEmpty){
        // Log Out
        if (result.containsKey('log_out')){
          Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Welcome()), 
          );
        }
        else if (result['dialog_name'] == "addAssetScreen") {
          await fetchPortfolio();
        }
        else if (result['dialog_name'] == 'edit_profile') {
          await getUserData();
        }
      }

      // If Get Wallet
      if (_backend.mapData != null ){
        await fetchPortfolio();
        await StorageServices.removeKey("getWallet");
      }
    }
  }

  /* ------------------------Fetch Local Data Method------------------------ */
  
  // Refech Data User And Portfolio
  _pullUpRefresh() async { 
    setState(() {
      _homeModel.portfolioList = [];
    });
    fetchPortfolio();
    getUserData();
    _homeModel.refreshController.refreshCompleted();
  }

  Future<dynamic> cropImageCamera(BuildContext context) async {
    File image = await camera();
    dialogLoading(context);
    if (image != null) {
      await Future.delayed(Duration(milliseconds: 300), () => Navigator.pop(context)); /* Wait 300 Millisecond And Close Loading Process */
      File cropImage = await ImageCropper.cropImage(
        // maxHeight: 4096,
        // maxWidth: 1024,
        sourcePath: image.path,
        androidUiSettings: AndroidUiSettings(
          backgroundColor: Colors.black,
          // lockAspectRatio: false
        )
      );
      return cropImage;
    }
    await Future.delayed(Duration(milliseconds: 100), () => Navigator.pop(context)); /* Wait 300 Millisecond And Close Loading Process */
    return null;
  }

  void scanReceipt() async { /* Receipt Scan Pay Process */
    try {
      var _barcode = await BarcodeScanner.scan();
      dialogLoading(context); /* Enable Loading Process */
      await _postRequest.getReward(_barcode.rawContent).then((onValue) async {
        if (onValue.containsKey('message'))
          await dialog(
            context,
            Text(onValue['message']),
            Icon(
              Icons.done_outline,
              color: hexaCodeToColor(AppColors.lightBlueSky,)
            )
          );
          else await dialog(context, Text(onValue['error']['message']), warningTitleDialog());
          // Disable Loading Process
          Navigator.pop(context); 
          if (onValue.containsKey('message')) fetchPortfolio();
        }
      );
    } catch (e) {
      await Future.delayed(Duration(milliseconds: 300), () { });
      AppServices.openSnackBar(_homeModel.globalKey, e.message);
    }
  }

  // Future<void> createPin(BuildContext context) async { /* Set PIN Dialog */
  //   menuModel.result = await showDialog(
  //     barrierDismissible: false,
  //     context: context,
  //     builder: 
  //     menuModel.result['pin'] == '' ? /* If PIN Not Yet Set */
  //     (BuildContext context) {
  //       return Material(
  //         color: Colors.transparent,
  //         child: disableNativePopBackButton(SetPinDialog(menuModel.result['error']))
  //       );
  //     } :
  //     menuModel.result['confirm'] == '' ? /* Set PIN Done And Then Set Confirm Pin */
  //     (BuildContext context) {
  //       return Material(
  //         color: Colors.transparent,
  //         child: disableNativePopBackButton(SetConfirmPin(menuModel.result['pin'])),
  //       );
  //     } :
  //     (BuildContext context) { /* Comfirm PIN Success Shower Dialog Of Private Key */
  //       return Material(
  //         color: Colors.transparent,
  //         child: WillPopScope(
  //           onWillPop: () async => await Future(() => false),
  //           child: disableNativePopBackButton(PrivateKeyDialog(Map<String, dynamic>.from(menuModel.result))),
  //         ),
  //       );
  //     }
  //   );
    
  //   if (menuModel.result['response'].isNotEmpty){/* From Set PIN Widget */
  //     if (menuModel.result["dialog_name"] == 'Pin'){
  //       // menuModel.result['pin'] = menuModel.['pin'];
  //       createPin(context); /* callBack */
  //     } else 
  //     if (menuModel.result["dialog_name"] == 'confirmPin'){ /* From Set Confirm PIN Widget */
  //       if (menuModel.result['compare'] == false) {
  //         menuModel.result['pin'] = '';
  //         menuModel.result['error'] = "PIN does not match"; /* Enable Error Text*/
  //         createPin(context); /* callBack */
  //       } else if (menuModel.result["compare"] == true){
  //         menuModel.result['confirm'] = '';
  //         await Future.delayed(Duration(milliseconds: 200), () { /* Wait A Bit and Call setPinGetWallet Function Again */
  //           createPin(context); /* callBack */
  //         });
  //       }
  //     } else { /* Success Set PIN And Push SnackBar */
  //       menuModel.result['pin'] = ""; /* Reset Pin Confirm PIN And Result To Empty */
  //       menuModel.result['confirm'] = "";
  //       snackBar(menuModel.globalKey, menuModel.result['message']); /* Copy Private Key Success And Show Message From Bottom */
  //     }
  //   } else { /* Reset Pin Confirm PIN And Result To Empty */
  //     menuModel.result['pin'] = "";  
  //     menuModel.result['confirm'] = "";
  //   }
  // }

  void resetState(String barcodeValue, String executeName) { /* Request Portfolio After Trx QR Success */
    setState(() {
      _homeModel.portfolioList = [];
    });
    fetchPortfolio();
    getUserData();
  }

  void toReceiveToken() async { /* Navigate Receive Token */
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReceiveWallet(homeM: _homeModel)
      )
    );
    if(Platform.isAndroid) await AndroidPlatform.resetBrightness();
    else await IOSPlatform.resetBrightness(IOSPlatform.defaultBrightnessLvl);
  }

  void openMyDrawer(){
    _homeModel.globalKey.currentState.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    
    final bloc = Bloc();

    return Scaffold(
      key: _homeModel.globalKey,
      drawer: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.transparent
        ),
        child: Menu(_homeModel.userData, _packageInfo, menuCallBack),
      ),

      body: SmartRefresher(
        physics: BouncingScrollPhysics(),
        controller: _homeModel.refreshController,
        child: BodyScaffold(
          height: MediaQuery.of(context).size.height,
          child: HomeBody(
            bloc: bloc,
            chartKey: _homeModel.chartKey,
            portfolioData: _homeModel.portfolioList,
            homeModel: _homeModel,
            // getWallet: createPin,
          )
        ),
        onRefresh: _pullUpRefresh,
      ),

      floatingActionButton: SizedBox(
        width: 64, height: 64,
        child: FloatingActionButton(
          backgroundColor: hexaCodeToColor(AppColors.secondary),
          child: SvgPicture.asset('assets/sld_qr.svg', width: 30, height: 30),
          onPressed: () async {
            await TrxOptionMethod.scanQR(context, _homeModel.portfolioList, resetState);
          },
        )
      ),
      
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: MyBottomAppBar( /* Bottom Navigation Bar */
        model: _homeModel,
        postRequest: _postRequest,
        scanReceipt: null, // Bottom Center Button
        resetDbdState: resetState,
        toReceiveToken: toReceiveToken,
        opacityController: opacityController,
        openDrawer: openMyDrawer,
      )
    );
  }
}
