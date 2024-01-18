import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  XFile? _pickedImage;
  final TextEditingController _headingController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('community').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: PostCard(
                  image: Image.network(
                    data['image_url'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                  ),
                  username: data['username'],
                  heading: data['heading'],
                  content: data['content'],
                  likes: data['likes'],
                  dislikes: data['dislikes'],
                  docId: document.id,
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPostDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddPostDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Post'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _pickImage(),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _pickedImage != null
                      ? Image.file(
                          File(_pickedImage!.path),
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.add_photo_alternate, size: 50),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _headingController,
                decoration: const InputDecoration(hintText: 'Heading'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(hintText: 'Content'),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _handlePostSubmission();
              Navigator.of(context).pop();
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

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

  void _handlePostSubmission() async {
    CollectionReference posts =
        FirebaseFirestore.instance.collection('community');
    var imageName = DateTime.now().millisecondsSinceEpoch.toString();

    var storageRef =
        FirebaseStorage.instance.ref().child('images/$imageName.jpg');
    var uploadTask = storageRef.putFile(File(_pickedImage!.path));

    var imageUrl = await (await uploadTask).ref.getDownloadURL();

    User? user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    String username = user?.email?.split('@').first ?? 'Anonymous';

    posts
        .add({
          'username': username,
          'heading': _headingController.text,
          'content': _contentController.text,
          'likes': 0,
          'dislikes': 0,
          'image_url': imageUrl,
        })
        .then((value) => const SnackBar(content: Text("Post Added.")))
        .catchError(
            (error) => const SnackBar(content: Text("Failed to add post.")));
  }
}

class PostCard extends StatelessWidget {
  const PostCard({
    Key? key,
    required this.image,
    required this.username,
    required this.heading,
    required this.content,
    required this.likes,
    required this.dislikes,
    required this.docId,
  }) : super(key: key);

  final Image image;
  final String username;
  final String heading;
  final String content;
  final int likes;
  final int dislikes;
  final String docId;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            image,
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(username,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(heading),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(content),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.thumb_up),
                  onPressed: () => _handleLike(),
                ),
                Text(likes.toString()),
                IconButton(
                  icon: const Icon(Icons.thumb_down),
                  onPressed: () => _handleDislike(),
                ),
                Text(dislikes.toString()),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _handleLike() {
    FirebaseFirestore.instance
        .collection('community')
        .doc(docId)
        .update({'likes': FieldValue.increment(1)});
  }

  void _handleDislike() {
    FirebaseFirestore.instance
        .collection('community')
        .doc(docId)
        .update({'dislikes': FieldValue.increment(1)});
  }
}
