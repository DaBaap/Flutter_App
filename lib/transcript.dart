import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import "package:fyp/function.dart";
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:audioplayers/audioplayers.dart';

class transcript extends StatefulWidget {
  const transcript({super.key, required this.path});
  final String path;
  @override
  State<transcript> createState() => _transcriptState();
}

class _transcriptState extends State<transcript> {
  var transcript = [];
  var profile = [];

  bool isTranscript = false;
  bool isProfile = false;

  // double progress = 0;
  // ValueNotifier<double?> progressNotifier = ValueNotifier<double?>(0);
  final manager = StateManagerUpload();
  bool isUpload = false;

  //for Audio
  bool isPlaying = false;
  final audioplayer = AudioPlayer();
  final audioCache = AudioCache();
  int playingIndex = 0;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;

  late VideoPlayerController _controller;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset("images/bggif.mp4")
      ..initialize().then((_) {
        _controller.play();
        _controller.setLooping(true);
        setState(() {});
      });
    manager.lol(widget.path);
    audioplayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });
    audioplayer.onDurationChanged.listen((event) {
      setState(() {
        duration = event;
      });
    });
    audioplayer.onPositionChanged.listen((event) {
      setState(() {
        position = event;
      });
    });
  }

  void transcriptFunc() async {
    if (isUpload) {
      const String url = "https://FlutterApp.dabaap.repl.co/transcript";
      var data;
      data = await fetchdata(url);
      var decoded = jsonDecode(data);
      print(decoded);
      transcript = decoded;
      print("transcript");

      print(decoded[0]["Speaker"]);
      setState(() {
        isTranscript = true;
        // transcript = decoded;
      });
    }
  }

  void profileFunc() async {
    if (isUpload) {
      const String url = "https://FlutterApp.dabaap.repl.co/profile";
      var data;
      data = await fetchdata(url);
      var decoded = jsonDecode(data);
      print(decoded);
      profile = decoded;
      print("profile");

      // print(decoded[0]["Speaker"]);
      setState(() {
        isProfile = true;
        // transcript = decoded;
      });
    }
  }
  // late String path;
  // void lol() async {
  //   progressNotifier.value = null;

  //   const String url = "https://FlutterApp.dabaap.repl.co/";
  //   final request = http.MultipartRequest('POST', Uri.parse(url));
  //   // final headers = {"Content-type": "multipart/form-data"};
  //   var multipartFile = await http.MultipartFile.fromPath('audio', widget.path,
  //       contentType: MediaType.parse('audio/mp3'));
  //   request.files.add(multipartFile);

  //   // request.headers.addAll(headers);
  //   var response = await request.send();
  //   var byteStream = response.stream;
  //   var totalBytes = multipartFile.length;
  //   var bytesTransferred = 0;

  //   byteStream.listen((event) {
  //     bytesTransferred += event.length;
  //     progressNotifier.value = (bytesTransferred / totalBytes);
  //     // setState(() {});
  //     print(progressNotifier.value);
  //   });
  // }

  // print(r);
  // http.Response res = await http.Response.fromStream(r);
  // final reJson = jsonDecode(res.body);
  // // print(await r.stream.transform(utf8.decoder).join());
  // print(reJson["message"]);
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    // lol();
    return Stack(
      children: [
        Visibility(
          visible: !isUpload,
          child: Container(
            alignment: Alignment.center,
            color: const Color.fromARGB(183, 0, 0, 0),
            height: height,
            width: width,
          ),
        ),
        Scaffold(
          extendBodyBehindAppBar: true,
          extendBody: true,
          appBar: AppBar(
            elevation: 20.0,
            // scrolledUnderElevation: 500,
            shadowColor: Colors.black,
            toolbarHeight: 120.0,
            backgroundColor: const Color.fromARGB(80, 0, 0, 0),
            foregroundColor: Colors.white,
            title: Transform(
              transform: Matrix4.translationValues(-20, 0.0, 0.0),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                minVerticalPadding: 0.0,
                horizontalTitleGap: 15.0,
                leading: IconButton(
                  icon: Icon(
                    isPlaying
                        ? Icons.pause_circle_outline
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 50.0,
                  ),
                  onPressed: () async {
                    if (isPlaying) {
                      await audioplayer.pause();
                      setState(() {
                        isPlaying = false;
                      });
                    } else {
                      String fileName = widget.path;
                      print(fileName);
                      await audioplayer.play(DeviceFileSource(fileName));
                      setState(() {
                        isPlaying = true;
                      });
                    }
                  },
                ),
                title: Transform(
                  transform: Matrix4.translationValues(15, 0.0, 0.0),
                  child: Text(
                    widget.path.split("/").last,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 25.0,
                    ),
                  ),
                ),
                subtitle: Slider(
                  min: 0,
                  max: duration.inSeconds.toDouble(),
                  value: position.inSeconds.toDouble(),
                  onChanged: (value) async {
                    final position = Duration(seconds: value.toInt());
                    await audioplayer.seek(position);
                    setState(() {});
                  },
                ),
              ),
            ),
          ),
          body: Stack(
            children: [
              VideoPlayer(_controller),
              Container(
                color: const Color.fromARGB(209, 0, 0, 0),
                width: double.infinity,
                height: double.infinity,
              ),
              <Widget>[
                //! Transcript

                SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Visibility(
                            visible: !isTranscript,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const CircularProgressIndicator(),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    // color: Colors.red,
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Retrieving Data...",
                                      style: GoogleFonts.poppins(
                                        color: const Color.fromARGB(
                                            234, 255, 255, 255),
                                        fontSize: 25.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Visibility(
                            visible: isTranscript,
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: transcript.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Text.rich(
                                  TextSpan(
                                    // '${for(var i=0;i<transcript.length;i++){"print"}}',
                                    // text: ,
                                    children: <InlineSpan>[
                                      TextSpan(
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          text:
                                              "${transcript[index]['Speaker']}: \n"),
                                      TextSpan(
                                          style: const TextStyle(
                                              // color: Colors.red,
                                              ),
                                          text:
                                              "${transcript[index]['Transcript']} \n"),
                                    ],
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                    ),
                                    // textAlign: TextAlign.left,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                //! Profile
                SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Visibility(
                            visible: !isProfile,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const CircularProgressIndicator(),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    // color: Colors.red,
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Retrieving Data...",
                                      style: GoogleFonts.poppins(
                                        color: const Color.fromARGB(
                                            234, 255, 255, 255),
                                        fontSize: 25.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Visibility(
                            visible: isProfile,
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: transcript.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Card(
                                    color: const Color.fromARGB(
                                        102, 158, 158, 158),
                                    elevation: 20.0,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            profile[index]["Speaker"],
                                            style: GoogleFonts.rubik(
                                              color: Colors.white,
                                              fontSize: 30.0,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.person_rounded,
                                          size: 100.0,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Text.rich(
                                            TextSpan(
                                              // '${for(var i=0;i<transcript.length;i++){"print"}}',
                                              // text: ,
                                              children: <InlineSpan>[
                                                const TextSpan(
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    text: "Name: "),
                                                TextSpan(
                                                    style: const TextStyle(
                                                        // color: Colors.red,
                                                        ),
                                                    text: !profile[index]
                                                                ['Name']
                                                            .isEmpty
                                                        ? "${profile[index]['Name']} \n"
                                                        : "N/A\n"),
                                                const TextSpan(
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    text: "Age: "),
                                                TextSpan(
                                                    style: const TextStyle(
                                                        // color: Colors.red,
                                                        ),
                                                    text:
                                                        "${profile[index]['Age']} \n"),
                                                const TextSpan(
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    text: "Organization: "),
                                                TextSpan(
                                                    style: const TextStyle(
                                                        // color: Colors.red,
                                                        ),
                                                    text:
                                                        "${profile[index]['Org']} \n"),
                                                const TextSpan(
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    text: "Profession: "),
                                                TextSpan(
                                                    style: const TextStyle(
                                                        // color: Colors.red,
                                                        ),
                                                    text:
                                                        "${profile[index]['Prof']} \n"),
                                              ],
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: 20.0,
                                              ),
                                              // textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  color: Colors.blue,
                  alignment: Alignment.center,
                  child: const Text('Page 3'),
                ),
                Container(
                  color: Colors.yellow,
                  alignment: Alignment.center,
                  child: const Text('Page 4'),
                ),
              ][currentPageIndex],
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Visibility(
                    visible: !isUpload,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          color: const Color.fromARGB(183, 0, 0, 0),
                          height: height,
                          width: width,
                        ),
                        Container(
                          alignment: Alignment.center,
                          width: 200.0,
                          height: 200.0,
                          child: ValueListenableBuilder<double?>(
                              valueListenable: manager.progressNotifier,
                              builder: (context, value, child) {
                                if (value == 1.0) {
                                  isUpload = true;
                                  transcriptFunc();
                                  profileFunc();
                                  Future.delayed(Duration.zero, () {
                                    setState(() {});
                                  });
                                }
                                return LiquidCircularProgressIndicator(
                                  // value: value!,
                                  // valueColor: const AlwaysStoppedAnimation(Colors.grey),
                                  // backgroundColor: Colors.white,
                                  // direction: Axis.vertical,
                                  center: Text(
                                    "Uploading...",
                                    style: GoogleFonts.poppins(
                                      color: Colors.black87,
                                      fontSize: 25.0,
                                    ),
                                  ),
                                );
                              }),
                        ),
                      ],
                    ),
                  ),
                  Visibility(visible: isUpload, child: Container())
                ],
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Container(
                color: const Color.fromARGB(255, 31, 31, 31),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 10.0,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: GNav(
                        backgroundColor: const Color.fromARGB(255, 31, 31, 31),
                        color: Colors.white,
                        activeColor: Colors.white,
                        tabBackgroundColor: Colors.grey.shade800,
                        gap: 8,
                        onTabChange: (value) {
                          print(value);
                          currentPageIndex = value;
                          setState(() {});
                        },
                        tabs: const [
                          GButton(
                            icon: Icons.article,
                            text: "Transcription",
                          ),
                          GButton(
                            icon: Icons.perm_identity_outlined,
                            text: "Profile",
                          ),
                          GButton(
                            icon: Icons.emoji_emotions,
                            text: "Emotion",
                          ),
                          GButton(
                            icon: Icons.analytics,
                            text: "Analysis",
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
// NEXT
// Create for emotion tab
// Create for Analysis tab

// Create emotion detection in conversation bullshit
// Create Google API




