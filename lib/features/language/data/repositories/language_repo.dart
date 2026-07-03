
import 'package:abaad_flutter/features/language/data/models/language_model.dart';
import 'package:abaad_flutter/shared/utils/app_constants.dart';
import 'package:flutter/material.dart';

class LanguageRepo {
  List<LanguageModel> getAllLanguages({required BuildContext context}) {
    return AppConstants.languages;
  }
}
