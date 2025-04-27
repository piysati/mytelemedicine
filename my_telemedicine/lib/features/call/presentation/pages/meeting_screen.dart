import 'package:flutter/material.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';

import '../../../../permission.dart';

class MeetingScreen extends StatefulWidget {
  final String roomID;
  final String userName;

  const MeetingScreen({Key? key, required this.roomID, required this.userName})
      : super(key: key);

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen>
    implements HMSUpdateListener {
  late HMSSDK _hmssdk;
  bool isMicOn = true;
  bool isVideoOn = true;

  @override
  void initState() {
    super.initState();
     getPermissions().then((value) => _initializeHMSSDK(getHMSConfig()));
   
  }

  Future<void> _initializeHMSSDK(HMSConfig config) async {
    _hmssdk = HMSSDK();
    await _hmssdk.build();
    _hmssdk.addUpdateListener(listener: this);
    _hmssdk.join(config: config);
  }
    HMSConfig getHMSConfig() {
    HMSConfig config = HMSConfig(
        userName: widget.userName,
        authToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2ZXJzaW9uIjoyLCJ0eXBlIjoiYXBwIiwiYXBwX2RhdGEiOm51bGwsImFjY2Vzc19rZXkiOiI2ODBlODEwODQ5NDRmMDY3MzEzYTk5MWEiLCJyb2xlIjoiaG9zdCIsInJvb21faWQiOiI2ODBlODExODM2ZDRjZmMxOTgxZjJiNjAiLCJ1c2VyX2lkIjoiMWU2Y2VjODYtYTMzNS00YzYyLTk4N2EtOTk4ZmQ2MDVhMzEyIiwiZXhwIjoxNzQ1ODY4MzI1LCJqdGkiOiJkZTQxNTRkYS1kOGM2LTQ3YjQtYjUzNS01ZjEyOTgwNTFiZWMiLCJpYXQiOjE3NDU3ODE5MjUsImlzcyI6IjY4MGU4MTA4NDk0NGYwNjczMTNhOTkxOCIsIm5iZiI6MTc0NTc4MTkyNSwic3ViIjoiYXBpIn0.WT4hsDDquodY-bfSzyuBWQ8E-O8MrnxQ7QHR2Vts5w0"); // Replace with your auth token
        //auth_token
    return config;

  void _joinRoom() async {
    HMSConfig config = HMSConfig(
        userName: widget.userName,
        authToken:
            "YOUR_AUTH_TOKEN_HERE"); // Replace with your auth token
    _hmssdk.join(config: config);
  }}

  @override
  void onJoin({required HMSRoom room}) {
    print("Joined room: ${room.name}");
  }

  @override
  void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {
    print("Peer updated: ${peer.name}, Update: $update");
    setState(() {});
  }

  @override
  void onTrackUpdate(
      {required HMSTrack track,
      required HMSTrackUpdate trackUpdate,
      required HMSPeer peer}) {
    print("Track updated: ${track.trackId}, Update: $trackUpdate");
    setState(() {});
  }

  @override
  void onError({required HMSException error}) {
    print("Error: ${error.message}");
  }

  @override
  void onMessage({required HMSMessage message}) {
    print("Message: ${message.message}");
  }

  void _toggleMic() async {
    await _hmssdk.switchAudio(isOn: !isMicOn);
    setState(() {
      isMicOn = !isMicOn;
    });
  }

  void _toggleVideo() async {
    await _hmssdk.switchVideo(isOn: !isVideoOn);
    setState(() {
      isVideoOn = !isVideoOn;
    });
  }

  void _leaveRoom() async {
    _hmssdk.leave();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Meeting Room ${widget.roomID}"),
      ),
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: _hmssdk.localPeer != null
              ? Stack(
                  children: [
                    GridView(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2),
                      children: [
                        ..._hmssdk.room?.peers
                                .where((peer) => peer.isLocal == false)
                                .map((peer) => peer.videoTrack != null
                                    ? Container(
                                        key: Key(peer.peerID),
                                        child: HMSVideoView(
                                          track: peer.videoTrack!,
                                        ))
                                    : Container(
                                        key: Key(peer.peerID),
                                        child: Center(
                                            child: Text("No video for ${peer.name}", style: TextStyle(color: Colors.white),)
                                        ),
                                    ))
                                .toList() ??
                            [],
                        if (_hmssdk.localPeer?.videoTrack != null)
                          Container(
                            child: HMSVideoView(
                                track: _hmssdk.localPeer!.videoTrack!),
                          ),
                      ],
                    ),
                  ],
                )
              : Center(child: Text("Loading")),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(isMicOn ? Icons.mic : Icons.mic_off),
              onPressed: _toggleMic,
            ),
            IconButton(
              icon: Icon(isVideoOn ? Icons.videocam : Icons.videocam_off),
              onPressed: _toggleVideo,
            ),
            IconButton(
              icon: const Icon(Icons.call_end),
              onPressed: _leaveRoom,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void onRemovedFromRoom(
      {required HMSPeer peer, required HMSRoom room}) {
    print("Removed from room: ${peer.name}");
  }

  @override
  void onReconnected() {
    print("Reconnected");
  }

  @override
  void onReconnecting() {
    print("Reconnecting");
  }

  @override
  void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {
    print("Room updated: ${room.name}, Update: $update");
  }
}