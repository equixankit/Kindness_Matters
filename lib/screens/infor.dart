import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: Text("Kindness Matters",
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child:
                    Image.asset("assets/icon512.png", width: 350, height: 250),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                  "Idea by Ansh Patil,\nEmail : patilansh260308@gmail.com,\nIndus International School, Bengaluru",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18)),
            ),
          ],
        ));
  }
}
