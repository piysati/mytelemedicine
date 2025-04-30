import 'package:flutter/material.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:my_telemedicine/features/app/app_export.dart';
import 'package:my_telemedicine/features/app/constants.dart';

class MeetingScreen extends StatefulWidget {
  final String appointmentId;
  const MeetingScreen({Key? key, required this.appointmentId}) : super(key: key);

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  late HMSConfig config;
  late HMSSDK hmsSDK;
  List<HMSPeer> peers = [];
  bool _meetingStarted = false;
  String? _meetingError;

  @override
  void initState() {
    super.initState();
    hmsSDK = HMSSDK();
    setupMeeting();
  }

  void setupMeeting() async {
    hmsSDK.addUpdateListener(hmsUpdateListener: HMSUpdateListener(onJoin: onJoin, onRoomUpdate: onRoomUpdate, onPeerUpdate: onPeerUpdate, onTrackUpdate: onTrackUpdate, onMessage: onMessage, onError: onError, onReconnecting: onReconnecting, onReconnected: onReconnected, onRemovedFromRoom: onRemovedFromRoom));
    await hmsSDK.build();
    config = HMSConfig(
      userName: "testuser",
      authToken: hmsToken,
      roomId: widget.appointmentId
    );

    joinMeeting();
  }

  void onJoin(HMSMeeting meeting) {
    print("onJoin");
    setState(() {
      _meetingStarted = true;
      hmsSDK.startAudioOutput();
      peers = meeting.peers;
    });
  }

  void onRoomUpdate(HMSRoom room, HMSRoomUpdate update) {}
  
  void _updateUi(){
    setState(() {});
  }
  void onPeerUpdate(HMSPeer peer, HMSPeerUpdate update) {
    setState(() {
      if (update == HMSPeerUpdate.peerJoined) {
        peers.add(peer);
      } else if (update == HMSPeerUpdate.peerLeft) {
        peers.remove(peer);
      }
    });
  }

  void onTrackUpdate(HMSTrack track, HMSTrackUpdate update, HMSPeer peer) {
    _updateUi();
  }

  void onMessage(HMSMessage message) {}

  void onError(HMSError error) {
    setState(() {
      _meetingError = error.message;
    });
  }

  Widget _buildErrorWidget(){
    return Center(
      child: Column(
        children: [
          Text(_meetingError ?? ""),
        ],
      ),
    );
  }
  void onReconnecting() {}

  void onReconnected() {}

  void onRemovedFromRoom(HMSPeerRemovedFrom peerRemovedFrom) {}

  void joinMeeting() async {
    try {
      await hmsSDK.join(config: config);
    } catch (e) {
      setState(() {
        _meetingError = e.toString();
      });

    }
  }

  void leaveMeeting() async {
    await hmsSDK.leave();
  }

  Widget videoView(HMSPeer peer) {
    HMSVideoTrack? videoTrack = peer.videoTrack;
    return (videoTrack != null && !videoTrack.isMute)
        ? HMSVideoView(
            track: videoTrack,
            setMirror: true,
          )
        : Container(color: Colors.grey);
  }

  Widget buildPeerList() {
    return GridView.builder(
      itemCount: peers.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Show 2 videos per row
        childAspectRatio: 1.0, // Adjust as needed
      ),
      itemBuilder: (BuildContext context, int index) {
        return Container(
          margin: const EdgeInsets.all(8.0),
          child: Center(
            child: videoView(peers[index]),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    try {
      hmsSDK.leave();
      hmsSDK.removeUpdateListener();
      hmsSDK.destroy();
      hmsSDK.stopAudioOutput();
    } catch(e){
      print("Error in dispose: $e");
    }
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop){
        leaveMeeting();
        Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Meeting Screen'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              leaveMeeting();
              Navigator.of(context).pop();
            },
          ),
        ),
        body: _meetingError != null ? _buildErrorWidget() :
        (_meetingStarted ?
         buildPeerList() :
         const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          )
        )


      ),
    );
  }
}