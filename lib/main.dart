import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const FurnitureHomePage(),
    );
  }
}

class FurnitureHomePage extends StatelessWidget {
  const FurnitureHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplikasi Pendataan Penjualan Furniture'),
      ),
      body: const FurnitureList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const FurnitureDialog(),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class FurnitureList extends StatelessWidget {
  const FurnitureList({super.key});

  @override
  Widget build(BuildContext context) {
    final CollectionReference furnitureRef = FirebaseFirestore.instance.collection('furniture');

    return StreamBuilder<QuerySnapshot>(
      stream: furnitureRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading data'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var furnitureList = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: furnitureList.length,
          itemBuilder: (context, index) {
            var furniture = furnitureList[index];
            return Card(
              color: Colors.blue.shade50,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text(furniture['nama_barang'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: Text(
                  'ID: ${furniture.id}\nJenis: ${furniture['jenis_barang']}\nJumlah: ${furniture['jumlah_barang']}\nHarga: ${furniture['harga']}',
                  style: const TextStyle(fontSize: 14),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.green),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => FurnitureDialog(furnitureId: furniture.id, furnitureData: furniture),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Konfirmasi Penghapusan'),
                            content: const Text('Apakah anda yakin ingin menghapus data ini?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Tidak'),
                              ),
                              TextButton(
                                onPressed: () {
                                  furnitureRef.doc(furniture.id).delete();
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Hapus'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class FurnitureDialog extends StatefulWidget {
  final String? furnitureId;
  final DocumentSnapshot? furnitureData;

  const FurnitureDialog({super.key, this.furnitureId, this.furnitureData});

  @override
  _FurnitureDialogState createState() => _FurnitureDialogState();
}

class _FurnitureDialogState extends State<FurnitureDialog> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController jenisController = TextEditingController();
  final TextEditingController jumlahController = TextEditingController();
  final TextEditingController hargaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.furnitureData != null) {
      idController.text = widget.furnitureId ?? 'id_furniture';
      namaController.text = widget.furnitureData!['nama_barang'];
      jenisController.text = widget.furnitureData!['jenis_barang'];
      jumlahController.text = widget.furnitureData!['jumlah_barang'].toString();
      hargaController.text = widget.furnitureData!['harga'].toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.furnitureId == null ? 'Tambah Furniture' : 'Edit Furniture'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: idController,
              decoration: const InputDecoration(labelText: 'ID Furniture'),
            ),
            TextField(
              controller: namaController,
              decoration: const InputDecoration(labelText: 'Nama Furniture'),
            ),
            TextField(
              controller: jenisController,
              decoration: const InputDecoration(labelText: 'Jenis Furniture'),
            ),
            TextField(
              controller: jumlahController,
              decoration: const InputDecoration(labelText: 'Jumlah Furniture'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: hargaController,
              decoration: const InputDecoration(labelText: 'Harga'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            final CollectionReference furnitureRef = FirebaseFirestore.instance.collection('furniture');
            try {
              if (widget.furnitureId == null) {
                // Add new furniture with specific ID
                await furnitureRef.doc(idController.text).set({
                  'id_furniture': idController.text,
                  'nama_barang': namaController.text,
                  'jenis_barang': jenisController.text,
                  'jumlah_barang': int.parse(jumlahController.text),
                  'harga': double.parse(hargaController.text),
                });
              } else {
                // Update existing furniture
                await furnitureRef.doc(widget.furnitureId).update({
                  'id_furniture': idController.text,
                  'nama_barang': namaController.text,
                  'jenis_barang': jenisController.text,
                  'jumlah_barang': int.parse(jumlahController.text),
                  'harga': double.parse(hargaController.text),
                });
              }
              Navigator.of(context).pop();
            } catch (e) {
              print('Error: $e');
            }
          },
          child: const Text('Save'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
