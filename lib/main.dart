import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_settings/app_settings.dart';
import 'package:package_info/package_info.dart';
import './doNotAskAgain.dart';
import 'package:permission_handler/permission_handler.dart';
import './custom_app_bar.dart';

void main() => runApp(
  MaterialApp(
    home: HomeView(),
  )
);

const String kNavigationExamplePage = '';

class HomeView extends StatefulWidget {
  HomeView({Key key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
  
}

class _HomeViewState extends State<HomeView>{

   PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );
  
  @override
  void initState() {
    super.initState();
    // checkLatestVersion();
  }

  @override
  void dispose() {
    super.dispose();
  }


  checkLatestVersion() async {
    //获取当前版本
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;

     //获取服务器上最新版本
    Map map = new HashMap();
    map['data'] = '1.新增app应用内升级\n2.修复若干个bug';
    map['ver'] = '1.0.1';
    map['url'] = 'http://gitsvr.mipesoft.com/hehuapei/file/raw/master/app.apk?inline=false';

    if((Random().nextInt(10)) > 3){
      _showOptionalUpdateDialog(
        context,
        "A newer version of the app is available"
      );
    }
  }

  _onUpdateNowClicked() async {
     Navigator.of(context).pop();
    //获取权限
    var per = await checkPermission();
    if(per != null && !per){
      return null;
    }
  }

///检查是否有权限
  checkPermission() async {
    //检查是否已有读写内存权限
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      Map<Permission, PermissionStatus> statuses = await [Permission.storage].request();
      if (statuses[Permission.storage] != PermissionStatus.granted) {
        return false;
      }
    }
    //判断如果还没拥有读写权限就申请获取权限
    // if(status != PermissionStatus.granted){
    //   var map = await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    //   if(map[PermissionGroup.storage] != PermissionStatus.granted){
    //     return false;
    //   }
    // }
  }


  _showOptionalUpdateDialog(context, String message) async {
    await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        String title = "App Update Available";
        String btnLabel = "Update Now";
        String btnLabelCancel = "Later";
        String btnLabelDontAskAgain = "Don't ask me again";
        return DoNotAskAgainDialog(
          title,
          message,
          btnLabel,
          btnLabelCancel,
          _onUpdateNowClicked,
          doNotAskAgainText:
              Platform.isIOS ? btnLabelDontAskAgain : 'Never ask again',
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Webview Demo')
      ),
      body: Builder(builder: (BuildContext context) {
        return Row(children: [
          RaisedButton(
          child: Text('go to webview'),
          onPressed: () {
           Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (BuildContext context) {
                                        return WebViewExample();
                                      }));
          }
        ),
        SizedBox(
          width: 10
        ),
        // RaisedButton(
        //   child: Text('版本更新'),
        //   onPressed: () {
        //     Navigator.pushAndRemoveUntil(
        //           context,
        //           MaterialPageRoute(
        //             builder: (context) {
        //               return WebViewExample();
        //             },
        //           ),
        //           ModalRoute.withName('/'),
        //         );
        //   }
        // )
        ],);
      }),
    );
  }
}

class WebViewExample extends StatefulWidget {
  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  File _image;
  final picker = ImagePicker();
  String _retrieveDataError;

  @override
  void initState() {
    if (!mounted) return;
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    String message = pickedFile.path;
    _controller.future.then((controller) {
      controller
        .evaluateJavascript("getPath('$message')")
        .then((result) {});
    });
                
  }

  Future getGallery() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    String message = pickedFile.path;
    _controller.future.then((controller) {
      controller
        .evaluateJavascript("getPath('$message')")
        .then((result) {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        leadingWidget: GestureDetector(
          child: Icon(Icons.arrow_back,color: Colors.white,),
          onTap: () {
            print('test');
            Navigator.of(context).pop();
          },
        ),
        title: 'Webview Page',
        navigationBarBackgroundColor: Color(0xFF1389FD),
      ),
      body: Builder(builder: (BuildContext context) {
        return WebView(
          initialUrl: 'http://106.53.233.99',
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _controller.complete(webViewController);
          },
          // TODO(iskakaushik): Remove this when collection literals makes it to stable.
          // ignore: prefer_collection_literals
          javascriptChannels: <JavascriptChannel>[
            _toasterJavascriptChannel(context),
            _bluetoothJavascriptChannel(context),
            _dateJavascriptChannel(context),
            _soundJavascriptChannel(context),
            _appSettingsJavascriptChannel(context)
          ].toSet(),
          navigationDelegate: (NavigationRequest request) {
            // if (request.url.startsWith('https://www.youtube.com/')) {
            //    Scaffold.of(context).showSnackBar(
            //     SnackBar(content: Text('blocking navigation to $request}')),
            //   );
            //   return NavigationDecision.navigate;
            // }
            print('allowing navigation to $request');
            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {
            print('Page started loading: $url');
          },
          onPageFinished: (String url) {
            print('Page finished loading: $url');
          },
          gestureNavigationEnabled: true,
        );
      }),
      floatingActionButton: favoriteButton(),
    );
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          // ignore: deprecated_member_use
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
          if (message.message == 'JS调用了Flutter') getImage();  
          if (message.message == 'JS调用了Flutter1') getGallery();  
             
        });
  }

  JavascriptChannel _bluetoothJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Bluetooth',
        onMessageReceived: (JavascriptMessage message) {
          AppSettings.openBluetoothSettings();
        });
  }

  JavascriptChannel _dateJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Date',
        onMessageReceived: (JavascriptMessage message) {
          AppSettings.openDateSettings();
        });
  }

  JavascriptChannel _soundJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Sound',
        onMessageReceived: (JavascriptMessage message) {
          AppSettings.openSoundSettings();
        });
  }

  JavascriptChannel _appSettingsJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'AppSettings',
        onMessageReceived: (JavascriptMessage message) {
          AppSettings.openAppSettings();
        });
  }

  Widget favoriteButton() {
    return FutureBuilder<WebViewController>(
        future: _controller.future,
        builder: (BuildContext context,
            AsyncSnapshot<WebViewController> controller) {
          if (controller.hasData) {
            return FloatingActionButton(
              onPressed: () async {
                final String url = await controller.data.currentUrl();
                _controller.future.then((controller) {
                    controller
                      .evaluateJavascript('callJS("visible")')
                      .then((result) {});
                });
              },
              child: Text('call JS'),
            );
          }
          return Container();
        });
  }
}

