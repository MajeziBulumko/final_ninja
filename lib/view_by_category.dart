import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_ninja/view_by_category.dart';

class ViewCat extends StatefulWidget {
  //this seems to be null when I try to write code that uses it.
  // Please assist here.
  final String category; //here

  const ViewCat({Key? key, required this.category}) : super(key: key);

  @override
  State<ViewCat> createState() => _ViewCatState();
}

class _ViewCatState extends State<ViewCat> {
  final TextEditingController name = TextEditingController();
  final TextEditingController price = TextEditingController();
  final TextEditingController store = TextEditingController();
  final TextEditingController units = TextEditingController();
  final TextEditingController uom = TextEditingController();

  final CollectionReference _prods =
      FirebaseFirestore.instance.collection('products');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(''),
        ),
      ),
      body: StreamBuilder(
        stream: _prods.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnap) {
          if (streamSnap.hasData) {
            return ListView.builder(
              itemCount: streamSnap.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot docSnap = streamSnap.data!.docs[index];
                return ListTile();
                //trying to view each product, by category, with all its details
                //and make it clickable for editing.
              },
            );
          }
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.green,
            ),
          );
        },
      ),
    );
  }
}
