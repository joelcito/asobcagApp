import 'package:flutter/material.dart';
import 'package:indrive_clone_flutter/src/data/EjemplarService.dart';
import 'package:indrive_clone_flutter/src/presentation/pages/llama/FormularioLlamaPage.dart';
import 'package:indrive_clone_flutter/src/presentation/pages/llama/LlamaDetailPage.dart';
import '../../../config/AppConfig.dart';

class LlamaPage extends StatefulWidget {
  const LlamaPage({super.key});

  @override
  State<LlamaPage> createState() => _LlamaPageState();
}

class _LlamaPageState extends State<LlamaPage> {
  final List<Map<String, dynamic>> _items = [];
  final EjemplarService _ejemplarService = EjemplarService();
  final String baseUrlImages = AppConfig.baseUrlImages;

  @override
  void initState() {
    super.initState();
    _loadEjemplares(); // Cargar los ejemplares al iniciar el widget
  }

  // Función para cargar los ejemplares desde el servicio
  Future<void> _loadEjemplares() async {
    try {
      final ejemplares = await _ejemplarService.ejemplaresUsuario();
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
      appBar: AppBar(title: Text("Listado de Llamas")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Cantidad de columnas
            crossAxisSpacing: 10.0, // Espaciado entre columnas
            mainAxisSpacing: 10.0, // Espaciado entre filas
            childAspectRatio: 1, // Relación de aspecto
          ),
          itemCount: _items.length,
          itemBuilder: (context, index) {
            final item = _items[index];

            // Usamos GestureDetector para detectar el clic y navegar a otra página
            return GestureDetector(
              onTap: () {
                // Aquí navegas a la página de detalles (puedes crearla si no existe)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LlamaDetailPage(item: item),
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
                    // Usamos Expanded para evitar desbordamientos y que las imágenes se ajusten
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: item["images"].length,
                        itemBuilder: (context, imageIndex) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 5.0,
                            ), // Espacio entre imágenes
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(15),
                              ),
                              child: Image.network(
                                item["images"][imageIndex],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 100, // Ajusta la altura de las imágenes
                                errorBuilder: (context, error, stackTrace) {
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
                        item["title"],
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
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'llama_fab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FormularioLlamaPage()),
          );
        },
        child: Icon(Icons.add, size: 32),
        backgroundColor: Colors.orange,
      ),
    );
  }

  // ****************** ESTE FUCNOION PERO NO MUESTRA TODAS LAS IMAGES **********************
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(title: Text("Listado de Llamas")),
  //     body: Padding(
  //       padding: const EdgeInsets.all(8.0),
  //       child: GridView.builder(
  //         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //           crossAxisCount: 2, // Cantidad de columnas
  //           crossAxisSpacing: 10.0,
  //           mainAxisSpacing: 10.0,
  //           childAspectRatio: 1,
  //         ),
  //         itemCount: _items.length,
  //         itemBuilder: (context, index) {
  //           final item = _items[index];
  //           return GestureDetector(
  //             onTap: () {
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
  //                   Flexible(
  //                     child: ClipRRect(
  //                       borderRadius: BorderRadius.vertical(
  //                         top: Radius.circular(15),
  //                       ),
  //                       child: Image.network(
  //                         item["images"][0], // Primera imagen de la lista
  //                         fit: BoxFit.cover,
  //                         width: double.infinity,
  //                         height: 100,
  //                         errorBuilder: (context, error, stackTrace) {
  //                           return Icon(
  //                             Icons.image_not_supported,
  //                             size: 50,
  //                             color: Colors.grey,
  //                           );
  //                         },
  //                       ),
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
  //       onPressed: () {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) => FormularioLlamaPage()),
  //         );
  //       },
  //       child: Icon(Icons.add, size: 32),
  //       backgroundColor: Colors.orange,
  //     ),
  //   );
  // }

  //  ************************ ESTE FUNCIONA PERO SIN CLICK *******************
  // @override
  // Widget build(BuildContext context) {
  //   print(_items);

  //   return Scaffold(
  //     appBar: AppBar(title: Text("Listado de Llamas")),
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
  //           return Card(
  //             elevation: 4,
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(15),
  //             ),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               children: [
  //                 Flexible(
  //                   child: GridView.builder(
  //                     shrinkWrap: true,
  //                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //                       crossAxisCount: 1, // Solo una columna para las imágenes
  //                       crossAxisSpacing: 5,
  //                       mainAxisSpacing: 5,
  //                     ),
  //                     itemCount: item["images"].length,
  //                     itemBuilder: (context, imageIndex) {
  //                       return ClipRRect(
  //                         borderRadius: BorderRadius.vertical(
  //                           top: Radius.circular(15),
  //                         ),
  //                         child: Image.network(
  //                           // imageUrl,
  //                           item["images"][imageIndex],
  //                           fit: BoxFit.cover,
  //                           width: double.infinity,
  //                           errorBuilder: (context, error, stackTrace) {
  //                             // Si la imagen no existe o no se puede cargar (404 o error en la red)
  //                             if (error is NetworkImageLoadException) {
  //                               // Aquí podemos manejar específicamente el error de carga de la imagen
  //                               return Icon(
  //                                 Icons
  //                                     .image_not_supported, // Ícono cuando no se puede cargar la imagen
  //                                 size: 50,
  //                                 color: Colors.grey,
  //                               );
  //                             }
  //                             // En caso de otro error, mostramos un ícono genérico
  //                             print(error);

  //                             return Icon(
  //                               Icons.error,
  //                               size: 50,
  //                               color: Colors.red,
  //                             );
  //                           },
  //                         ),
  //                       );
  //                     },
  //                   ),
  //                 ),
  //                 Padding(
  //                   padding: const EdgeInsets.all(8.0),
  //                   child: Text(
  //                     item["title"]!,
  //                     style: TextStyle(
  //                       fontSize: 16,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           );
  //         },
  //       ),
  //     ),
  //     // Agregar el botón flotante
  //     floatingActionButton: FloatingActionButton(
  //       onPressed: () {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) => FormularioLlamaPage()),
  //         );
  //       },
  //       child: Icon(Icons.add, size: 32),
  //       backgroundColor: Colors.orange,
  //     ),
  //   );
  // }
}
