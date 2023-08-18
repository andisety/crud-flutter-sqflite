import 'package:crud_db/databse/db_helper.dart';
import 'package:flutter/material.dart';

import 'model/note.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> allData = [];
  bool _isLoading = true;

  void _refreshData() async {
    final data = await SqlHelper.getData();
    setState(() {
      allData = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  void showBottomSheet(int? id) async {
    if (id != null) {
      final existData = allData.firstWhere((element) => element['id'] == id);
      _titleController.text = existData['title'];
      _descController.text = existData['desc'];
    }

    showModalBottomSheet(
      elevation: 5,
      isScrollControlled: true,
      context: context,
      builder: (_) => Container(
        padding: EdgeInsets.only(
            top: 30,
            left: 15,
            right: 15,
            bottom: MediaQuery.of(context).viewInsets.bottom + 50),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(), hintText: "Title"),
            ),
            SizedBox(
              height: 10,
            ),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: InputDecoration(
                  border: OutlineInputBorder(), hintText: "Description"),
            ),
            SizedBox(
              height: 20,
            ),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (id == null) {
                    await _addData();
                  }
                  if (id != null) {
                    await _updateData(id);
                  }
                  _titleController.text = "";
                  _descController.text = "";
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Text(
                    id == null ? "Add Data" : "Update",
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _addData() async {
    final Note note = Note(
        id: null, title: _titleController.text, desc: _descController.text);
    await SqlHelper.createdata(note);
    _refreshData();
  }

  Future<void> _updateData(int id) async {
    final Note note =
        Note(id: id, title: _titleController.text, desc: _descController.text);
    await SqlHelper.updatedata(note);
    _refreshData();
  }

  void _deleteData(int id) async {
    await SqlHelper.deleteData(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.redAccent, content: Text("data deleted")));
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CRUD"),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : allData.isEmpty
              ? Center(
                  child: Text("data empty"),
                )
              : ListView.builder(
                  itemCount: allData.length,
                  itemBuilder: (context, index) => Card(
                        margin: EdgeInsets.all(15),
                        child: ListTile(
                          title: Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: Text(
                              allData[index]['title'],
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          subtitle: Text(allData[index]['desc']),
                          trailing:
                              Row(mainAxisSize: MainAxisSize.min, children: [
                            IconButton(
                                onPressed: () {
                                  showBottomSheet(allData[index]['id']);
                                },
                                icon: Icon(
                                  Icons.edit,
                                  color: Colors.indigoAccent,
                                )),
                            IconButton(
                                onPressed: () {
                                  _deleteData(allData[index]['id']);
                                },
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                )),
                          ]),
                        ),
                      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showBottomSheet(null),
        child: Icon(Icons.add),
      ),
    );
  }
}
