import 'package:flutter/material.dart';
import 'package:flutter_sqlite/sql_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UKUR',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Test Ukut'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> _products = [];

  bool _isLoading = true;

  //ambil semua data dari database
  void _refreshJournals() async {
    final data = await SQLHelper.getProducts();
    setState(() {
      _products = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    _refreshJournals();
    super.initState();
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _showForm(int? id) async {
    if (id != null) {
      final existingProduct =
          _products.firstWhere((element) => element['id'] == id);
      _titleController.text = existingProduct['title'];
      _descriptionController.text = existingProduct['description'];
    }
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 15,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 120,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'Title'),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(hintText: 'Description'),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () async {
                if (id == null) {
                  await _addProduct();
                }

                if (id != null) {
                  await _updateProduct(id);
                }

                _titleController.text = '';
                _descriptionController.text = '';

                Navigator.of(context).pop();
              },
              child: Text(id == null ? 'Create' : 'Update'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _addProduct() async {
    await SQLHelper.createProduct(
        _titleController.text, _descriptionController.text);
    _refreshJournals();
  }

  Future<void> _updateProduct(int id) async {
    await SQLHelper.updateProduct(
        id, _titleController.text, _descriptionController.text);
    _refreshJournals();
  }

  Future<void> _deleteProduct(int id) async {
    await SQLHelper.deleteProduct(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a journal!'),
    ));
    _refreshJournals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) => Card(
                color: Colors.teal,
                margin: const EdgeInsets.all(15),
                child: ListTile(
                  title: Text(_products[index]['title']),
                  subtitle: Text(_products[index]['description']),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => _showForm(_products[index]['id']),
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: () =>
                              _deleteProduct(_products[index]['id']),
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
