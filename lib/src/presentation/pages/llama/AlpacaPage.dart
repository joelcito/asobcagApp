import 'package:flutter/material.dart';
import 'package:indrive_clone_flutter/src/data/EjemplarService.dart';
import 'package:indrive_clone_flutter/src/presentation/pages/llama/FormularioAlpacaPage.dart';
import 'package:indrive_clone_flutter/src/presentation/pages/llama/LlamaDetailPage.dart';
import '../../../config/AppConfig.dart';

class AlpacaPage extends StatefulWidget {
  const AlpacaPage({super.key});

  @override
  State<AlpacaPage> createState() => _AlpacaPageState();
}

class _AlpacaPageState extends State<AlpacaPage> {
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
      final ejemplares = await _ejemplarService.ejemplaresAlpacasUsuario();
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
      appBar: AppBar(title: Text("Listado de Alpacas")),
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
        heroTag: 'alpaca_fab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FormularioAlpacaPage()),
          );
        },
        child: Icon(Icons.add, size: 32),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
