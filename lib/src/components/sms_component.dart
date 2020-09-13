import 'package:wallet_apps/index.dart';

class SmsBox extends StatelessWidget {

  final double left;
  final double right;
  final FocusNode focusNode;
  final TextEditingController controller;
  final Function onChanged;

  SmsBox({
    this.left,
    this.right,
    this.focusNode,
    this.controller,
    this.onChanged
  });

  Widget build(BuildContext context){
    return FittedBox(
      fit: BoxFit.contain,
      child: Container(
        // margin: EdgeInsets.only(left: left, right: right),
        child: SizedBox(
          width: 49,
          height: 69,
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            inputFormatters: [LengthLimitingTextInputFormatter(1), WhitelistingTextInputFormatter.digitsOnly],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              labelStyle: TextStyle(
                fontSize: 18.0,
                color: Colors.white
              ),
              /* Prefix Text */
              filled: true, fillColor: hexaCodeToColor(AppColors.cardColor),
              // enabledBorder: myOutlineInput(hexaCodeToColor("#FFFFFF").withOpacity(0.3)),
              /* Enable Border But Not Show Error */
              border: errorOutline(),
              /* Show Error And Red Border */
              focusedBorder: myOutlineInput(hexaCodeToColor("#FFFFFF").withOpacity(0.3)),
              /* Default Focuse Border Color*/
              focusColor: hexaCodeToColor("#ffffff"),
              /* Border Color When Focusing */
              contentPadding: EdgeInsets.only(top: 23,right: 5.0, bottom: 23, left: 5), // No Content Padding = -10.0 px
            ),
            onChanged: onChanged,
          )
        ),
      ),
    );
  }
}