import 'package:flutter/material.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:telehealth_app/setup/app_manager.dart';
import 'package:provider/provider.dart';
import 'package:telehealth_app/setup/sdkinitializer.dart';

import 'message_screen.dart';

class Meeting extends StatefulWidget {
  final String username;

  const Meeting({Key? key, required this.username}) : super(key: key);

  @override
  _MeetingState createState() => _MeetingState();
}

class _MeetingState extends State<Meeting> with WidgetsBindingObserver {
  bool selfLeave = false;
  bool isAudioOn = true;
  bool isVideoOn = true;
  bool isRoomEnded = false;
  Offset position = const Offset(10, 10);
  HMSLocalPeer? localPeer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // initMeeting();
  }

  @override
  Widget build(BuildContext context) {
    context.select<AppManager, HMSPeer?>((user) => user.remotePeer);
    final remoteTrack =
        context.select<AppManager, HMSTrack?>((user) => user.remoteVideoTrack);
    final localVideoTrack = context
        .select<AppManager, HMSVideoTrack?>((user) => user.localVideoTrack);

    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: const Text("100ms Telehealth App"),
        actions: [
          IconButton(
              onPressed: () {
                SdkInitializer.hmssdk.switchCamera();
              },
              icon: const Icon(Icons.camera_front)),
        ],
      ),
      drawer: ListenableProvider.value(
        value: Provider.of<AppManager>(context, listen: true),
        child: const MessageScreen(),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
            child: Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Flexible(
                        child: (remoteTrack != null)
                            ? HMSVideoView(
                                track: remoteTrack as HMSVideoTrack,
                                matchParent: false)
                            : const Center(
                                child:
                                    Text('Waiting for the Doctor to join!'))),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black,
                    child: IconButton(
                      icon: isAudioOn
                          ? const Icon(Icons.mic)
                          : const Icon(Icons.mic_off),
                      onPressed: () {
                        SdkInitializer.hmssdk.switchAudio();
                        setState(() {
                          isAudioOn = !isAudioOn;
                        });
                      },
                      color: Colors.blue,
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.black,
                    child: IconButton(
                      icon: isVideoOn
                          ? const Icon(Icons.videocam)
                          : const Icon(Icons.videocam_off),
                      onPressed: () {
                        SdkInitializer.hmssdk.switchVideo(isOn: isVideoOn);
                        if (!isVideoOn) {
                          SdkInitializer.hmssdk.startCapturing();
                        } else {
                          SdkInitializer.hmssdk.stopCapturing();
                        }
                        setState(() {
                          isVideoOn = !isVideoOn;
                        });
                      },
                      color: Colors.blue,
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.black,
                    child: Builder(builder: (context) {
                      return IconButton(
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                          icon: const Icon(Icons.message));
                    }),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.black,
                    child: IconButton(
                      icon: const Icon(Icons.call_end),
                      onPressed: () => showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                                title: const Text('Leave the Meeting?',
                                    style: TextStyle(fontSize: 24)),
                                actions: [
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.amberAccent),
                                      onPressed: () {
                                        SdkInitializer.hmssdk.leave();
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Yes',
                                          style: TextStyle(fontSize: 20))),
                                  ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel',
                                          style: TextStyle(fontSize: 24))),
                                ],
                              )),
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: position.dx,
            top: position.dy,
            child: Draggable<bool>(
                data: true,
                childWhenDragging: Container(),
                child: localPeerVideo(localVideoTrack),
                onDragEnd: (details) =>
                    {setState(() => position = details.offset)},
                feedback: Container(
                  height: 200,
                  width: 150,
                  color: Colors.black,
                  child: const Icon(
                    Icons.videocam_off_rounded,
                    color: Colors.white,
                  ),
                )),
          ),
        ],
      ),
    );
  }

  Widget localPeerVideo(HMSVideoTrack? localTrack) {
    return Container(
      height: 200,
      width: 150,
      color: Colors.black,
      child: (isVideoOn && localTrack != null)
          ? HMSVideoView(
              track: localTrack,
            )
          : const Icon(
              Icons.videocam_off_rounded,
              color: Colors.white,
            ),
    );
  }
}
