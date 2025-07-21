import 'dart:io';
import 'package:FENCAMEL/src/data/EjemplarService.dart';
import 'package:FENCAMEL/src/domain/ColorService.dart';
import 'package:FENCAMEL/src/domain/FenotipoService.dart';
import 'package:FENCAMEL/src/presentation/pages/llama/FormularioEsquilaLlama.dart';
import 'package:FENCAMEL/src/presentation/pages/llama/FormularioFibraLlama.dart';
import 'package:FENCAMEL/src/presentation/pages/llama/FormularioMedicacionLlama.dart';
import 'package:FENCAMEL/src/presentation/pages/llama/FormularioMorfologicoLlama.dart';
import 'package:FENCAMEL/src/presentation/pages/llama/FormularioPequenoLlama.dart';
import 'package:flutter/material.dart';
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
  DateTime? _fecha;
  String? _microChip;
  String? _arete;
  bool _isLoading = false;

  List<Map<String, dynamic>> _colores = [];
  List<Map<String, dynamic>> _fenotipos = [];
  List<String> _sexos = ["Macho", "Hembra"];
  List<File> _imagenesSeleccionadas = [];
  TextEditingController _fechaController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final EjemplarService ejemplarService = EjemplarService();
  final Colorservice colorSerice = Colorservice();
  final Fenotiposervice fenotiposervice = Fenotiposervice();
  final ImagePicker _picker = ImagePicker();

  final List<Map<String, dynamic>> datosFormulariosPequenosBiometrico = [];
  final List<Map<String, dynamic>> datosFormulariosMorfologico = [];
  final List<Map<String, dynamic>> datosFormulariosFibras = [];
  final List<Map<String, dynamic>> datosFormulariosEsquila = [];

  void _guardarEjemplar() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Muestra el cargador y deshabilita el botón
      });
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

      setState(() {
        _isLoading = false; // Muestra el cargador y deshabilita el botón
      });

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

  void _abrirFormularioPequeno() {
    showDialog(
      context: context,
      builder:
          (context) => FormularioPequenoLlama(
            onGuardar: (datos) {
              setState(() {
                print(datos);

                datosFormulariosPequenosBiometrico.add(datos);
              });
            },
          ),
    );
  }

  // ESTO ES PARA EL FORMULARIO MORFOLOGICO
  final List<String> listaEvaluadores = [
    'Evaluador 1',
    'Evaluador 2',
    'Evaluador 3',
  ];

  void _abrirFormularioMorfologico() {
    showDialog(
      context: context,
      builder:
          (context) => FormularioMorfologicoLlama(
            evaluadores: listaEvaluadores,
            onGuardar: (datos) {
              setState(() {
                print(datos);
                datosFormulariosMorfologico.add(datos);
              });
              // Navigator.of(
              //   context,
              // ).pop(); // Cierra el diálogo después de guardar
            },
          ),
    );
  }

  // ESTO ES PARA EL FORMUALRIO DE FIBRAS
  final List<String> listaLaboratorios = ['Lab A', 'Lab B', 'Lab C'];
  final List<String> listaEquipos = ['Equipo 1', 'Equipo 2', 'Equipo 3'];
  void _abrirFormularioFibra() {
    showDialog(
      context: context,
      builder:
          (context) => FormularioFibraLlama(
            laboratorios: listaLaboratorios,
            equipos: listaEquipos,
            onGuardar: (datos) {
              setState(() {
                // Maneja los datos recibidos aquí
                print('Datos guardados: $datos');
                datosFormulariosFibras.add(datos);
              });
              // Navigator.pop(context);
            },
          ),
    );
  }

  // ESTO ES PARA FORM UALRIO DE ESQUILAS
  final List<String> listaEsquiladores = ['Juan', 'Pedro', 'Luis'];

  void _abrirFormularioEsquila() {
    showDialog(
      context: context,
      builder:
          (context) => FormularioEsquilaLlama(
            esquiladores: listaEsquiladores,
            onGuardar: (datos) {
              setState(() {
                // Aquí puedes usar los datos recibidos del formulario
                print('Datos esquila: $datos');
                datosFormulariosEsquila.add(datos);
              });
              // Navigator.pop(context);
            },
          ),
    );
  }

  // ESTO ES PARA EL FORMULARIO DE MEDICACIONES
  final productos = [
    ProductoVeterinario(id: '1', nombre: 'Producto A'),
    ProductoVeterinario(id: '2', nombre: 'Producto B'),
  ];

  final responsables = [
    Responsable(id: '1', nombreCompleto: 'Juan Pérez'),
    Responsable(id: '2', nombreCompleto: 'Ana Gómez'),
  ];

  void _abrirFormularioMedicacion() {
    showDialog(
      context: context,
      builder:
          (context) => FormularioMedicacionLlama(
            productos: productos,
            responsables: responsables,
            onGuardar: (datos) {
              print('Datos medicación: $datos');
              // Aquí procesas o guardas los datos
              Navigator.pop(context);
            },
          ),
    );
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
      appBar: AppBar(
        title: Text(
          "Form. Registro de Llama",
          style: TextStyle(
            color: Color(0xFF7A6E2A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Microchip",
                    labelStyle: TextStyle(color: Color(0xFF7A6E2A)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF7A6E2A)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF7A6E2A),
                        width: 2,
                      ),
                    ),
                  ),
                  validator:
                      (value) => value!.isEmpty ? "Ingrese un microchip" : null,
                  onSaved: (value) => _microChip = value!,
                  cursorColor: Color(0xFF7A6E2A),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Nombre",
                    labelStyle: TextStyle(color: Color(0xFF7A6E2A)),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF7A6E2A),
                        width: 2,
                      ),
                    ),
                  ),
                  validator:
                      (value) => value!.isEmpty ? "Ingrese un nombre" : null,
                  onSaved: (value) => _nombre = value!,
                  cursorColor: Color(0xFF7A6E2A),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Arete",
                    labelStyle: TextStyle(color: Color(0xFF7A6E2A)),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF7A6E2A),
                        width: 2,
                      ),
                    ),
                  ),
                  validator:
                      (value) => value!.isEmpty ? "Ingrese un arete" : null,
                  onSaved: (value) => _arete = value!,
                  cursorColor: Color(0xFF7A6E2A),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Tipo Parto",
                    labelStyle: TextStyle(color: Color(0xFF7A6E2A)),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF7A6E2A),
                        width: 2,
                      ),
                    ),
                  ),
                  validator:
                      (value) =>
                          value!.isEmpty ? "Ingrese el tipo de parto" : null,
                  onSaved: (value) => _tipo_parto = value!,
                  cursorColor: Color(0xFF7A6E2A),
                ),
                SizedBox(height: 20),

                // Dropdown de color
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: "Selecciona un color",
                    labelStyle: TextStyle(color: Color(0xFF7A6E2A)),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF7A6E2A),
                        width: 2,
                      ),
                    ),
                  ),
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
                  decoration: InputDecoration(
                    labelText: "Selecciona el sexo",
                    labelStyle: TextStyle(color: Color(0xFF7A6E2A)),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF7A6E2A),
                        width: 2,
                      ),
                    ),
                  ),
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
                    labelStyle: TextStyle(color: Color(0xFF7A6E2A)),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF7A6E2A),
                        width: 2,
                      ),
                    ),
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
                  decoration: InputDecoration(
                    labelText: "Fecha de nacimiento",
                    labelStyle: TextStyle(color: Color(0xFF7A6E2A)),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF7A6E2A),
                        width: 2,
                      ),
                    ),
                  ),
                  readOnly: true, // Deshabilita la edición directa del campo
                  controller: _fechaController, // Controlador para la fecha
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      locale: const Locale("es", "ES"),
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
                Center(
                  child: IconButton(
                    icon: Icon(Icons.camera_alt),
                    onPressed: _tomarFoto,
                    tooltip: "Tomar foto",
                  ),
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
                    : Text("No hay fotos tomadas", textAlign: TextAlign.center),
                SizedBox(height: 20),

                // Botón de Guardar
                ElevatedButton(
                  onPressed: _isLoading ? null : _guardarEjemplar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isLoading
                            ? Color(0xFF7A6E2A)
                            : Color.fromARGB(
                              255,
                              89,
                              83,
                              39,
                            ), // Color de fondo (puedes cambiarlo al que prefieras)
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child:
                      _isLoading
                          ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: Colors.white),
                              SizedBox(width: 10),
                              Text("Cargando"),
                            ],
                          )
                          : Text(
                            "Guardar",
                            style: TextStyle(color: Colors.white),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 16, right: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              heroTag: 'btn1',
              onPressed: _abrirFormularioPequeno,
              child: Icon(Icons.add, size: 32),
              backgroundColor: Colors.green,
              tooltip: "Botón 1",
            ),
            SizedBox(height: 12),
            FloatingActionButton(
              heroTag: 'btn2',
              onPressed: _abrirFormularioMorfologico,
              child: Icon(Icons.pets, size: 32),
              backgroundColor: Colors.orange,
              tooltip: "Botón 2",
            ),
            SizedBox(height: 12),
            FloatingActionButton(
              heroTag: 'btn3',
              onPressed: _abrirFormularioFibra,
              child: Icon(Icons.directions_run, size: 32),
              backgroundColor: Colors.blue,
              tooltip: "Botón 3",
            ),
            SizedBox(height: 12),
            FloatingActionButton(
              heroTag: 'btn4',
              onPressed: _abrirFormularioEsquila,
              child: Icon(Icons.star, size: 32),
              backgroundColor: Colors.purple,
              tooltip: "Botón 4",
            ),
            SizedBox(height: 12),
            FloatingActionButton(
              heroTag: 'btn5',
              onPressed: _abrirFormularioMedicacion,
              child: Icon(Icons.camera_alt, size: 32),
              backgroundColor: Colors.red,
              tooltip: "Botón 5",
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
