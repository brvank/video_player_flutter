import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';

class JVideoPlayer extends StatefulWidget {
  const JVideoPlayer({Key? key}) : super(key: key);

  @override
  State<JVideoPlayer> createState() => _JVideoPlayerState();
}

enum JPlayerState { playing, loading, error, completed }

class _JVideoPlayerState extends State<JVideoPlayer>
    with TickerProviderStateMixin {
  late AnimationController playPauseAnimationController,
      thumbAnimationController,
      videoControllerAnimationController,
      seekForwardAnimationController,
      seekBackwardAnimationController;
  late Tween playePauseTween,
      thumbTween,
      videoControllerTween,
      seekForwardTween,
      seekBackwardTween;
  late Animation playPauseAnimation,
      thumbAnimation,
      videoControllerAnimation,
      seekForwardAnimation,
      seekBackwardAnimation;
  late VideoPlayerController videoPlayerController;
  double opacity = 0;
  double duration = 0;
  double position = 0;
  double radius = 16;
  double timeLineHeight = 4;
  late Duration dateTime;
  late Timer disableTimer;
  JPlayerState jPlayerState = JPlayerState.loading;

  @override
  void initState() {
    super.initState();

    int temp = duration.toInt();
    dateTime = Duration(seconds: temp);
    print(dateTime.toString().substring(0, 8));

    setUpAnimation();
    setUpPlayer();
  }

  Future<void> setUpPlayer() async {
    setState(() {
      jPlayerState = JPlayerState.loading;
    });
    try {
      videoPlayerController = VideoPlayerController.network(
          'https://multiplatform-f.akamaihd.net/i/multi/will/bunny/big_buck_bunny_,640x360_400,640x360_700,640x360_1000,950x540_1500,.f4v.csmil/master.m3u8');
      videoPlayerController.initialize().then((value) {
        setState(() {
          jPlayerState = JPlayerState.playing;
          videoPlayerController.play();
          duration = videoPlayerController.value.duration.inSeconds.toDouble();
          position = 0;
          removeVideoController();
        });
      });
      videoPlayerController.addListener(listener);
    } catch (e) {
      print('error');
      print(e);
      setState(() {
        jPlayerState = JPlayerState.error;
      });
    }
  }

  void listener() {
    if (videoPlayerController.value.isPlaying) {
      setState(() {
        position = videoPlayerController.value.position.inSeconds.toDouble();
        jPlayerState = JPlayerState.playing;
      });
    } else if (videoPlayerController.value.isBuffering) {
      setState(() {
        print('buffering');
        jPlayerState = JPlayerState.loading;
      });
    } else if (videoPlayerController.value.hasError) {
      setState(() {
        jPlayerState = JPlayerState.error;
      });
    } else if (videoPlayerController.value.position ==
        videoPlayerController.value.duration) {
      setState(() {
        jPlayerState = JPlayerState.completed;
      });
    }else if(videoPlayerController.value.isLooping) {
      setState(() {
        print('looping');
        jPlayerState = JPlayerState.loading;
      });
    }else{
      print('something different =============================================== \n${videoPlayerController.value}');
    }
  }

  Widget JPlayerWidget() {
    return jPlayerState == JPlayerState.loading
        ? Container(
            color: Colors.black,
          )
        : JPlayer();
  }

  Widget JPlayer() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: VideoPlayer(videoPlayerController),
    );
  }

  Future<void> setUpAnimation() async {
    playPauseAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    thumbAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    videoControllerAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    seekForwardAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    seekBackwardAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));

    playePauseTween = Tween<double>(begin: 0, end: (2 * pi) / 3);
    thumbTween = Tween<double>(begin: 0, end: 2);
    videoControllerTween = Tween<double>(begin: 1, end: 0);
    seekForwardTween = Tween<double>(begin: 0, end: pi);
    seekBackwardTween = Tween<double>(begin: 0, end: pi);

    playPauseAnimation = playePauseTween.animate(playPauseAnimationController);
    thumbAnimation = thumbTween.animate(thumbAnimationController);
    videoControllerAnimation =
        videoControllerTween.animate(videoControllerAnimationController);
    seekForwardAnimation =
        seekForwardTween.animate(seekForwardAnimationController);
    seekBackwardAnimation =
        seekForwardTween.animate(seekBackwardAnimationController);

    seekForwardAnimationController.addListener(() {
      setState(() {});
    });

    seekBackwardAnimationController.addListener(() {
      setState(() {});
    });

    videoControllerAnimationController.addListener(() {
      setState(() {});
    });

    thumbAnimationController.addListener(() {
      setState(() {});
    });

    playPauseAnimationController.addListener(() {
      setState(() {
        opacity = playPauseAnimationController.value;
      });
    });

    // removeVideoController();
  }

  Future<void> removeVideoController() async {
    disableTimer = Timer(Duration(seconds: 3), () {
      print('removing controller');
      videoControllerAnimationController.forward();
    });
  }

  void playOrpause() {
    if (playPauseAnimationController.isCompleted) {
      if (disableTimer.isActive) {
        print('stoping timer');
        disableTimer.cancel();
      }

      if (!videoPlayerController.value.isPlaying) {
        videoPlayerController.play();
      }
      playPauseAnimationController.reverse();
      removeVideoController();
    } else {
      if (disableTimer.isActive) {
        print('stoping timer');
        disableTimer.cancel();
      }
      if (videoPlayerController.value.isPlaying) {
        videoPlayerController.pause();
      }
      playPauseAnimationController.forward();
      removeVideoController();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          JPlayerWidget(),
          Container(
            child: jPlayerState == JPlayerState.loading
                ? progressIndicator()
                : jPlayerState == JPlayerState.completed ||
                        jPlayerState == JPlayerState.error
                    ? refreshWidget()
                    : Stack(
                        children: [
                          Center(
                            child: AnimatedBuilder(
                                animation: videoControllerAnimation,
                                child: videoControllerWidget(),
                                builder: (context, child) {
                                  return Opacity(
                                    opacity: videoControllerAnimation.value,
                                    child: child,
                                  );
                                }),
                          ),
                          Positioned(
                            right: 20,
                            top: 0,
                            bottom: 0,
                            child: AnimatedBuilder(
                              animation: seekForwardAnimation,
                              child: Icon(
                                CupertinoIcons.chevron_right_2,
                                color: Colors.white,
                              ),
                              builder: (context, child) {
                                return Opacity(
                                  opacity: sin(seekForwardAnimation.value),
                                  child: child,
                                );
                              },
                            ),
                          ),
                          Positioned(
                            left: 20,
                            top: 0,
                            bottom: 0,
                            child: AnimatedBuilder(
                              animation: seekBackwardAnimation,
                              child: Icon(
                                CupertinoIcons.chevron_left_2,
                                color: Colors.white,
                              ),
                              builder: (context, child) {
                                return Opacity(
                                  opacity: sin(seekBackwardAnimation.value),
                                  child: child,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
          )
        ],
      ),
    );
  }

  Widget refreshWidget() {
    return Center(
      child: InkWell(
        child: Icon(
          Icons.replay,
          color: Colors.white,
          size: 40,
        ),
        onTap: () {
          //TODO: return to position 0 or retry
          setUpPlayer();
        },
      ),
    );
  }

  Widget progressIndicator() {
    return Center(
      child: CircularProgressIndicator(
        color: Colors.white,
        strokeWidth: 2,
      ),
    );
  }

  Widget videoControllerWidget() {
    return LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onDoubleTap: () {},
        onDoubleTapDown: (tap) {
          print(tap.localPosition);
          print(constraints);
          if (tap.localPosition.dx > constraints.maxWidth / 2) {
            print('right');
            seekPosition(5);
            if (seekForwardAnimationController.isCompleted) {
              seekForwardAnimationController.reverse();
            } else {
              seekForwardAnimationController.forward();
            }
          } else {
            print('left');
            seekPosition(-5);
            if (seekBackwardAnimationController.isCompleted) {
              seekBackwardAnimationController.reverse();
            } else {
              seekBackwardAnimationController.forward();
            }
          }
        },
        onTap: () {
          if (videoControllerAnimationController.isCompleted) {
            videoControllerAnimationController.reverse();
            removeVideoController();
          } else {
            if (disableTimer.isActive) {
              disableTimer.cancel();
            }
            videoControllerAnimationController.forward();
          }
        },
        child: Stack(children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Color(0x66000000),
              child: Center(
                child: AnimatedBuilder(
                    animation: playPauseAnimation,
                    child: play(),
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: playPauseAnimation.value,
                        child: child,
                      );
                    }),
              ),
            ),
          ),
          timer(constraints),
          Positioned(
            left: 22,
            bottom: 2,
            child: Text(
              '${time(Duration(seconds: position.toInt()))}/${time(Duration(seconds: duration.toInt()))}',
              style: TextStyle(color: Colors.white),
            ),
          )
        ]),
      );
    });
  }

  Widget timer(BoxConstraints constraints) {
    return Positioned(
        bottom: 0,
        right: 0,
        left: 0,
        child: Container(
          padding: EdgeInsets.all(8),
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.all(radius / 2 - timeLineHeight / 2 + 8),
                child: LinearProgressIndicator(
                  minHeight: timeLineHeight,
                  value: position / duration,
                  backgroundColor: Colors.grey,
                  color: Colors.white,
                ),
              ),
              Positioned(
                left: 40,
                child: Container(
                  padding: EdgeInsets.all(radius / 2 - timeLineHeight / 2 + 8),
                  child: Container(
                      height: timeLineHeight, width: 8, color: Colors.yellow),
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                    left: 8 +
                        (constraints.maxWidth - 24 - 16 - radius / 2) *
                            (position / duration),
                    top: 8,
                    bottom: 8),
                child: GestureDetector(
                  child: thumb(),
                  onHorizontalDragCancel: () {
                    if (disableTimer.isActive) {
                      disableTimer.cancel();
                    }
                    thumbAnimationController.forward();
                    removeVideoController();
                  },
                  onHorizontalDragDown: (dragDetails) {
                    if (disableTimer.isActive) {
                      disableTimer.cancel();
                    }
                    thumbAnimationController.reverse();
                  },
                  onHorizontalDragEnd: (dragDetails) {
                    if (disableTimer.isActive) {
                      disableTimer.cancel();
                    }
                    videoPlayerController
                        .seekTo(Duration(seconds: position.toInt()));
                    thumbAnimationController.reverse();
                    removeVideoController();
                  },
                  onHorizontalDragStart: (dragDetails) {
                    if (disableTimer.isActive) {
                      disableTimer.cancel();
                    }
                    thumbAnimationController.forward();
                  },
                  onHorizontalDragUpdate: (dragDetails) {
                    double temp = dragDetails.delta.dx;
                    // seekPosition(temp);
                    // //TODO: not working now
                    // if (position == 40) {
                    //   print('reached to 40');
                    //   HapticFeedback.vibrate();
                    //   HapticFeedback.heavyImpact();
                    // }
                  },
                ),
              ),
            ],
          ),
        ));
    // return Slider(
    //   value: position / duration,
    //   thumbColor: Colors.white,
    //   onChanged: (change) {},
    //   onChangeEnd: (value) {
    //     videoPlayerController
    //         .seekTo(Duration(seconds: (value * duration).toInt()));
    //   },
    // );
  }

  void seekPosition(double temp) {
    // if (position + temp >= 0 && position + temp <= duration) {
    //   setState(() {
    //     position += temp;
    //   });
    // } else {
    //   if (position + temp < 0) {
    //     setState(() {
    //       position = 0;
    //     });
    //   } else {
    //     position = duration;
    //   }
    // }
    videoPlayerController.seekTo(Duration(
        seconds:
            videoPlayerController.value.position.inSeconds + temp.toInt()));
  }

  Widget thumb() {
    return AnimatedBuilder(
        animation: thumbAnimation,
        child: Icon(
          Icons.circle,
          color: Colors.white,
          size: radius,
        ),
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + thumbAnimation.value / 4,
            child: child,
          );
        });
  }

  Widget play({Color color = Colors.white}) {
    return Container(
      child: jPlayerState == JPlayerState.error ||
              jPlayerState == JPlayerState.completed
          ? refreshWidget()
          : GestureDetector(
              child: opacity > 0.5
                  ? Opacity(
                      opacity: opacity,
                      child: Icon(
                        Icons.play_arrow,
                        color: color,
                        size: 40,
                      ),
                    )
                  : Opacity(
                      opacity: 1 - opacity,
                      child: Icon(
                        Icons.pause,
                        color: color,
                        size: 40,
                      ),
                    ),
              onTap: () {
                if (videoControllerAnimationController.value == 1) {
                  videoControllerAnimationController.reverse();
                  removeVideoController();
                } else {
                  playOrpause();
                }
              },
            ),
    );
  }

  String time(Duration duration) {
    if (duration.inHours >= 10) {
      return duration.toString().substring(0, 8);
    } else {
      return duration.toString().substring(0, 7);
    }
  }
}
