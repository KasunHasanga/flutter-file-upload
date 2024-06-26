import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as Path;

import 'check_permission.dart';
import 'directory_path.dart';
import 'helper.dart';

class FileList extends StatefulWidget {
  FileList({super.key});

  @override
  State<FileList> createState() => _FileListState();
}

class _FileListState extends State<FileList> {
  bool isPermission = false;
  var checkAllPermissions = CheckPermission();

  checkPermission() async {
    var permission = await checkAllPermissions.isStoragePermission();
    if (permission) {
      setState(() {
        isPermission = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkPermission();
  }

  var dataList = [
    {
      "id": "2",
      "title": "file Video 1",
      "url": "https://download.samplelib.com/mp4/sample-30s.mp4"
    },
    {
      "id": "3",
      "title": "file Video 2",
      "url": "https://download.samplelib.com/mp4/sample-20s.mp4"
    },
    {
      "id": "4",
      "title": "file Video 3",
      "url": "https://download.samplelib.com/mp4/sample-15s.mp4"
    },
    {
      "id": "5",
      "title": "file Video 4",
      "url": "https://download.samplelib.com/mp4/sample-10s.mp4"
    },
    {
      "id": "6",
      "title": "file PDF 6",
      "url":
          "https://www.iso.org/files/live/sites/isoorg/files/store/en/PUB100080.pdf"
    },
    {
      "id": "10",
      "title": "file PDF 7",
      "url": "https://www.tutorialspoint.com/javascript/javascript_tutorial.pdf"
    },
    {
      "id": "10",
      "title": "C++ Tutorial",
      "url": "https://www.tutorialspoint.com/cplusplus/cpp_tutorial.pdf"
    },
    {
      "id": "11",
      "title": "file PDF 9",
      "url":
          "https://www.iso.org/files/live/sites/isoorg/files/store/en/PUB100431.pdf"
    },
    {
      "id": "12",
      "title": "file PDF 10",
      "url": "https://www.tutorialspoint.com/java/java_tutorial.pdf"
    },
    {
      "id": "13",
      "title": "file PDF 12",
      "url": "https://www.irs.gov/pub/irs-pdf/p463.pdf"
    },
    {
      "id": "14",
      "title": "file PDF 11",
      "url": "https://www.tutorialspoint.com/css/css_tutorial.pdf"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        body:isPermission
            ? ListView.builder(
            itemCount: dataList.length,
            itemBuilder: (BuildContext context, int index) {
              var data = dataList[index];
              return TileList(
                fileUrl: data['url']!,
                title: data['title']!,
              );
            })
            : Center(
          child: TextButton(
              onPressed: () {
                checkPermission();
              },
              child: const Text("Permission issue")),
        ),

        bottomSheet:SpinKitCubeGrid(
      itemBuilder: (BuildContext context, int index) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: index.isEven ? Colors.red : Colors.green,
          ),
        );
      },
    ) ,);
  }
}

class TileList extends StatefulWidget {
  TileList({super.key, required this.fileUrl, required this.title});
  final String fileUrl;
  final String title;

  @override
  State<TileList> createState() => _TileListState();
}

class _TileListState extends State<TileList> {
  bool dowloading = false;
  bool fileExists = false;
  double progress = 0;
  String fileName = "";
  late String filePath;
  late CancelToken cancelToken;
  var getPathFile = DirectoryPath();

  startDownload() async {
    cancelToken = CancelToken();
    var storePath = await getPathFile.getPath();
    filePath = '$storePath/$fileName';
    setState(() {
      dowloading = true;
      progress = 0;
    });

    try {
      await Dio().download(widget.fileUrl, filePath,
          onReceiveProgress: (count, total) {
        setState(() {
          progress = (count / total);
        });
      }, cancelToken: cancelToken);
      setState(() {
        dowloading = false;
        fileExists = true;
      });
    } catch (e) {
      print(e);
      setState(() {
        dowloading = false;
      });
    }
  }

  cancelDownload() {
    cancelToken.cancel();
    setState(() {
      dowloading = false;
    });
  }

  checkFileExit() async {
    var storePath = await getPathFile.getPath();
    filePath = '$storePath/$fileName';
    bool fileExistCheck = await File(filePath).exists();
    setState(() {
      fileExists = fileExistCheck;
    });
  }

  openfile() {
    OpenFile.open(filePath);
    print("fff $filePath");
  }


  String fileSize="0kb";

  @override
  void initState() {
    super.initState();
    setState(() {
      fileName = Path.basename(widget.fileUrl);
    });
    checkFileExit();
    getFileSize();
  }
  getFileSize()async{
    var r = await Dio().head(widget.fileUrl);
    var byteLength=r.headers["content-length"];
    String value =Helper.formatBytes(int.parse("${byteLength?[0]}"), 1);
    if (kDebugMode) {
      print("${Path.basename(widget.fileUrl)}   $value   ${widget.fileUrl}");
    }

    setState(() {
      fileSize =value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shadowColor: Colors.grey.shade100,
      child: ListTile(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title),
              Text(fileSize),

            ],
          ),
          leading: IconButton(
              onPressed: () {
                fileExists && dowloading == false
                    ? openfile()
                    : dowloading? cancelDownload():null;
              },
              icon: fileExists && dowloading == false
                  ? const Icon(
                      Icons.window,
                      color: Colors.green,
                    )
                  :dowloading? const Icon(Icons.close):const Icon(Icons.ac_unit) ),
          trailing: IconButton(
              onPressed: () {
                fileExists && dowloading == false
                    ? openfile()
                    : startDownload();
              },
              icon: fileExists
                  ? const Icon(
                      Icons.save,
                      color: Colors.green,
                    )
                  : dowloading
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 3,
                              backgroundColor: Colors.grey,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.blue),
                            ),
                            Text(
                              "${(progress * 100).toStringAsFixed(2)}",
                              style: TextStyle(fontSize: 12),
                            )
                          ],
                        )
                      : const Icon(Icons.download))),
    );
  }
}
