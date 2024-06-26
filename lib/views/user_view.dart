import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../config/auth_provider.dart';
import '../api/police_service.dart';

class User extends StatefulWidget {
  const User({super.key});

  @override
  State<User> createState() => _UserState();

  static fromJson(json) {}
}

class _UserState extends State<User> {
  String username = 'Cargando...';
  String firstName = 'Cargando...';
  String lastName = 'Cargando...';
  String dni = 'Cargando...';
  String email = 'Cargando...';
  String phoneNumber = 'Cargando...';
  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadCitizenData();
  }

  Future<void> _loadCitizenData() async {
    try {
      final userId = Provider.of<AuthProvider>(context, listen: false).getUserId;
      final citizenService = PoliceService();
      final response = await citizenService.getPoliceByUserId(userId);
      final policeData = response;

      if (policeData != null && policeData.containsKey('user')) {
        final userData = policeData['user'];

        if (mounted) {
          setState(() {
            username = userData['username'] ?? 'Sin Nombre de usuario';
            firstName = userData['firstName'] ?? 'Sin Nombre';
            lastName = userData['lastName'] ?? 'Sin Apellido';
            dni = userData['dni'] ?? 'Sin ID';
            email = userData['email'] ?? 'Sin Email';
            phoneNumber = userData['phoneNumber'] ?? 'Sin Teléfono';
          });
        }
      } else {
        print('Error: Datos de usuario no encontrados en la respuesta');
      }
    } on FormatException catch (e) {
      print('Format exception: $e');
    } catch (e) {
      print('Error loading citizen data: $e');
    }
  }


  Future<void> _updatePoliceData(int userId, String username, String dni, String email, String phoneNumber) async {
    try {
      final policeService = PoliceService();
      final updateData = {
        'username': username,
        'dni': dni,
        'email': email,
        'phoneNumber': phoneNumber,
      };

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      await policeService.updatePolice(userId, updateData);

      if (!mounted) return;

      setState(() {
        username = username;
        dni = dni;
        email = email;
        phoneNumber = phoneNumber;
      });
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    } catch (e) {
      print('Error updating citizen data: $e');
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating data: $e')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      // Aquí se puede agregar código para subir la imagen al servidor si es necesario :b
    }
  }

  void _viewImage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                child: SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: PhotoView(
                    imageProvider: _image != null
                        ? FileImage(_image!)
                        : const AssetImage('assets/default_profile.jpg') as ImageProvider,
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _image = null;
                    });
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(12),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
              ),
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
        title: const Text('Mi perfil'),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.red,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 25),
              Stack(
                children: [
                  GestureDetector(
                    onTap: _viewImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _image != null
                          ? FileImage(_image!)
                          : const AssetImage('assets/default_profile.jpg') as ImageProvider,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickImage,
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImage,
                child: Text(
                  username,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Sobre mi',
                    style: TextStyle(fontSize: 16),
                  ),
                  TextButton(
                    onPressed: () {
                      _showEditDialog(context);
                    },
                    child: const Text(
                      'Editar',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
              const Divider(),
              Column(
                children: [
                  InfoTile(
                    icon: Icons.credit_card,
                    title: dni,
                  ),
                  InfoTile(
                    icon: Icons.perm_identity,
                    title: '$firstName $lastName',
                  ),
                  InfoTile(
                    icon: Icons.email,
                    title: email,
                  ),
                  InfoTile(
                    icon: Icons.phone,
                    title: phoneNumber,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 50),
              ElevatedButton.icon(
                onPressed: () {
                  Provider.of<AuthProvider>(context, listen: false).logout();
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  'Cerrar Sesión',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController(text: username);
    TextEditingController idController = TextEditingController(text: dni);
    TextEditingController firstNameController = TextEditingController(text: firstName);
    TextEditingController lastNameController = TextEditingController(text: lastName);
    TextEditingController emailController = TextEditingController(text: email);
    TextEditingController phoneController = TextEditingController(text: phoneNumber);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Información'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de usuario',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: idController,
                  decoration: const InputDecoration(
                    labelText: 'Dni',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Apellido',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo Electrónico',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              onPressed: () {
                final userId = Provider.of<AuthProvider>(context, listen: false).getUserId;
                _updatePoliceData(userId, nameController.text, idController.text, emailController.text, phoneController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                foregroundColor: Colors.white,
              ),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}

class InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;

  const InfoTile({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.red,
          ),
          const SizedBox(width: 16),
          Text(title),
        ],
      ),
    );
  }
}