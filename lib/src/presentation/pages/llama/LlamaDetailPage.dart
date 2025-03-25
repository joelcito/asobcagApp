import 'package:flutter/material.dart';

class LlamaDetailPage extends StatelessWidget {
  final Map<String, dynamic> item;

  const LlamaDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    double screenWidth =
        MediaQuery.of(context).size.width; // 📏 Obtiene el ancho de pantalla

    return Scaffold(
      appBar: AppBar(title: Text(item["title"] ?? "Detalle del Ejemplar")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📸 Sección de imágenes (NO SE TOCA)
            if (item["images"] != null && item["images"].isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: item["images"].length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          item["images"][index],
                          fit: BoxFit.cover,
                          width: 250,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 250,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 20),

            // 📋 Sección de información en DOS COLUMNAS
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.count(
                    crossAxisCount:
                        screenWidth > 600
                            ? 2
                            : 1, // 🔥 2 columnas en pantallas grandes, 1 en móviles
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio:
                        3.5, // 📏 Ajuste de altura para que no se vea tan aplastado
                    children: [
                      _buildInfoCard(
                        Icons.confirmation_number,
                        "Núm. Registro:",
                        item["numero_registro"],
                      ),
                      _buildInfoCard(
                        Icons.memory,
                        "Microchip:",
                        item["microchip"],
                      ),
                      _buildInfoCard(Icons.tag, "Núm. Arete:", item["arete"]),
                      _buildInfoCard(Icons.pets, "Tipo:", item["tipo"]),
                      _buildInfoCard(
                        Icons.cake,
                        "F. Nacimiento:",
                        item["fecha_nacimiento"],
                      ),
                      _buildInfoCard(
                        Icons.color_lens,
                        "Color:",
                        item["nombreColor"],
                      ),
                      _buildInfoCard(
                        Icons.account_tree,
                        "Fenotipo:",
                        item["nombreFenotipo"],
                      ),
                      _buildInfoCard(Icons.male, "Padre:", item["nombrePadre"]),
                      _buildInfoCard(
                        Icons.female,
                        "Madre:",
                        item["nombreMadre"],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🏷️ Método para construir tarjetas de información
  Widget _buildInfoCard(IconData icon, String label, dynamic value) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.blueAccent, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    value?.toString() ?? "No disponible",
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
