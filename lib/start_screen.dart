import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_ninja/view_by_category.dart';

// the start screen with all the categories.
// each product has a different categeory.
// so it only makes sense to view each one
// by its category

class StartScreen extends StatefulWidget {
  StartScreen({super.key});
  bool loading = false;
  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final TextEditingController name = TextEditingController();

  final CollectionReference _cats =
      FirebaseFirestore.instance.collection('categories');

  Future<void> _update([DocumentSnapshot? docSnap]) async {
    if (docSnap != null) {
      name.text = docSnap['name'];
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext bctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(bctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                ElevatedButton(
                    onPressed: () async {
                      final String mane = name.text;
                      await _cats.doc(docSnap!.id).update({"category": mane});
                      name.text = '';
                                        },
                    child: const Text('update'))
              ],
            ),
          );
        });
  }

  Future<void> _delete(String catId) async {
    await _cats.doc(catId).delete();

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category has been deleted')));
  }

  Future<void> _create() async {
    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext bctx) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(bctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                  onPressed: () async {
                    final String mane = name.text;

                    await _cats.add({"category": mane});
                    name.text = '';
                    Navigator.of(context).pop();
                                    },
                  child: const Text('Create'))
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Categories'),
        ),
      ),
      body: StreamBuilder(
        stream: _cats.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnap) {
          if (streamSnap.hasData) {
            return ListView.builder(
              itemCount: streamSnap.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot docSnap = streamSnap.data!.docs[index];
                String catego = docSnap['category'];
                return Card(
                  child: GestureDetector(
                    onDoubleTap: () {
                      setState(() {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (BuildContext context) {
                          return ViewCat(
                              category: catego); // this line in particular
                        }));
                      });
                    },
                    child: ListTile(
                      onTap: (() async {
                        ViewCat(category: catego);
                      }),
                      title: Text(docSnap['category']),
                      trailing: SizedBox(
                        width: 150,
                        child: Row(
                          children: [
                            IconButton(
                                onPressed: () => _update(docSnap),
                                icon: const Icon(Icons.edit)),
                            IconButton(
                                onPressed: () => _delete(docSnap.id),
                                icon: const Icon(Icons.delete)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (() => _create()),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
