import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../api/new_service.dart';

class NewsView extends StatefulWidget {
  const NewsView({Key? key}) : super(key: key);

  @override
  State<NewsView> createState() => _NewsViewState();
}

class _NewsViewState extends State<NewsView> {
  List<dynamic> newsList = []; // Updated to hold dynamic news data
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    try {
      var service = NewService();
      List<dynamic> newsData = await service.getAllNews();
      setState(() {
        newsList = newsData ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('Hubo un error cargando noticias: $e'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.newspaper_rounded,
                color: Colors.white,
              ),
              onPressed: () {
                // Handle home button pressed
              },
            ),
            const SizedBox(width: 8.0),
            Text(
              'Noticias',
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
      ),
      body: isLoading || newsList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: newsList.length,
              itemBuilder: (context, index) {
                var newsItem = newsList[index];

                List<String> imageUrls = [];
                if (newsItem.containsKey('images')) {
                  for (var image in newsItem['images']) {
                    if (image != null && image['url'] != null) {
                      imageUrls.add(image['url']);
                    }
                  }
                }

                return GestureDetector(
                  onTap: () {
                    _showCommentsDialog(newsItem);
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    margin: const EdgeInsets.all(10),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (imageUrls.isNotEmpty)
                          SizedBox(
                            height: 200, // Adjust image slider height as needed
                            child: PageView.builder(
                              itemCount: imageUrls.length,
                              itemBuilder: (context, imageIndex) {
                                return Image.network(
                                  imageUrls[imageIndex],
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                newsItem['description'] ?? '', // Handle null description
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.person, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        newsItem['police-name'] ?? '', // Handle null police name
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.comment, size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${newsItem['comments']?.length ?? 0}',
                                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(Icons.date_range, size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatDate(newsItem['date']), // Ensure date formatting function handles null
                                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0), // Rounded corners
            ),
            margin: const EdgeInsets.all(10),
            child:
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const NewsFormDialog();
                        },
                      );
                    },
                    child: const Text(
                      'Publicar noticia',
                      style: TextStyle(fontSize: 16.0, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isLoading = true;
                    });
                    _fetchNews(); // Call the method to reload news
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 24.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCommentsDialog(Map<String, dynamic> newsItem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Comentarios'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var comment in newsItem['comments'])
                ListTile(
                  leading: const Icon(Icons.person), // Icon next to commenter's name
                  title: Text(comment['text']),
                  subtitle: Text(
                    '${comment['user']['firstName']} ${comment['user']['lastName']}',
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(String dateString) {
    return DateFormat('dd-MM-yyyy').format(DateTime.parse(dateString));
  }
}

class NewsFormDialog extends StatefulWidget {
  const NewsFormDialog({Key? key}) : super(key: key);

  @override
  _NewsFormDialogState createState() => _NewsFormDialogState();
}

class _NewsFormDialogState extends State<NewsFormDialog> {
  final TextEditingController _descriptionController = TextEditingController();
  final List<File> _photoFiles = [];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Publicar noticia'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Descripción',
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              _checkPermissionAndPickImage();
            },
            child: const Text('Añadir foto'),
          ),
          const SizedBox(height: 10),
          Wrap(
            children: _photoFiles
                .map(
                  (file) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(file.path), // Display file path or name
                ),
              ),
            )
                .toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            _publishNews(); // Call method to publish news
          },
          child: const Text('Publicar'),
        ),
      ],
    );
  }

  void _publishNews() async {
    String description = _descriptionController.text;
    List<File> files = _photoFiles;
    NewService newsService = NewService();

    if (description.isNotEmpty && files.isNotEmpty) {
      try {
        dynamic response = await newsService.publishNews(description, files);

        print('News published successfully: $response');

        // Close the dialog after publishing
        Navigator.of(context).pop();
      } catch (e) {
        // Handle error case
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('Hubo un error al publicar la noticia: $e'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } else {
      // Handle case where description or files are empty
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Por favor, ingrese una descripción y al menos una foto para publicar.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _checkPermissionAndPickImage() async {
    if (await Permission.photos.request().isGranted) {
      _pickImage();
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Permissions Required'),
          content: const Text('Please grant permission to access photos.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _photoFiles.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }
}