// ignore_for_file: depend_on_referenced_packages

// import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fyp/function.dart';
import 'package:fyp/transcript.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;

import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FYP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: const FrontPage(),
    );
  }
}

class FrontPage extends StatefulWidget {
  const FrontPage({super.key});

  @override
  State<FrontPage> createState() => _FrontPageState();
}

class _FrontPageState extends State<FrontPage> {
  // int fileCount = 1;
  List<PlatformFile> allFiles = [];
  late VideoPlayerController _controller;
  bool isLoading = false;
  FilePickerResult? result;
  PlatformFile? pickedfile;
  bool isDownload = false;
  final manager = StateManager();
  //for Audio
  final audioplayer = AudioPlayer();
  final audioCache = AudioCache();
  List<bool> isPlaying = [false];
  int playingIndex = 0;
  // bool isPlaying = false;
  List<Duration> duration = [Duration.zero];
  List<Duration> position = [Duration.zero];

  String? _filename;
  var data;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset("images/bggif.mp4")
      ..initialize().then((_) {
        _controller.play();
        _controller.setLooping(true);
        setState(() {});
      });
    audioplayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying[playingIndex] = state == PlayerState.playing;
      });
    });
    audioplayer.onDurationChanged.listen((event) {
      setState(() {
        duration[playingIndex] = event;
      });
    });
    audioplayer.onPositionChanged.listen((event) {
      setState(() {
        position[playingIndex] = event;
      });
    });
  }

  void checkFile() async {
    //Check if Demo.mp3 exists
    String fileName = "Demo.mp3";
    String dir = (Platform.isAndroid
            ? await getExternalStorageDirectory() //FOR ANDROID
            : await getApplicationSupportDirectory())!
        .path;
    String savePath = '$dir/$fileName';

    //for a directory: await Directory(savePath).exists();
    if (await File(savePath).exists()) {
      print("Demo.mp3 exists");
      isDownload = true;
    } else {
      isDownload = false;
    }
    if (allFiles.isEmpty) {
      print("ghj");
      allFiles.add(PlatformFile(name: fileName, path: savePath, size: 1070973));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    checkFile();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          VideoPlayer(_controller),
          Container(
            color: const Color.fromARGB(209, 0, 0, 0),
            width: double.infinity,
            height: double.infinity,
          ),
          Column(
            children: [
              const SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(left: 0.0, top: 20.0),
                  child: ListTile(
                    title: Text("Library",
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 45.0,
                          fontWeight: FontWeight.w700,
                          fontFamily: "arial",
                          decoration: TextDecoration.none,
                        )),
                    tileColor: Colors.transparent,
                  ),
                ),
              ),
              const Divider(
                height: 20,
                thickness: 2,
                indent: 30,
                endIndent: 20,
                color: Color.fromARGB(184, 50, 50, 50),
              ),
              ListView.builder(
                padding: const EdgeInsets.all(0.0),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true, // use this
                itemCount: allFiles.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    selectedTileColor: Colors.transparent,
                    minLeadingWidth: 70.0,
                    minVerticalPadding: 20.0,
                    contentPadding: const EdgeInsets.only(left: 30.0),
                    onTap: () async {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (BuildContext context) {
                          return transcript(path: allFiles[index].path!);
                        }),
                      );
                    },
                    leading: Column(
                      children: [
                        Visibility(
                          visible: !isDownload,
                          child: const Icon(
                            Icons.music_note_sharp,
                            color: Colors.white,
                            size: 35.0,
                          ),
                        ),
                        Visibility(
                          visible: isDownload,
                          child: IconButton(
                            icon: Icon(isPlaying[index]
                                ? Icons.pause_circle_filled_sharp
                                : Icons.play_circle_fill_sharp),
                            color: Colors.white,
                            iconSize: 40.0,
                            onPressed: () async {
                              playingIndex = index;
                              if (isPlaying[index]) {
                                await audioplayer.pause();
                                setState(() {
                                  isPlaying[index] = false;
                                });
                              } else {
                                String fileName = allFiles[index].path!;
                                print(fileName);
                                await audioplayer
                                    .play(DeviceFileSource(fileName));
                                setState(() {
                                  isPlaying[index] = true;
                                });
                              }
                            },
                          ),
                        )
                      ],
                    ),
                    title: Text(allFiles[index].name,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 24.0,
                          fontWeight: FontWeight.normal,
                          fontFamily: "arial",
                          decoration: TextDecoration.none,
                        )),
                    subtitle: Column(
                      children: [
                        Visibility(
                          visible: !isDownload,
                          child: ValueListenableBuilder<double?>(
                            valueListenable: manager.progressNotifier,
                            builder: (context, percent, child) {
                              if (percent == 1.0) {
                                isDownload = true;
                                Future.delayed(Duration.zero, () {
                                  setState(() {});
                                });
                              }
                              return LinearProgressIndicator(
                                backgroundColor:
                                    const Color.fromARGB(0, 0, 0, 0),
                                value: percent,
                              );
                            },
                          ),
                        ),
                        Visibility(
                          visible: isDownload,
                          child: Slider(
                            min: 0,
                            max: duration[index].inSeconds.toDouble(),
                            value: position[index].inSeconds.toDouble(),
                            onChanged: (value) async {
                              final position = Duration(seconds: value.toInt());
                              await audioplayer.seek(position);
                              setState(() {});
                            },
                          ),
                        )
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        manager.startDownloading();
                      },

                      // () async {
                      //   // data = await fetchdata(url);
                      //   // // var decoded = jsonDecode(data);
                      //   // setState(() {
                      //   //   print(data);
                      //   // });
                      //   manager.startDownloading
                      // },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.grey,
                        shape: const CircleBorder(),
                      ),
                      child: Column(
                        children: [
                          Visibility(
                            visible: !isDownload,
                            child: const Icon(
                              Icons.downloading_sharp,
                              color: Colors.white,
                              size: 40.0,
                            ),
                          ),
                          // Visibility(
                          //   visible: isDownload,
                          //   child: const Icon(
                          //     null,
                          //     color: Colors.white,
                          //     size: 40.0,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Stack(children: [
                  Container(
                    height: 80.0,
                    width: double.infinity,
                    color: const Color.fromARGB(255, 31, 31, 31),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          //             data = await fetchdata(url);
                          // // var decoded = jsonDecode(data);
                          // setState(() {
                          //   print(data);
                          // });
                          // try {
                          //   print("asds");
                          //   setState(() {
                          //     isLoading = true;
                          //   });

                          result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['mp3', 'ogg', 'wav'],
                            allowMultiple: false,
                          );
                          if (result != null) {
                            _filename = result!.files.first.name;
                            pickedfile = result!.files.first;

                            print("File name $pickedfile");
                            allFiles.add(pickedfile!);
                            isPlaying.add(false);
                            duration.add(Duration.zero);
                            position.add(Duration.zero);

                            setState(() {});
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(20),
                        ),
                        child: const SafeArea(
                          child: Icon(Icons.add,
                              color: Color.fromARGB(255, 0, 0, 0), size: 40.0),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          )
        ],
      ),
    );
  }
}
