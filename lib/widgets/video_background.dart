import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoBackground extends StatefulWidget {
  final String assetPath;
  final Widget child;
  final double overlayOpacity; // 遮罩强度 0~1

  const VideoBackground({
    super.key,
    required this.assetPath,
    required this.child,
    this.overlayOpacity = 0.30,
  });

  @override
  State<VideoBackground> createState() => _VideoBackgroundState();
}

class _VideoBackgroundState extends State<VideoBackground> {
  late final VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.assetPath)
      ..setLooping(true)
      ..setVolume(0.0)
      ..initialize().then((_) {
        if (!mounted) return;
        _controller.play();
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inited = _controller.value.isInitialized;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (inited)
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          )
        else
          const ColoredBox(color: Colors.black),

        // 轻微遮罩，让文字更清晰
        ColoredBox(color: Colors.black.withOpacity(widget.overlayOpacity)),

        // 前景内容
        widget.child,
      ],
    );
  }
}
