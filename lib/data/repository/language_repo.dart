
import 'package:abaad_flutter/data/model/response/language_model.dart';
import 'package:abaad_flutter/util/app_constants.dart';
import 'package:flutter/material.dart';

class LanguageRepo {
  List<LanguageModel> getAllLanguages({required BuildContext context}) {
    return AppConstants.languages;
  }
}
