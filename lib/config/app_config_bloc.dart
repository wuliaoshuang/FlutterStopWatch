import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_stop_watch/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfigBloc extends Cubit<AppConfig>{

  AppConfigBloc({required AppConfig appConfig}) : super(appConfig);

  void switchThemeColor(Color color){
    if(color != state.themeColor){
      emit(state.copyWith(color: color));
      _saveState();
    }
  }

  void switchLanguage(Locale locale){
    if(locale != state.locale){
      emit(state.copyWith(locale: locale));
      _saveState();
    }
  }

  Future<void> _saveState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('themeColor', state.themeColor.value.toString());
    prefs.setString('locale', state.locale.toString());
    if (kDebugMode) {
      print('Saved state: ${state.themeColor.value.toString()}, ${state.locale.toString()}');
    }
  }

  Future<void> loadState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? themeColor = prefs.getString('themeColor');
    final String? locale = prefs.getString('locale');

    if(themeColor != null && locale != null){
      emit(state.copyWith(
        color: Color(int.parse(themeColor)),
        locale: Locale.fromSubtags(languageCode: locale)
      ));
      if (kDebugMode) {
        print('if Loaded state: $themeColor, $locale');
      }
    }
    if (kDebugMode) {
      print('Loaded state: $themeColor, $locale');
    }
  }


}