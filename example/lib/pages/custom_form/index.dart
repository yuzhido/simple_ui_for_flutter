import 'package:flutter/material.dart';
import 'package:simple_ui/src/custom_form/index.dart';

class CustomFormPage extends StatefulWidget {
  const CustomFormPage({super.key});
  @override
  State<CustomFormPage> createState() => _CustomFormPageState();
}

class _CustomFormPageState extends State<CustomFormPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('导航栏标题')),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Column(
          children: [
            SelectForDropdown(),
            SelectForTree(),
            SelectForSingle(),
            SelectForMultiple(),
            SelectForRadio(),
            SelectForCheckbox(),
            InputForText(),
            InputForTextarea(),
            InputForInteger(),
            InputForNumber(),
            DateForDateTime(),
            DateForDate(),
            DateForTime(),
            FileForUpload(),
          ],
        ),
      ),
    );
  }
}
