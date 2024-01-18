import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Ongoing Challenges'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance.collection('challenges').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          data['description'],
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) => ChallengeDetails(
                                challengeName: data['name'],
                              ),
                            );
                          },
                          child: const Text('Take the Challenge'),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}

class ChallengeDetails extends StatefulWidget {
  final String challengeName;

  const ChallengeDetails({required this.challengeName, super.key});

  @override
  State<ChallengeDetails> createState() => _ChallengeDetailsState();
}

class _ChallengeDetailsState extends State<ChallengeDetails> {
  bool isLoading = false;
  XFile? _pickedImage;
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _pickedImage = pickedImage;
      });
    }
  }

  Future<void> _submitChallenge() async {
    setState(() {
      isLoading = true;
    });
    String imageUrl = '';
    if (_pickedImage != null) {
      var imageName = DateTime.now().millisecondsSinceEpoch.toString();
      var storageRef =
          FirebaseStorage.instance.ref().child('feeds/$imageName.jpg');
      var uploadTask = storageRef.putFile(File(_pickedImage!.path));
      imageUrl = await (await uploadTask).ref.getDownloadURL();
    }

    User? user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    String username = user?.email?.split('@').first ?? 'Anonymous';

    CollectionReference feeds = FirebaseFirestore.instance.collection('feeds');
    feeds.add({
      'username': username,
      'challengeName': widget.challengeName,
      'image': imageUrl,
      'description': _descriptionController.text,
      'rating': 0
    }).then((value) {
      const SnackBar(content: Text("Challenge added successfully."));
      _clearInputFields();
      Navigator.of(context).pop();
    }).catchError((error) {
      const SnackBar(content: Text("Challenge added successfully."));
      _clearInputFields();
      Navigator.of(context).pop();
    });
    setState(() {
      isLoading = false;
    });
  }

  void _clearInputFields() {
    _pickedImage = null;
    _descriptionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedPadding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  Text(
                    widget.challengeName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20.0),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('Upload an image (optional)'),
                  ),
                  if (_pickedImage != null)
                    Image.file(File(_pickedImage!.path)),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Describe how you finished the challenge',
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _submitChallenge,
                          child: const Text('Submit'),
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
