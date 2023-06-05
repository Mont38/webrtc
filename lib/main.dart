import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:sdp_transform/sdp_transform.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

final _offercontroller = TextEditingController();
final candidatecontroller = TextEditingController();
final candidateUsercontroller = TextEditingController();
final sdpController = TextEditingController();
bool bandera = false;

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _localVideoRenderer = RTCVideoRenderer();
  final _remoteVideoRenderer = RTCVideoRenderer();

  final txtoffer = TextFormField(
    controller: _offercontroller,
    maxLines: 2,
    maxLength: TextField.noMaxLength,
    decoration: InputDecoration(
      labelText: 'codigo offer',
      labelStyle: TextStyle(
          color: Color.fromRGBO(
            244,
            244,
            244,
            1,
          ),
          fontSize: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Colors.grey.shade400,
          width: 2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color.fromRGBO(255, 178, 122, 1),
          width: 2,
        ),
      ),
      filled: true,
      fillColor: Color.fromARGB(126, 103, 66, 106),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color.fromRGBO(66, 71, 106, 0.5),
          width: 2,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    ),
  );
  final txtremote = TextFormField(
    controller: sdpController,
    maxLines: 4,
    maxLength: TextField.noMaxLength,
    decoration: InputDecoration(
      labelText: 'remoto',
      hintText: 'inserta codigo',
      labelStyle:
          TextStyle(color: Color.fromRGBO(244, 244, 244, 1), fontSize: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Colors.grey.shade400,
          width: 2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color.fromRGBO(255, 178, 122, 1),
          width: 2,
        ),
      ),
      filled: true,
      fillColor: const Color.fromRGBO(66, 71, 106, 0.5),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color.fromRGBO(66, 71, 106, 0.5),
          width: 2,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    ),
  );
  final txtCandidateremote = TextFormField(
    controller: candidatecontroller,
    maxLines: 4,
    maxLength: TextField.noMaxLength,
    decoration: InputDecoration(
      labelText: 'remoto candidato',
      hintText: 'inserta codigo',
      labelStyle:
          TextStyle(color: Color.fromRGBO(244, 244, 244, 1), fontSize: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Colors.grey.shade400,
          width: 2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color.fromRGBO(255, 178, 122, 1),
          width: 2,
        ),
      ),
      filled: true,
      fillColor: const Color.fromRGBO(66, 71, 106, 0.5),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color.fromRGBO(66, 71, 106, 0.5),
          width: 2,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    ),
  );
  final txtcandidate = TextFormField(
    controller: candidateUsercontroller,
    maxLines: 2,
    maxLength: TextField.noMaxLength,
    decoration: InputDecoration(
      labelText: 'candidato',
      labelStyle: TextStyle(color: Color.fromRGBO(244, 244, 244, 1)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Colors.grey.shade400,
          width: 2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color.fromRGBO(255, 178, 122, 1),
          width: 2,
        ),
      ),
      filled: true,
      fillColor: const Color.fromRGBO(66, 71, 106, 0.5),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color.fromRGBO(66, 71, 106, 0.5),
          width: 2,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    ),
  );

  bool _offer = false;

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;

  initRenderer() async {
    await _localVideoRenderer.initialize();
    await _remoteVideoRenderer.initialize();
  }

  _getUserMedia() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'facingMode': 'user',
      }
    };

    MediaStream stream =
        await navigator.mediaDevices.getUserMedia(mediaConstraints);

    _localVideoRenderer.srcObject = stream;
    return stream;
  }

  _createPeerConnecion() async {
    Map<String, dynamic> configuration = {
      'sdpSemantics': 'plan-b',
      "iceServers": [
        {"url": "stun:stun.l.google.com:19302"},
      ]
    };

    final Map<String, dynamic> offerSdpConstraints = {
      "mandatory": {
        "OfferToReceiveAudio": true,
        "OfferToReceiveVideo": true,
      },
      "optional": [],
    };

    _localStream = await _getUserMedia();

    RTCPeerConnection pc =
        await createPeerConnection(configuration, offerSdpConstraints);

    pc.addStream(_localStream!);

    pc.onIceCandidate = (e) {
      if (e.candidate != null) {
        print(json.encode({
          'candidate': e.candidate.toString(),
          'sdpMid': e.sdpMid.toString(),
          'sdpMlineIndex': e.sdpMLineIndex,
        }));

        if (bandera == true) {
          final guardar = json.encode({
            'candidate': e.candidate.toString(),
            'sdpMid': e.sdpMid.toString(),
            'sdpMlineIndex': e.sdpMLineIndex,
          });

          Map<String, dynamic> mapa = json.decode(guardar);

          // Acceder a los valores del mapa
          String candidate = mapa['candidate'];
          String sdpMid = mapa['sdpMid'];
          int sdpMlineIndex = mapa['sdpMlineIndex'];

          // Imprimir los valores
          print('Candidate: $candidate');
          print('sdpMid: $sdpMid');
          print('sdpMlineIndex: $sdpMlineIndex');
          if (candidate.contains('network-id 2') && candidate.contains('udp')) {
            candidateUsercontroller.text = guardar;
          }
        }
      }
    };

    pc.onIceConnectionState = (e) {
      print(e);
    };

    pc.onAddStream = (stream) {
      print('addStream: ' + stream.id);
      _remoteVideoRenderer.srcObject = stream;
    };

    return pc;
  }

  void _createOffer() async {
    RTCSessionDescription description =
        await _peerConnection!.createOffer({'offerToReceiveVideo': 1});
    var session = parse(description.sdp.toString());
    print(json.encode(session));

    _offer = true;
    _offercontroller.text = json.encode(session);

    _peerConnection!.setLocalDescription(description);
  }

  void _createAnswer() async {
    bandera = true;
    RTCSessionDescription description =
        await _peerConnection!.createAnswer({'offerToReceiveVideo': 1});

    var session = parse(description.sdp.toString());
    print("${json.encode(session)}iuwuwu");

    _peerConnection!
        .setLocalDescription(description)
        .then((value) => candidatecontroller.text = json.encode((session)));
  }

  void _setRemoteDescription() async {
    String jsonString = sdpController.text;
    dynamic session = await jsonDecode(jsonString);

    String sdp = write(session, null);

    RTCSessionDescription description =
        RTCSessionDescription(sdp, _offer ? 'answer' : 'offer');
    print("uw${description.toMap()}");

    await _peerConnection!.setRemoteDescription(description);
  }

  void _addCandidate() async {
    String jsonString = sdpController.text;
    dynamic session = await jsonDecode(jsonString);
    print(session['candidate']);
    dynamic candidate = RTCIceCandidate(
        session['candidate'], session['sdpMid'], session['sdpMlineIndex']);
    await _peerConnection!.addCandidate(candidate);
  }

  @override
  void initState() {
    initRenderer();
    _createPeerConnecion().then((pc) {
      _peerConnection = pc;
    });
    // _getUserMedia();
    super.initState();
  }

  @override
  void dispose() async {
    await _localVideoRenderer.dispose();
    sdpController.dispose();
    super.dispose();
  }

  SizedBox videoRenderers() => SizedBox(
        height: 210,
        child: Row(children: [
          Flexible(
            child: Container(
              key: const Key('local'),
              margin: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
              decoration: const BoxDecoration(color: Colors.black),
              child: RTCVideoView(_localVideoRenderer),
            ),
          ),
          Flexible(
            child: Container(
              key: const Key('remote'),
              margin: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
              decoration: const BoxDecoration(color: Colors.black),
              child: RTCVideoView(_remoteVideoRenderer),
            ),
          ),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(187, 204, 172, 218),
        appBar: AppBar(
            title: const Text("WebRTC"),
            centerTitle: true,
            elevation: 1,
            backgroundColor: const Color.fromARGB(255, 230, 191, 232),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ))),
        body: Container(
          decoration:
              const BoxDecoration(color: Color.fromARGB(187, 204, 172, 218)),
          child: Column(
            children: [
              videoRenderers(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: _createOffer,
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              padding: const EdgeInsets.all(20.0),
                              backgroundColor:
                                  const Color.fromARGB(255, 230, 191, 232)),
                          child: const Icon(Icons.person,
                              size: 15, color: Colors.black),
                        ),
                        const SizedBox(height: 3.0),
                        const Text('Offer'),
                        const SizedBox(height: 8.0),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: _createAnswer,
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              padding: const EdgeInsets.all(20.0),
                              backgroundColor:
                                  Color.fromARGB(255, 230, 191, 232)),
                          child: const Icon(Icons.people,
                              size: 15, color: Colors.black),
                        ),
                        const SizedBox(height: 3.0),
                        const Text('Answer'),
                        const SizedBox(height: 8.0),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: _setRemoteDescription,
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              padding: const EdgeInsets.all(20.0),
                              backgroundColor:
                                  Color.fromARGB(255, 230, 191, 232)),
                          child: const Icon(Icons.add_to_home_screen_sharp,
                              size: 15, color: Colors.black),
                        ),
                        const SizedBox(height: 3.0),
                        const Text('set remote'),
                        const SizedBox(height: 8.0),
                        const SizedBox(
                          height: 3,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: _addCandidate,
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              padding: const EdgeInsets.all(20.0),
                              backgroundColor:
                                  Color.fromARGB(255, 230, 191, 232)),
                          child: const Icon(Icons.person_add_alt_rounded,
                              size: 15, color: Colors.black),
                        ),
                        const SizedBox(height: 3.0),
                        const Text('add candidate'),
                        const SizedBox(height: 8.0),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("offer"),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: txtoffer,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text("candidato"),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: txtCandidateremote,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: txtcandidate,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.3,
                child: txtremote,
              ),
            ],
          ),
        ));
  }
}
