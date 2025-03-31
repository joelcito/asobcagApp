import 'package:flutter/material.dart';
import 'package:indrive_clone_flutter/src/data/EjemplarService.dart';
import 'package:indrive_clone_flutter/src/presentation/pages/llama/FormularioLlamaPage.dart';
import 'package:indrive_clone_flutter/src/presentation/pages/llama/LlamaDetailPage.dart';
import '../../../config/AppConfig.dart';
import 'dart:io';

class LlamaOffLinePage extends StatefulWidget {
  const LlamaOffLinePage({super.key});

  @override
  State<LlamaOffLinePage> createState() => _LlamaOffLinePageState();
}

class _LlamaOffLinePageState extends State<LlamaOffLinePage> {
  final List<Map<String, dynamic>> _items = [];
  final EjemplarService _ejemplarService = EjemplarService();
  final String baseUrlImages = AppConfig.baseUrlImages;
  late Future<List<Map<String, dynamic>>> _ejemplares;

  @override
  void initState() {
    super.initState();
    // _loadEjemplares(); // Cargar los ejemplares al iniciar el widget
    _ejemplares = EjemplarService().ejemplaresLocales();
  }

  // Función para cargar los ejemplares desde el servicio
  Future<void> _loadEjemplares() async {
    try {
      final ejemplares = await _ejemplarService.ejemplaresLocales();

      print("*********************************************");
      print(ejemplares.length);
      print("*********************************************");

      setState(() {
        _items.clear(); // Limpiar la lista actual
        _items.addAll(ejemplares); // Agregar los nuevos ejemplares a la lista
      });
    } catch (e) {
      // En caso de error, podrías mostrar un mensaje de error o manejarlo de otra manera
      print("Error al cargar los ejemplares: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar los ejemplares: $e")),
      );
    }
  }

  String getImageUrl(String imagePath) {
    return "${baseUrlImages}$imagePath"; // Concatenamos baseUrlImages con la ruta relativa
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Llamas Pendientes'),
        centerTitle: true,
        backgroundColor: Color(0xFF7A6E2A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _ejemplares,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No hay ejemplares pendientes.'));
            } else {
              final ejemplares = snapshot.data!;

              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Número de columnas
                  crossAxisSpacing: 10.0, // Espacio entre columnas
                  mainAxisSpacing: 10.0, // Espacio entre filas
                  childAspectRatio: 1, // Relación de aspecto
                ),
                itemCount: ejemplares.length,
                itemBuilder: (context, index) {
                  final ejemplar = ejemplares[index];
                  final images = ejemplar['images'] as List<String>;

                  // Usamos GestureDetector para permitir navegar a otro detalle
                  return GestureDetector(
                    onTap: () {
                      // Aquí puedes navegar a una página de detalle si es necesario
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LlamaDetailPage(item: ejemplar),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: images.length,
                              itemBuilder: (context, imageIndex) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 5.0,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(15),
                                    ),
                                    child: Image.file(
                                      File(images[imageIndex]),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height:
                                          100, // Ajusta la altura de las imágenes
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Icon(
                                          Icons.image_not_supported,
                                          size: 50,
                                          color: Colors.grey,
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              ejemplar['nombre'] ?? 'Sin nombre',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'ejemplar_offline_fab',
        onPressed: () {
          // Aquí puedes agregar la acción de abrir otro formulario, si es necesario
          // Navigator.push(context, MaterialPageRoute(builder: (context) => FormularioPage()));
        },
        child: Icon(Icons.add, size: 32, color: Colors.white),
        backgroundColor: Color(0xFF7A6E2A),
      ),
    );
  }

  // *********************************** ESTE DA PERO NO ME GUSTA
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(title: Text('Ejemplares Pendientes')),
  //     body: FutureBuilder<List<Map<String, dynamic>>>(
  //       future: _ejemplares,
  //       builder: (context, snapshot) {
  //         if (snapshot.connectionState == ConnectionState.waiting) {
  //           return Center(child: CircularProgressIndicator());
  //         } else if (snapshot.hasError) {
  //           return Center(child: Text('Error: ${snapshot.error}'));
  //         } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
  //           return Center(child: Text('No hay ejemplares pendientes.'));
  //         } else {
  //           // Datos listos para mostrar
  //           final ejemplares = snapshot.data!;

  //           return ListView.builder(
  //             itemCount: ejemplares.length,
  //             itemBuilder: (context, index) {
  //               final ejemplar = ejemplares[index];
  //               final images = ejemplar['images'] as List<String>;

  //               return ListTile(
  //                 title: Text(ejemplar['nombre'] ?? 'Sin nombre'),
  //                 subtitle: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text('ID: ${ejemplar['id']}'),
  //                     if (images.isNotEmpty)
  //                       ...images.map((imagePath) {
  //                         final file = File(imagePath);
  //                         if (file.existsSync()) {
  //                           return Image.file(file);
  //                         } else {
  //                           return Image.asset(
  //                             'assets/placeholder.jpg',
  //                           ); // Imagen de reemplazo si no se encuentra
  //                         }
  //                       }).toList(),
  //                   ],
  //                 ),
  //               );
  //             },
  //           );
  //         }
  //       },
  //     ),
  //   );
  // }

  // ********************************** ANTIGUO
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text(
  //         "Listado de Llamas Off Line",
  //         style: TextStyle(color: Colors.white),
  //       ),
  //       centerTitle: true,
  //       backgroundColor: Color(0xFF7A6E2A),
  //     ),
  //     body: Padding(
  //       padding: const EdgeInsets.all(8.0),
  //       child: GridView.builder(
  //         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //           crossAxisCount: 2, // Cantidad de columnas
  //           crossAxisSpacing: 10.0, // Espaciado entre columnas
  //           mainAxisSpacing: 10.0, // Espaciado entre filas
  //           childAspectRatio: 1, // Relación de aspecto
  //         ),
  //         itemCount: _items.length,
  //         itemBuilder: (context, index) {
  //           final item = _items[index];

  //           // Usamos GestureDetector para detectar el clic y navegar a otra página
  //           return GestureDetector(
  //             onTap: () {
  //               // Aquí navegas a la página de detalles (puedes crearla si no existe)
  //               Navigator.push(
  //                 context,
  //                 MaterialPageRoute(
  //                   builder: (context) => LlamaDetailPage(item: item),
  //                 ),
  //               );
  //             },
  //             child: Card(
  //               elevation: 4,
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(15),
  //               ),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.center,
  //                 children: [
  //                   // Usamos Expanded para evitar desbordamientos y que las imágenes se ajusten
  //                   Expanded(
  //                     child: ListView.builder(
  //                       shrinkWrap: true,
  //                       itemCount: item["images"].length,
  //                       itemBuilder: (context, imageIndex) {
  //                         return Padding(
  //                           padding: const EdgeInsets.symmetric(
  //                             vertical: 5.0,
  //                           ), // Espacio entre imágenes
  //                           child: ClipRRect(
  //                             borderRadius: BorderRadius.vertical(
  //                               top: Radius.circular(15),
  //                             ),
  //                             child: Image.network(
  //                               item["images"][imageIndex],
  //                               fit: BoxFit.cover,
  //                               width: double.infinity,
  //                               height: 100, // Ajusta la altura de las imágenes
  //                               errorBuilder: (context, error, stackTrace) {
  //                                 return Icon(
  //                                   Icons.image_not_supported,
  //                                   size: 50,
  //                                   color: Colors.grey,
  //                                 );
  //                               },
  //                             ),
  //                           ),
  //                         );
  //                       },
  //                     ),
  //                   ),
  //                   Padding(
  //                     padding: const EdgeInsets.all(8.0),
  //                     child: Text(
  //                       item["title"],
  //                       style: TextStyle(
  //                         fontSize: 16,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           );
  //         },
  //       ),
  //     ),
  //     floatingActionButton: FloatingActionButton(
  //       heroTag: 'llama_off_fab',
  //       onPressed: () {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) => FormularioLlamaPage()),
  //         );
  //       },
  //       child: Icon(Icons.add, size: 32, color: Colors.white),
  //       backgroundColor: Color(0xFF7A6E2A),
  //     ),
  //   );
  // }
}
