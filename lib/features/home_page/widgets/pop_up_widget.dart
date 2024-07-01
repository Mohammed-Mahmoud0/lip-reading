import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lip_reading/core/theming/colors.dart';
import 'package:lip_reading/core/widgets/app_text_form_field.dart';

class IpPopup extends StatelessWidget {
  const IpPopup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController ipController = TextEditingController();
    TextEditingController portController = TextEditingController();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Container(
        height: 300.h,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Enter IP and Port',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: ColorsManager.mainBlue,
              ),
            ),
            const SizedBox(height: 20.0),
            AppTextFormField(
              hintText: 'Ip Address',
              myController: ipController,
              hintStyle: TextStyle(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
            AppTextFormField(
                hintText: 'Port',
                myController: portController,
                hintStyle: TextStyle(
                  color: Colors.black.withOpacity(0.5),
                )),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop({
                  'ip': ipController.text != ''
                      ? ipController.text
                      : '192.168.1.12',
                  'port': int.tryParse(portController.text) ?? 5050,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsManager.mainBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 30.0, vertical: 15.0),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
