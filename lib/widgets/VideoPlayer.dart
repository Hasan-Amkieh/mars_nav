import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart';

class VideoPlayer extends StatefulWidget {
  const VideoPlayer({Key? key, required this.filePath}) : super(key: key);

  final String filePath;

  @override
  State<VideoPlayer> createState() => VideoPlayerState();
}

class VideoPlayerState extends State<VideoPlayer> {
  final meeduPlayerController = MeeduPlayerController(
    controlsStyle: ControlsStyle.primary,
    enabledButtons: const EnabledButtons(pip: true),
    // enabledControls: const EnabledControls(doubleTapToSeek: false),
    pipEnabled: true,
    // header: header
  );

  StreamSubscription? _playerEventSubs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  @override
  void dispose() {
    _playerEventSubs?.cancel();
    meeduPlayerController.dispose();
    super.dispose();
  }

  _init() async {
    await meeduPlayerController.setDataSource(
        DataSource(
          type: DataSourceType.file,
          file: File(widget.filePath),
        ),
        autoplay: true,
        looping: false);
  }

  Widget get header {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Visibility(
            visible: false,
            child: CupertinoButton(
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.maybePop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
        stream: null,
        builder: (context, snapshot) {
          return AspectRatio(
            aspectRatio: 16 / 9,
            child: MeeduVideoPlayer(
              controller: meeduPlayerController,
              header: (context, controller, responsive) => header,
            ),
          );
        }
    );
  }
}