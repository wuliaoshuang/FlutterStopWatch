import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_stop_watch/config/app_config_bloc.dart';

import '../config/app_config.dart';

void showLanguageSelectDialog(BuildContext context){
  List<String> data = AppConfig.languageSupports.keys.toList();
  showCupertinoModalPopup(
      context: context,
      builder: (context) => LanguageSelectDialog(
        data: data,
      ));
}

class LanguageSelectDialog extends StatelessWidget {

  final List<String> data;
  const LanguageSelectDialog({super.key, required this.data});

  @override
  Widget build(BuildContext context){
    return Material(
      child: SizedBox(
        height: 350,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("选择语言",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 ),),
            ),
            Expanded(child: ListView.builder(
              padding: EdgeInsets.zero,
              itemBuilder: _buildItem,
              itemCount: data.length,
            ))
          ],
        ),
      )
    );
  }


  Widget _buildItem(BuildContext context, int index){

    Locale locale = AppConfig.languageSupports.values.toList()[index];
    Locale? blocLocal = BlocProvider.of<AppConfigBloc>(context).state.locale;
    bool checked = locale == blocLocal;
    Color color = Theme.of(context).primaryColor;

    return ListTile(
      title: Text(data[index]),
      onTap: ()=> _onSelect(context, index),
      trailing: checked ? Icon(Icons.check, size: 20, color: color,) : null,
    );
  }


  void  _onSelect(BuildContext context, int index){
    Locale locale = AppConfig.languageSupports.values.toList()[index];
    BlocProvider.of<AppConfigBloc>(context).switchLanguage(locale);
    Navigator.of(context).pop();
  }

}
