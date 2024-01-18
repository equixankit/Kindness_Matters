import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:kindness_matters/screens/sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kindness_matters/utils/image_constants.dart';
import 'package:kindness_matters/screens/infor.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({Key? key}) : super(key: key);

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const SignInScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kindness Matters'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InfoScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('feeds').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ClipRRect(
                    child: Image.asset(ImageConstant.feedHome),
                  ),
                );
              } else {
                index -= 1;

                Map<String, dynamic> data =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (data['image'] != null && data['image'] != '')
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20.0),
                              child: Image.network(
                                data['image'],
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          const SizedBox(height: 12.0),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.grey[200],
                                child:
                                    const Icon(Icons.person_outline, size: 18),
                              ),
                              const SizedBox(width: 8.0),
                              Text(
                                data['username'],
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16.0,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            data['challengeName'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(data["description"]),
                          const SizedBox(height: 16.0),
                          RatingBar(
                            initialRating: data['rating'].toDouble(),
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 35.0,
                            itemPadding:
                                const EdgeInsets.symmetric(horizontal: 2.0),
                            ratingWidget: RatingWidget(
                              full: const Icon(Icons.star, color: Colors.amber),
                              half: const Icon(Icons.star_half,
                                  color: Colors.amber),
                              empty: const Icon(Icons.star_border,
                                  color: Colors.amber),
                            ),
                            onRatingUpdate: (rating) {
                              FirebaseFirestore.instance
                                  .collection('feeds')
                                  .doc(snapshot.data!.docs[index].id)
                                  .update({
                                'rating': rating,
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
