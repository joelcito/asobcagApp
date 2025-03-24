import 'dart:io';

import 'package:flutter/material.dart';
import 'package:indrive_clone_flutter/src/data/EjemplarService.dart';
import 'package:indrive_clone_flutter/src/domain/ColorService.dart';
import 'package:indrive_clone_flutter/src/domain/FenotipoService.dart';
import 'package:image_picker/image_picker.dart';

class FormularioLlamaPage extends StatefulWidget {
  @override
  _FormularioLlamaPageState createState() => _FormularioLlamaPageState();
}

class _FormularioLlamaPageState extends State<FormularioLlamaPage> {
  String _nombre = '';
  String _tipo_parto = '';
  int? _colorSeleccionado;
  int? _fenotipoSeleccionado;
  String? _sexoSeleccionado;
  DateTime? _fechaSeleccionada;
  int? _numeroRegistro;
  String? _microChip;
  String? _arete;

  List<Map<String, dynamic>> _colores = [];
  List<Map<String, dynamic>> _fenotipos = [];
  List<String> _sexos = ["Macho", "Hembra"];
  List<File> _imagenesSeleccionadas = [];
  TextEditingController _fechaController = TextEditingController();
  DateTime? _fecha;

  final _formKey = GlobalKey<FormState>();
  final EjemplarService ejemplarService = EjemplarService();
  final Colorservice colorSerice = Colorservice();
  final Fenotiposervice fenotiposervice = Fenotiposervice();
  final ImagePicker _picker = ImagePicker();

  void _guardarEjemplar() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Construcción del JSON con los datos del ejemplar
      Map<String, dynamic> ejemplar = {
        "nombre": _nombre,
        "color_id": _colorSeleccionado,
        "fenotipo_id": _fenotipoSeleccionado,
        "tipo": "LLAMA",
        "tipo_parto": _tipo_parto,
        "sexo": _sexoSeleccionado,
        "fecha_nacimiento": _fechaSeleccionada?.toIso8601String(),
        "microchip": _microChip,
        "arete": _arete,
      };

      // Llamar al servicio para registrar el ejemplar con imágenes
      bool success = await ejemplarService.registroEjemplar(
        ejemplar,
        _imagenesSeleccionadas,
      );

