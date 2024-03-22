import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_stop_watch/config/app_config.dart';
import 'package:my_stop_watch/config/app_config_bloc.dart';
import 'package:my_stop_watch/record_panel.dart';
import 'package:my_stop_watch/right2_left_router.dart';
import 'package:my_stop_watch/setting_page.dart';
import 'package:my_stop_watch/stopwatch.dart';

import 'button_tools.dart';
import 'model/time_record.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark, // 状态栏图标亮色
    ),
  );
  final appConfigBloc = AppConfigBloc(appConfig: AppConfig.defaultConfig());
  appConfigBloc.loadState();
  runApp(
      BlocProvider<AppConfigBloc>(
          create: (_)=> appConfigBloc,
        child: const MyApp()
      ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppConfigBloc, AppConfig>(builder:(_, state)=>  MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: state.locale,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: state.themeColor, background: const Color(0xfffafafa)),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarBrightness: Brightness.dark,
            statusBarColor: Colors.transparent,
          )
        )
      ),
      home: const MyHomePage(title: ''),

    ));


  }
}


class NewRoute extends StatelessWidget {
  const NewRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New route"),
      ),
      body: const Center(
        child: Text("This is new route"),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  StopWatchType _type = StopWatchType.none;

  late Ticker _ticker;
  Duration _duration = Duration.zero;
  Duration _secondDuration = Duration.zero;

  final List<TimeRecord> _record = [];

  @override
  void initState() {
    super.initState();
    _ticker = Ticker(_onTick);
  }

  Duration dt = Duration.zero;
  Duration lastDuration = Duration.zero;

  void _onTick(Duration elapsed) {
    setState(() {
      dt = elapsed - lastDuration;
      _duration += dt;
      if(_record.isNotEmpty){
        _secondDuration = _duration - _record.last.record;
      }
      lastDuration = elapsed;
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }



  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void toggle(){
    bool running = _type == StopWatchType.running;

    if(running){
      _ticker.stop();
      lastDuration = Duration.zero;
    }else{
      _ticker.start();
    }

    setState(() {
      _type = running ? StopWatchType.stopped : StopWatchType.running;
    });
  }

  void onReset() {
    setState(() {
      _duration = Duration.zero;
      _secondDuration = Duration.zero;
      _type = StopWatchType.none;
      _record.clear();
    });
  }

  void onRecoder(){
    Duration current = _duration;
    Duration addition = _duration;
    if(_record.isNotEmpty){
      addition = _duration - _record.last.record;
    }
    setState(() {
      _record.add(TimeRecord(record: current, addition: addition));
    });

  }

  void ncnc (bool b){

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(widget.title),
          actions: buildActions(),
          elevation: 0
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            buildStopWatchPanel(),
            buildRecordPanel(),
            buildTools()

          ],
        ),
      ),
    );
  }

  List<Widget> buildActions(){


    return [
      PopupMenuButton<String>(
        itemBuilder: itemBuilder,
        onSelected: _onSelectItem,
        icon: const Icon(Icons.more_vert_outlined, color: Color(0xff262626)),
        position: PopupMenuPosition.under,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))
        ),
      )
    ];
  }

  List<PopupMenuEntry<String>> itemBuilder (BuildContext context){
    String settingText = AppLocalizations.of(context)!.setting;
    return [
      PopupMenuItem(value: settingText, child: Text(settingText))
    ];

  }

  void _onSelectItem(String value){
    String settingText = AppLocalizations.of(context)!.setting;
    if(value == settingText){
      Navigator.of(context).push(Right2LeftRouter(child: const SettingPage()));
    }
  }

  Widget buildStopWatchPanel(){

    double radius = MediaQuery.of(context).size.shortestSide / 2 * 0.75;

    return Container(
      height: radius * 2.2,
      color: Colors.transparent,
      child: StopwatchWidget(radius: radius, duration: _duration, secondDuration: _secondDuration),
    );
  }

  Widget buildRecordPanel(){

    return Expanded(
        child: RecordPanel(record: _record,)
    );
  }

  Widget buildTools() {
    return  ButtonTools(
      state: _type,
      onRecoder: onRecoder,
      onReset: onReset,
      toggle: toggle,
    );
  }

}