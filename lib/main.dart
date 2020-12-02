import 'dart:async';
import 'dart:io' show Platform;

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(_MyApp());
}

class _MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<_MyApp> {
  ScanResult scanResult;

  final _flashOnController = TextEditingController(text: "Flash on");
  final _flashOffController = TextEditingController(text: "Flash off");
  //final _cancelController = TextEditingController(text: "Cancel");

  var _aspectTolerance = 0.00;
  var _numberOfCameras = 0;
  var _selectedCamera = -1;
  var _useAutoFocus = true;
  var _autoEnableFlash = false;

  static final _possibleFormats = BarcodeFormat.values.toList()
    ..removeWhere((e) => e == BarcodeFormat.unknown);

  List<BarcodeFormat> selectedFormats = [..._possibleFormats];

  @override
  // ignore: type_annotate_public_apis
  initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      _numberOfCameras = await BarcodeScanner.numberOfCameras;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    //  var w = MediaQuery.of(context).size.width;
    //var h = MediaQuery.of(context).size.height;
    var contentList2 = <Widget>[
      (scanResult != null)
          ? Card(
              color: Colors.transparent,
              child: Column(
                children: <Widget>[
                  ((int.parse(scanResult.rawContent.substring(0, 3)) > 299 &&
                              int.parse(
                                      scanResult.rawContent.substring(0, 3)) <=
                                  380) ||
                          (int.parse(scanResult.rawContent.substring(1, 3)) >
                                  29) &&
                              (int.parse(
                                      scanResult.rawContent.substring(1, 3)) <
                                  38)
                          )
                      ? Dialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0)),
                          child: Stack(
                            overflow: Overflow.visible,
                            alignment: Alignment.topCenter,
                            children: [
                              Container(
                                height: 250,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      10, 100, 10, 10),
                                  child: Column(
                                    children: [
                                      Text(
                                        scanResult.rawContent,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        'product is bad',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      RaisedButton(
                                        onPressed: () {
                                          scan();
                                        },
                                        color: Colors.redAccent,
                                        child: Text(
                                          'Scan Again',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                  top: -20,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.redAccent,
                                    radius: 60,
                                    child: Icon(
                                      Icons.warning,
                                      color: Colors.white,
                                      size: 50,
                                    ),
                                  )),
                            ],
                          ))
                      : Dialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0)),
                          child: Stack(
                            overflow: Overflow.visible,
                            alignment: Alignment.topCenter,
                            children: [
                              Container(
                                height: 250,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      10, 100, 10, 10),
                                  child: Column(
                                    children: [
                                      Text(
                                        scanResult.rawContent,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        'product is good',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      RaisedButton(
                                        onPressed: () {
                                          scan();
                                        },
                                        color: Colors.greenAccent,
                                        child: Text(
                                          'Scan Again',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                  top: -20,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.greenAccent,
                                    radius: 60,
                                    child: Icon(
                                      Icons.done_outline,
                                      color: Colors.white,
                                      size: 50,
                                    ),
                                  )),
                            ],
                          ),
                        ),
                ],
              ),
            )
          : InkWell(
              onTap: scan,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 300, 20, 200),
                child: Center(
                  child: Container(
                    height: 70,
                    width: 400,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100.0),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x80000000),
                            blurRadius: 30.0,
                            offset: Offset(0.0, 5.0),
                          ),
                        ],
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF0000FF),
                            Color(0xFFFF3500),
                          ],
                        )),
                    child: Center(
                      child: Text(
                        'Scan Your Barcode',
                        style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    ];
/////////////////////////////////////////////////////////
    var contentList = <Widget>[
      ListTile(
        title: Text("Camera selection"),
        dense: true,
        enabled: false,
      ),
      RadioListTile(
        onChanged: (v) => setState(() => _selectedCamera = -1),
        value: -1,
        title: Text("Default camera"),
        groupValue: _selectedCamera,
      ),
    ];

    for (var i = 0; i < _numberOfCameras; i++) {
      contentList.add(RadioListTile(
        onChanged: (v) => setState(() => _selectedCamera = i),
        value: i,
        title: Text("Camera ${i + 1}"),
        groupValue: _selectedCamera,
      ));
    }

    contentList.addAll([
      ListTile(
        title: Text("Button Texts"),
        dense: true,
        enabled: false,
      ),
      ListTile(
        title: TextField(
          decoration: InputDecoration(
            hasFloatingPlaceholder: true,
            labelText: "Flash On",
          ),
          controller: _flashOnController,
        ),
      ),
      ListTile(
        title: TextField(
          decoration: InputDecoration(
            hasFloatingPlaceholder: true,
            labelText: "Flash Off",
          ),
          controller: _flashOffController,
        ),
      ),
      // ListTile(
      //   title: TextField(
      //     decoration: InputDecoration(
      //       hasFloatingPlaceholder: true,
      //       labelText: "Cancel",
      //     ),
      //     controller: _cancelController,
      //   ),
      // ),
    ]);

    if (Platform.isAndroid) {
      contentList.addAll([
        ListTile(
          title: Text("Android specific options"),
          dense: true,
          enabled: false,
        ),
        ListTile(
          title:
              Text("Aspect tolerance (${_aspectTolerance.toStringAsFixed(2)})"),
          subtitle: Slider(
            min: -1.0,
            max: 1.0,
            value: _aspectTolerance,
            onChanged: (value) {
              setState(() {
                _aspectTolerance = value;
              });
            },
          ),
        ),
        CheckboxListTile(
          title: Text("Use autofocus"),
          value: _useAutoFocus,
          onChanged: (checked) {
            setState(() {
              _useAutoFocus = checked;
            });
          },
        )
      ]);
    }

    contentList.addAll([
      ListTile(
        title: Text("Other options"),
        dense: true,
        enabled: false,
      ),
      CheckboxListTile(
        title: Text("Start with flash"),
        value: _autoEnableFlash,
        onChanged: (checked) {
          setState(() {
            _autoEnableFlash = checked;
          });
        },
      )
    ]);

    contentList.addAll([
      ListTile(
        title: Text("Barcode formats"),
        dense: true,
        enabled: false,
      ),
      ListTile(
        trailing: Checkbox(
          tristate: true,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          value: selectedFormats.length == _possibleFormats.length
              ? true
              : selectedFormats.length == 0 ? false : null,
          onChanged: (checked) {
            setState(() {
              selectedFormats = [
                if (checked ?? false) ..._possibleFormats,
              ];
            });
          },
        ),
        dense: true,
        enabled: false,
        title: Text("Detect barcode formats"),
        subtitle: Text(
          'If all are unselected, all possible platform formats will be used',
        ),
      ),
    ]);

    contentList.addAll(_possibleFormats.map(
      (format) => CheckboxListTile(
        value: selectedFormats.contains(format),
        onChanged: (i) {
          setState(() => selectedFormats.contains(format)
              ? selectedFormats.remove(format)
              : selectedFormats.add(format));
        },
        title: Text(format.toString()),
      ),
    ));
    return MaterialApp(
      color: Colors.indigo.shade100,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.indigo.shade50,
        drawer: Drawer(
          child: ListView(
            children: contentList,
          ),
        ),
        appBar: AppBar(
          backgroundColor: Colors.indigo,
          title: Text('Barcode Scanner Example'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.camera),
              tooltip: "Scan",
              onPressed: () {
                scan();
              },
            )
          ],
        ),

        body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                Color(0xFF0050FF),
                Color(0xFFF5001),
              ])),
          child: ListView(
            children: contentList2,
          ),
        ),
        // body: InkWell(
        //   onTap: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(builder: (context) => mycard()),
        //     );
        //   },
        //   child: Center(
        //     child: Container(
        //       height: 70,
        //       width: 300,
        //       decoration: BoxDecoration(
        //         borderRadius: BorderRadius.circular(100.0),
        //         boxShadow: [
        //           BoxShadow(
        //             color: Color(0x80000000),
        //             blurRadius: 30.0,
        //             offset: Offset(0.0, 5.0),
        //           ),
        //         ],
        //         gradient: LinearGradient(
        //           begin: Alignment.topLeft,
        //           end: Alignment.bottomRight,
        //           colors: [
        //             Color(0xFF0000FF),
        //             Color(0xFFFF3500),
        //           ],
        //         ),
        //       ),
        //       child: Center(
        //         child: Text(
        //           'Scan Your Barcode',
        //           style: TextStyle(
        //               fontSize: 30.0,
        //               fontWeight: FontWeight.bold,
        //               color: Colors.white),
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
      ),
    );
  }

  Future scan() async {
    try {
      var options = ScanOptions(
        strings: {
          "flash_on": _flashOnController.text,
          "flash_off": _flashOffController.text,
        },
        restrictFormat: selectedFormats,
        useCamera: _selectedCamera,
        autoEnableFlash: _autoEnableFlash,
        android: AndroidOptions(
          aspectTolerance: _aspectTolerance,
          useAutoFocus: _useAutoFocus,
        ),
      );

      var result = await BarcodeScanner.scan(options: options);

      setState(() => scanResult = result);
    } on PlatformException catch (e) {
      var result = ScanResult(
        type: ResultType.Error,
        format: BarcodeFormat.unknown,
      );

      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          result.rawContent = 'The user did not grant the camera permission!';
        });
      } else {
        result.rawContent = 'Unknown error: $e';
      }
      setState(() {
        scanResult = result;
      });
    }
  }
}

class mycard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var scanResult = ScanResult();
    return Card(
      child: Column(
        children: <Widget>[
          (int.parse(scanResult.rawContent.substring(0, 3)) > 299 &&
                  int.parse(scanResult.rawContent.substring(0, 3)) < 381)
              ? Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0)),
                  child: Stack(
                    overflow: Overflow.visible,
                    alignment: Alignment.center,
                    children: [
                      Container(
                        color: Colors.transparent,
                        height: 200,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 200, 10, 10),
                          child: Column(
                            children: [
                              Text(
                                'Warning !!!',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                'product is bad',
                                style: TextStyle(fontSize: 20),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              RaisedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                color: Colors.redAccent,
                                child: Text(
                                  'Okay',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                          top: -60,
                          child: CircleAvatar(
                            backgroundColor: Colors.redAccent,
                            radius: 60,
                            child: Icon(
                              Icons.warning,
                              color: Colors.white,
                              size: 50,
                            ),
                          )),
                    ],
                  ))
              : ListTile(
                  title: Text("Format note"),
                  subtitle: Text(scanResult.formatNote ?? "product is good "),
                ),
        ],
      ),
    );
  }
}