      if (success) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("¡Ocurrió un error al registrar el ejemplar!"),
          ),
        );
      }
    }
  }

  Future<void> cargarColores() async {
    List<Map<String, dynamic>> colores = await colorSerice.listaColores();
    setState(() {
      _colores = colores;
    });
  }

  Future<void> cargarFenotipos() async {
    List<Map<String, dynamic>> fenotipos =
        await fenotiposervice.listaFenotipos();
    setState(() {
      _fenotipos = fenotipos;
    });
  }

  Future<void> _tomarFoto() async {
    // Muestra un cuadro de diálogo para que el usuario elija entre cámara o galería
    final pickedOption = await showDialog<ImageSource>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Selecciona una opción'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, ImageSource.camera); // Cámara
              },
              child: Text('Tomar Foto'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, ImageSource.gallery); // Galería
              },
              child: Text('Seleccionar Imagen'),
            ),
          ],
        );
      },
    );

    if (pickedOption != null) {
      final XFile? image = await _picker.pickImage(source: pickedOption);
      if (image != null) {
        setState(() {
          // Añade la nueva imagen (o foto) a la lista
          _imagenesSeleccionadas.add(File(image.path));
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Llama al método de sincronización automática cuando se inicie la pantalla
    ejemplarService.enviarEjemplaresPendientes();
    cargarColores();
    cargarFenotipos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Registrar de Llama")),
      body: SingleChildScrollView(
        // <-- Agregado para permitir scroll
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // <-- Alinea a la izquierda
              children: [
                // TextFormField(
                //   decoration: InputDecoration(labelText: "Numero de Registro"),
                //   validator:
                //       (value) =>
                //           value!.isEmpty
                //               ? "Ingrese un número de Registro"
                //               : null,
                //   onSaved: (value) => _numeroRegistro = value!,
                // ),
                TextFormField(
                  decoration: InputDecoration(labelText: "Microchip"),
                  validator:
                      (value) => value!.isEmpty ? "Ingrese un microchip" : null,
                  onSaved: (value) => _microChip = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "Nombre"),
                  validator:
                      (value) => value!.isEmpty ? "Ingrese un nombre" : null,
                  onSaved: (value) => _nombre = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "Arete"),
                  validator:
                      (value) => value!.isEmpty ? "Ingrese un arete" : null,
                  onSaved: (value) => _arete = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "Tipo Parto"),
                  validator:
                      (value) =>
                          value!.isEmpty ? "Ingrese el tipo de parto" : null,
                  onSaved: (value) => _tipo_parto = value!,
                ),
                SizedBox(height: 20),

                // Dropdown de color
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(labelText: "Selecciona un color"),
                  value: _colorSeleccionado,
                  items:
                      _colores.map<DropdownMenuItem<int>>((color) {
                        return DropdownMenuItem<int>(
                          value: color['color_id'],
                          child: Text(color['nombre']),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _colorSeleccionado = value;
                    });
                  },
                  validator:
                      (value) => value == null ? "Seleccione un color" : null,
                ),
                SizedBox(height: 20),

                // Dropdown de sexos
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: "Selecciona el sexo"),
                  value: _sexoSeleccionado,
                  items:
                      _sexos.map<DropdownMenuItem<String>>((sexo) {
                        return DropdownMenuItem<String>(
                          value: sexo,
                          child: Text(sexo),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _sexoSeleccionado = value;
                    });
                  },
                  validator:
                      (value) => value == null ? "Seleccione un sexo" : null,
                ),

                SizedBox(height: 20),
                // Dropdown de Fenotipo
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: "Selecciona un Fenotipo",
                  ),
                  value: _fenotipoSeleccionado,
                  items:
                      _fenotipos.map<DropdownMenuItem<int>>((fenotipo) {
                        return DropdownMenuItem<int>(
                          value: fenotipo['fenotipo_id'],
                          child: Text(fenotipo['nombre']),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _fenotipoSeleccionado = value;
                    });
                  },
                  validator:
                      (value) =>
                          value == null ? "Seleccione un fenotipo" : null,
                ),
                SizedBox(height: 20),

                // ESTO ES PARA LA FECHA
                TextFormField(
                  decoration: InputDecoration(labelText: "Fecha de nacimiento"),
                  readOnly: true, // Deshabilita la edición directa del campo
                  controller: _fechaController, // Controlador para la fecha
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate:
                          _fechaSeleccionada ??
                          DateTime.now(), // Fecha por defecto
                      firstDate: DateTime(1900), // Fecha mínima permitida
                      lastDate: DateTime.now(), // Fecha máxima permitida (hoy)
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _fechaSeleccionada =
                            pickedDate; // Guarda la fecha seleccionada
                        _fechaController.text =
                            "${_fechaSeleccionada!.toLocal()}".split(
                              ' ',
                            )[0]; // Muestra la fecha en el formato adecuado
                      });
                    }
                  },
                  validator:
                      (value) => value!.isEmpty ? "Seleccione una fecha" : null,
                  onSaved: (value) => _fecha = _fechaSeleccionada!,
                ),
                SizedBox(height: 20),

                // Botón para tomar foto
                IconButton(
                  icon: Icon(Icons.camera_alt),
                  onPressed: _tomarFoto,
                  tooltip: "Tomar foto",
                ),
                SizedBox(height: 20),

                // Mostrar imágenes seleccionadas
                _imagenesSeleccionadas.isNotEmpty
                    ? GridView.builder(
                      shrinkWrap:
                          true, // <-- Importante para evitar error de tamaño infinito
                      physics:
                          NeverScrollableScrollPhysics(), // <-- Desactiva el scroll interno
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: _imagenesSeleccionadas.length,
                      itemBuilder: (context, index) {
                        return Image.file(
                          _imagenesSeleccionadas[index],
                          fit: BoxFit.cover,
                        );
                      },
                    )
                    : Text("No hay fotos tomadas"),
                SizedBox(height: 20),

                // Botón de Guardar
                ElevatedButton(
                  onPressed: _guardarEjemplar,
                  child: Text("Guardar"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
