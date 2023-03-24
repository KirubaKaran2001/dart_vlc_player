import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class DartVLCExample extends StatefulWidget {
  const DartVLCExample({super.key});

  @override
  DartVLCExampleState createState() => DartVLCExampleState();
}

class DartVLCExampleState extends State<DartVLCExample> {
  Player player = Player(
    id: 0,
    videoDimensions: const VideoDimensions(640, 360),
    registerTexture: !Platform.isWindows,

  );
  
  MediaType mediaType = MediaType.file;
  CurrentState current = CurrentState();
  PositionState position = PositionState();
  PlaybackState playback = PlaybackState();
  GeneralState general = GeneralState();
  VideoDimensions videoDimensions = const VideoDimensions(0, 0);
  List<Media> medias = <Media>[];
  List<Device> devices = <Device>[];
  TextEditingController controller = TextEditingController();
  TextEditingController metasController = TextEditingController();
  double bufferingProgress = 0.0;
  Media? metasMedia;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      player.currentStream.listen((current) {
        setState(() => this.current = current);
      });
      player.positionStream.listen((position) {
        setState(() => this.position = position);
      });
      player.playbackStream.listen((playback) {
        setState(() => this.playback = playback);
      });
      player.generalStream.listen((general) {
        setState(() => this.general = general);
      });
      player.videoDimensionsStream.listen((videoDimensions) {
        setState(() => this.videoDimensions = videoDimensions);
      });
      player.bufferingProgressStream.listen(
        (bufferingProgress) {
          setState(() => this.bufferingProgress = bufferingProgress);
        },
      );
      player.errorStream.listen((event) {
        debugPrint('libvlc error.');
      });
      devices = Devices.all;
      Equalizer equalizer = Equalizer.createMode(EqualizerMode.live);
      equalizer.setPreAmp(10.0);
      equalizer.setBandAmp(31.25, 10.0);
      player.setEqualizer(equalizer);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('dart_vlc'),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return importMedia();
                  },
                );
              },
              icon: const Icon(Icons.album),
            ),
            IconButton(
              onPressed: () {
                writeToFilee();
              },
              icon: const Icon(Icons.download),
            ),
          ],
        ),
        body: Platform.isWindows
            ? NativeVideo(
                player: player,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                volumeThumbColor: Colors.blue,
                volumeActiveColor: Colors.blue,
                showControls: true,
              )
            : Video(
                player: player,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                volumeThumbColor: Colors.blue,
                volumeActiveColor: Colors.blue,
                showControls: true,
              ),
      ),
    );
  }

  Widget importMedia() {
    return AlertDialog(
      actions: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      cursorWidth: 1.0,
                      autofocus: true,
                      style: const TextStyle(
                        fontSize: 14.0,
                      ),
                      decoration: const InputDecoration.collapsed(
                        hintStyle: TextStyle(
                          fontSize: 14.0,
                        ),
                        hintText: 'Enter Media path.',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  if (mediaType == MediaType.file) {
                    medias.add(
                      Media.file(
                        File(
                          controller.text.replaceAll('"', ''),
                        ),
                      ),
                    );
                  } else if (mediaType == MediaType.network) {
                    medias.add(
                      Media.network(
                        controller.text,
                      ),
                    );
                  }
                  setState(() {});
                },
                child: const Text('Add To Playlist'),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  setState(
                    () {
                      player.open(
                        Playlist(
                          medias: medias,
                          playlistMode: PlaylistMode.single,
                        ),
                      );
                    },
                  );
                  Navigator.pop(context);
                },
                child: const Text('Open Into Player'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<File> writeToFilee() async {
    const url =
        'https://assets.mixkit.co/videos/preview/mixkit-people-pouring-a-warm-drink-around-a-campfire-513-large.mp4';
    const outputFilePath = 'video.mp4';
    final response = await http.get(Uri.parse(url));
    Directory? tempDir = await getDownloadsDirectory();
    String tempPath = tempDir!.path;
    var filePath = '$tempPath/' '$outputFilePath';
    await File(filePath).writeAsBytes(response.bodyBytes);
    return File(filePath).writeAsBytes(response.bodyBytes);
  }
}

