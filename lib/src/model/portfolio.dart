import 'package:http/http.dart' as _http;
import 'package:wallet_apps/index.dart';

class Portfolio{

  List<Map<String, dynamic>> list = [];

  Future<void> extractData(_http.Response data){
    List decode = json.decode(data.body);
    if(decode.runtimeType.toString() == "_GrowableList<dynamic>" || decode.runtimeType.toString() == "List<dynamic>"){
      decode.forEach((element) {
        list.add(element);
      });
    } else {
      decode.forEach((element) {
        list.add(element);
      });
    }
  }
}