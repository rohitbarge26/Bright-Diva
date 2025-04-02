import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'custom_text.dart';

class ShowAlertDialog extends StatelessWidget {
  //final String alertLogoPath;
  final String status;
  final String statusInfo;
  final String buttonText;
  final String navigationRough;
  final bool isWithParam;
  final int navigationIndex;

  ShowAlertDialog(
    //this.alertLogoPath,
    this.status,
    this.statusInfo,
    this.buttonText,
    this.navigationRough,
    this.isWithParam,
    this.navigationIndex,
  );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(19),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 50),
      content: Container(
        padding: const EdgeInsets.only(top: 32, left: 24, right: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /*SvgPicture.asset(
              alertLogoPath,
              height: 64,
              width: 64,
            ),*/
            const SizedBox(height: 16),
            CustomText(
              textAlign: TextAlign.center,
              text: status,
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              desiredLineHeight: 24.2,
              color: const Color(0XFF171717),
            ),
            const SizedBox(height: 8),
            CustomText(
              text: statusInfo,
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              desiredLineHeight: 20,
              color: const Color(0XFF737373),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 24, left: 24, bottom: 32.0),
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFFF85A5A),
            ),
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Center(
                child: CustomText(
                  text: buttonText,
                  fontSize: 16,
                  desiredLineHeight: 24,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFFFFFF),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
