// ignore_for_file: file_names, camel_case_types, use_super_parameters, prefer_const_constructors

import 'package:cjb/pages/main/main_page/apply_page.dart';
import 'package:flutter/material.dart';

class CV_page extends StatelessWidget {
  final int jobId;

  const CV_page({Key? key, required this.jobId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ApplyPage(jobId: jobId);
  }
}
