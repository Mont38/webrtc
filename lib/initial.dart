import 'package:flutter/material.dart';

class Initial extends StatefulWidget {
  const Initial({super.key});

  @override
  State<Initial> createState() => _InitialState();
}

class _InitialState extends State<Initial> {
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
            child: Row(
          children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/home');
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  backgroundColor: Color.fromARGB(255, 245, 161, 44),
                ),
                child: const Text(
                  'Start',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ))
          ],
        )));
  }
}
