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

class FormularioAlpacaPage extends StatefulWidget {
  @override
  _FormularioAlpacaPageState createState() => _FormularioAlpacaPageState();
}

class _FormularioAlpacaPageState extends State<FormularioAlpacaPage> {
  String _nombre = '';
  String? _tipo_parto;
  int? _colorSeleccionado;
  int? _fenotipoSeleccionado;
  String? _sexoSeleccionado;
  DateTime? _fechaSeleccionada;
  String? _microChip;
  String? _arete;
  bool _isLoading = false;

  List<Map<String, dynamic>> _colores = [];
  List<Map<String, dynamic>> _fenotipos = [];
  List<String> _sexos = ["Macho", "Hembra"];
  List<String> _tipo_partos = ["NORMAL", "ASISTIDO"];
  List<File> _imagenesSeleccionadas = [];
  TextEditingController _fechaController = TextEditingController();
  DateTime? _fecha;

  final _formKey = GlobalKey<FormState>();
  final EjemplarService ejemplarService = EjemplarService();
  final Colorservice colorSerice = Colorservice();
  final Fenotiposervice fenotiposervice = Fenotiposervice();
  final ImagePicker _picker = ImagePicker();

  final Map<String, dynamic> datosFormulariosPequenosBiometrico = {};
  final Map<String, dynamic> datosFormulariosMorfologico = {};
  final Map<String, dynamic> datosFormulariosFibras = {};
  final Map<String, dynamic> datosFormulariosEsquila = {};
  final Map<String, dynamic> datosFormulariosMedicacion = {};

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
        "tipo": "ALPACA",
        "tipo_parto": _tipo_parto,
        "sexo": _sexoSeleccionado,
        "fecha_nacimiento": _fechaSeleccionada?.toIso8601String(),
        "microchip": _microChip,
        "arete": _arete,
      };

      if (datosFormulariosPequenosBiometrico.isNotEmpty) {
        ejemplar.addAll({
          "reg_biometrico_motivo": datosFormulariosPequenosBiometrico['motivo'],
          "reg_biometrico_fecha": datosFormulariosPequenosBiometrico['fecha'],
          "reg_biometrico_evaluador_id":
              datosFormulariosPequenosBiometrico['evaluador'],
          "reg_biometrico_peso": datosFormulariosPequenosBiometrico['peso'],
          "reg_biometrico_altura_cruz":
              datosFormulariosPequenosBiometrico['altura_cruz'],
          "reg_biometrico_altura_grupa":
              datosFormulariosPequenosBiometrico['altura_grupa'],
          "reg_biometrico_altura_cabeza":
              datosFormulariosPequenosBiometrico['altura_cabeza'],
          "reg_biometrico_ancho_pecho":
              datosFormulariosPequenosBiometrico['ancho_pecho'],
          "reg_biometrico_ancho_isquiones":
              datosFormulariosPequenosBiometrico['ancho_isquiones'],
          "reg_biometrico_perimetro_toracico":
              datosFormulariosPequenosBiometrico['perimetro_toraxico'],
          "reg_biometrico_perimetro_abdominal":
              datosFormulariosPequenosBiometrico['perimetro_abdominal'],
          "reg_biometrico_largo_cuello":
              datosFormulariosPequenosBiometrico['largo_cuello'],
          "reg_biometrico_cuello_perimetro_sup":
              datosFormulariosPequenosBiometrico['cuello_perimetro_sup'],
          "reg_biometrico_cuello_perimetro_inf":
              datosFormulariosPequenosBiometrico['cuello_perimetro_inf'],
          "reg_biometrico_largo_oreja":
              datosFormulariosPequenosBiometrico['largo_oreja'],
          "reg_biometrico_largo_cola":
              datosFormulariosPequenosBiometrico['largo_cola'],
          "reg_biometrico_diametro_cania_ant":
              datosFormulariosPequenosBiometrico['diametro_cania_ant'],
          "reg_biometrico_diametro_cania_post":
              datosFormulariosPequenosBiometrico['diametro_cania_post'],
        });
      }

      // AHORA PARA REGISTRO MORFOLOGICOS
      if (datosFormulariosMorfologico.isNotEmpty) {
        ejemplar.addAll({
          "reg_morfologico_motivo": datosFormulariosMorfologico['motivo'],
          "reg_morfologico_fecha": datosFormulariosMorfologico['fecha'],
          "reg_morfologico_evaluador_id":
              datosFormulariosMorfologico['evaluador'],
          "reg_morfologico_oreja": datosFormulariosMorfologico['oreja'],
          "reg_morfologico_cuello": datosFormulariosMorfologico['cuello'],
          "reg_morfologico_cabeza": datosFormulariosMorfologico['cabeza'],
          "reg_morfologico_alzada": datosFormulariosMorfologico['alzada'],
          "reg_morfologico_largo_cuerpo":
              datosFormulariosMorfologico['largo_cuerpo'],
          "reg_morfologico_amplitud_pecho":
              datosFormulariosMorfologico['amplitud_pecho'],
          "reg_morfologico_fortaleza": datosFormulariosMorfologico['fortaleza'],
          "reg_morfologico_balance": datosFormulariosMorfologico['balance'],
          "reg_morfologico_canias": datosFormulariosMorfologico['canias'],
          "reg_morfologico_copete": datosFormulariosMorfologico['copete'],
          "reg_morfologico_linea_superior":
              datosFormulariosMorfologico['linea_superior'],
          "reg_morfologico_grupa": datosFormulariosMorfologico['grupa'],
        });
      }

      // AHORA PARA FIBRAS
      if (datosFormulariosFibras.isNotEmpty) {
        ejemplar.addAll({
          "reg_fibra_laboratorio_id":
              datosFormulariosFibras['laboratorio'] != null
                  ? int.tryParse(datosFormulariosFibras['laboratorio'])
                  : null,
          "reg_fibra_equipo_id":
              datosFormulariosFibras['equipo'] != null
                  ? int.tryParse(datosFormulariosFibras['equipo'])
                  : null,
          "reg_fibra_fecha_muestreo": datosFormulariosFibras['fecha_muestreo'],
          "reg_fibra_fecha_analisis": datosFormulariosFibras['fecha_analisis'],
          "reg_fibra_zona_corporal": datosFormulariosFibras['zona_corporal'],
          "reg_fibra_fd": datosFormulariosFibras['fd'],
          "reg_fibra_sd": datosFormulariosFibras['sd'],
          "reg_fibra_cv": datosFormulariosFibras['cv'],
          "reg_fibra_fc": datosFormulariosFibras['fc'],
          "reg_fibra_pm": datosFormulariosFibras['pm'],
          "reg_fibra_mfd": datosFormulariosFibras['mfd'],
        });
      }

      // AHORA PARA ESQUILAS
      if (datosFormulariosEsquila.isNotEmpty) {
        ejemplar.addAll({
          "reg_esquila_esquilador_id":
              datosFormulariosEsquila['esquilador'] != null
                  ? int.tryParse(datosFormulariosEsquila['esquilador'])
                  : null,
          "reg_esquila_fecha": datosFormulariosEsquila['fecha_esquila'],
          "reg_esquila_tipo_esquila": datosFormulariosEsquila['tipo_esquila'],
          "reg_esquila_inca_esquila":
              datosFormulariosEsquila['inca_esquila'] == true ? 1 : 0,
          "reg_esquila_peso_manto":
              datosFormulariosEsquila['peso_manto']?.isNotEmpty == true
                  ? datosFormulariosEsquila['peso_manto']
                  : null,
          "reg_esquila_peso_cuello":
              datosFormulariosEsquila['peso_cuello']?.isNotEmpty == true
                  ? datosFormulariosEsquila['peso_cuello']
                  : null,
          "reg_esquila_peso_braga":
              datosFormulariosEsquila['peso_braga']?.isNotEmpty == true
                  ? datosFormulariosEsquila['peso_braga']
                  : null,
          "reg_esquila_peso_total":
              datosFormulariosEsquila['peso_total']?.isNotEmpty == true
                  ? datosFormulariosEsquila['peso_total']
                  : null,
          "reg_esquila_longitud":
              datosFormulariosEsquila['longitud']?.isNotEmpty == true
                  ? datosFormulariosEsquila['longitud']
                  : null,
          "reg_esquila_observacion":
              datosFormulariosEsquila['observacion']?.isNotEmpty == true
                  ? datosFormulariosEsquila['observacion']
                  : null,
        });
      }

      if (datosFormulariosMedicacion.isNotEmpty) {
        ejemplar.addAll({
          "reg_medicacion_producto_veterrinario_id":
              datosFormulariosMedicacion['producto_veterinario_id'] != null
                  ? int.tryParse(
                    datosFormulariosMedicacion['producto_veterinario_id'],
                  )
                  : null,
          "reg_medicacion_responsable_id":
              datosFormulariosMedicacion['responsable_id'] != null
                  ? int.tryParse(datosFormulariosMedicacion['responsable_id'])
                  : null,
          "reg_medicacion_fecha": datosFormulariosMedicacion['fecha'],
          "reg_medicacion_tipo":
              datosFormulariosMedicacion['tipo']?.isNotEmpty == true
                  ? datosFormulariosMedicacion['tipo']
                  : null,
          "reg_medicacion_docis":
              datosFormulariosMedicacion['dosis']?.toString().isNotEmpty == true
                  ? datosFormulariosMedicacion['dosis'].toString()
                  : null,
          "reg_medicacion_unidades":
              datosFormulariosMedicacion['unidades']?.isNotEmpty == true
                  ? datosFormulariosMedicacion['unidades']
                  : null,
          "reg_medicacion_observacion":
              datosFormulariosMedicacion['observacion']?.isNotEmpty == true
                  ? datosFormulariosMedicacion['observacion']
                  : null,
        });
      }

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
                datosFormulariosPequenosBiometrico.addAll(datos);
              });
            },
          ),
    );
  }

  void _abrirFormularioMorfologico() {
    showDialog(
      context: context,
      builder:
          (context) => FormularioMorfologicoLlama(
            onGuardar: (datos) {
              setState(() {
                datosFormulariosMorfologico.addAll(datos);
              });
            },
          ),
    );
  }

  void _abrirFormularioFibra() {
    showDialog(
      context: context,
      builder:
          (context) => FormularioFibraLlama(
            onGuardar: (datos) {
              setState(() {
                datosFormulariosFibras.addAll(datos);
              });
            },
          ),
    );
  }

  void _abrirFormularioEsquila() {
    showDialog(
      context: context,
      builder:
          (context) => FormularioEsquilaLlama(
            onGuardar: (datos) {
              setState(() {
                datosFormulariosEsquila.addAll(datos);
              });
            },
          ),
    );
  }

  void _abrirFormularioMedicacion() {
    showDialog(
      context: context,
      builder:
          (context) => FormularioMedicacionLlama(
            onGuardar: (datos) {
              datosFormulariosMedicacion.addAll(datos);
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
          "Form. Registro de Alpaca",
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

                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Selecciona el tipo parto",
                    labelStyle: TextStyle(color: Color(0xFF7A6E2A)),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF7A6E2A),
                        width: 2,
                      ),
                    ),
                  ),
                  value: _tipo_parto,
                  items:
                      _tipo_partos.map<DropdownMenuItem<String>>((tipoParto) {
                        return DropdownMenuItem<String>(
                          value: tipoParto,
                          child: Text(tipoParto),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _tipo_parto = value;
                    });
                  },
                  validator:
                      (value) =>
                          value == null ? "Seleccione un tipo de parto" : null,
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
                    labelText: "Selecciona un Tipo",
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
                    : Text("No hay fotos tomadas"),
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
