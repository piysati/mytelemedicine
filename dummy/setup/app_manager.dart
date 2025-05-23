import 'package:flutter/cupertino.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:my_telemedicine/models/message.dart';
import 'package:my_telemedicine/setup/sdkinitializer.dart';
import 'package:telehealth_app/models/message.dart';
import 'package:telehealth_app/setup/sdkinitializer.dart';

class AppManager extends ChangeNotifier implements HMSUpdateListener {
  //To store remote peer tracks and peer objects
  HMSTrack? remoteVideoTrack;
  HMSPeer? remotePeer;
  HMSTrack? remoteAudioTrack;
  HMSVideoTrack? localVideoTrack;
  bool _disposed = false;
  List<Message> messages = [];
  late HMSPeer localPeer;

  //Method to attach listener to sdk
  void startListen() {
    SdkInitializer.hmssdk.addUpdateListener(listener: this);
  }

  //To dispose the objects when user leaves the room
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  //Method provided by Provider to notify the listeners whenever there is a change in the model
  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  //Method to listen to local Peer join update
  @override
  void onJoin({required HMSRoom room}) {
    print("before joining");
    for (HMSPeer each in room.peers!) {
      if (each.isLocal) {
        localPeer = each;
        break;
      }
    }
  }

  //Method to listen to peer Updates we are only using peerJoined and peerLeft updates here
  @override
  void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {
    switch (update) {
      //To handle when peer joins
      //We are setting up remote peers audio and video track here.
      case HMSPeerUpdate.peerJoined:
        messages = [];
        remotePeer = peer;
        remoteAudioTrack = peer.audioTrack;
        remoteVideoTrack = peer.videoTrack;
        break;
      // Setting up the remote peer to null so that we can render UI accordingly
      case HMSPeerUpdate.peerLeft:
        messages = [];
        remotePeer = null;
        break;
      case HMSPeerUpdate.audioToggled:
        break;
      case HMSPeerUpdate.videoToggled:
        break;
      case HMSPeerUpdate.roleUpdated:
        break;
      case HMSPeerUpdate.metadataChanged:
        break;
      case HMSPeerUpdate.nameChanged:
        break;
      case HMSPeerUpdate.defaultUpdate:
        break;
    }
    notifyListeners();
  }

  //Method to get Track Updates of all the peers
  @override
  void onTrackUpdate(
      {required HMSTrack track,
      required HMSTrackUpdate trackUpdate,
      required HMSPeer peer}) {
    switch (trackUpdate) {
      //Setting up tracks for remote peers
      //When a track is added for the first time
      case HMSTrackUpdate.trackAdded:
        if (track.kind == HMSTrackKind.kHMSTrackKindAudio) {
          if (!track.peer!.isLocal) remoteAudioTrack = track;
        } else if (track.kind == HMSTrackKind.kHMSTrackKindVideo) {
          if (!track.peer!.isLocal) {
            remoteVideoTrack = track;
          } else {
            localVideoTrack = track as HMSVideoTrack;
          }
        }
        break;
      //When a track is removed
      case HMSTrackUpdate.trackRemoved:
        if (track.kind == HMSTrackKind.kHMSTrackKindAudio) {
          if (!track.peer!.isLocal) remoteAudioTrack = null;
        } else if (track.kind == HMSTrackKind.kHMSTrackKindVideo) {
          if (!track.peer!.isLocal) {
            remoteVideoTrack = null;
          } else {
            localVideoTrack = null;
          }
        }
        break;
      //Case when someone mutes audio/video
      case HMSTrackUpdate.trackMuted:
        if (track.kind == HMSTrackKind.kHMSTrackKindAudio) {
          if (!track.peer!.isLocal) remoteAudioTrack = track;
        } else if (track.kind == HMSTrackKind.kHMSTrackKindVideo) {
          if (!track.peer!.isLocal) {
            remoteVideoTrack = track;
          } else {
            localVideoTrack = null;
          }
        }
        break;
      //Case when someone unmutes audio/video
      case HMSTrackUpdate.trackUnMuted:
        if (track.kind == HMSTrackKind.kHMSTrackKindAudio) {
          if (!track.peer!.isLocal) remoteAudioTrack = track;
        } else if (track.kind == HMSTrackKind.kHMSTrackKindVideo) {
          if (!track.peer!.isLocal) {
            remoteVideoTrack = track;
          } else {
            localVideoTrack = track as HMSVideoTrack;
          }
        }
        break;
      case HMSTrackUpdate.trackDescriptionChanged:
        break;
      case HMSTrackUpdate.trackDegraded:
        break;
      case HMSTrackUpdate.trackRestored:
        break;
      case HMSTrackUpdate.defaultUpdate:
        break;
    }
    notifyListeners();
  }

  //Method to listen to remote peer messages
  @override
  void onMessage({required HMSMessage message}) {
    Message _newMessage = Message(
        message: message.message,
        peerId: message.sender!.peerId,
        time: message.time,
        senderName: message.sender!.name);
    messages.add(_newMessage);
    notifyListeners();
  }

  //Method to listen to Error Updates
  @override
  void onError({required HMSException error}) {
    print(error.message);
  }

  //Method to get the list of current speakers
  @override
  void onUpdateSpeakers({required List<HMSSpeaker> updateSpeakers}) {}

  //Method to listen to room updates
  @override
  void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {}

  //Method to listen when the reconnection is successful
  @override
  void onReconnected() {}

  //Method to listen while reconnection
  @override
  void onReconnecting() {}

  //Method to be listened when remote peer remove local peer from room
  @override
  void onRemovedFromRoom(
      {required HMSPeerRemovedFromPeer hmsPeerRemovedFromPeer}) {}

  //Method to listen to role change request
  @override
  void onRoleChangeRequest({required HMSRoleChangeRequest roleChangeRequest}) {}

  //Method to listen to change track request
  @override
  void onChangeTrackStateRequest(
      {required HMSTrackChangeRequest hmsTrackChangeRequest}) {}
      
        @override
        void onAudioDeviceChanged({HMSAudioDevice? currentAudioDevice, List<HMSAudioDevice>? availableAudioDevice}) {
          // TODO: implement onAudioDeviceChanged
        }
      
        @override
        void onHMSError({required HMSException error}) {
          // TODO: implement onHMSError
        }
      
        @override
        void onPeerListUpdate({required List<HMSPeer> addedPeers, required List<HMSPeer> removedPeers}) {
          // TODO: implement onPeerListUpdate
        }
      
        @override
        void onSessionStoreAvailable({HMSSessionStore? hmsSessionStore}) {
          // TODO: implement onSessionStoreAvailable
        }
}
