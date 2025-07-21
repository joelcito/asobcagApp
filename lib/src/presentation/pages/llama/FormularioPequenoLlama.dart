import 'package:FENCAMEL/src/domain/UsuarioService.dart';
import 'package:flutter/material.dart';

class FormularioPequenoLlama extends StatefulWidget {
  final void Function(Map<String, dynamic> datos) onGuardar;

  FormularioPequenoLlama({required this.onGuardar});

  @override
  _FormularioPequenoLlamaState createState() => _FormularioPequenoLlamaState();
}

class _FormularioPequenoLlamaState extends State<FormularioPequenoLlama> {
  final _formKey = GlobalKey<FormState>();

  // Controladores o variables para cada campo
  final TextEditingController motivoController = TextEditingController(
    text: "Nacimiento",
  );
  final TextEditingController fechaController = TextEditingController();
  String? evaluadorSeleccionado;

  final TextEditingController pesoController = TextEditingController();
  final TextEditingController alturaCruzController = TextEditingController();
  final TextEditingController alturaGrupaController = TextEditingController();
  final TextEditingController alturaCabezaController = TextEditingController();
  final TextEditingController anchoPechoController = TextEditingController();
  final TextEditingController anchoIsquionesController =
      TextEditingController();
  final TextEditingController perimetroToraxicoController =
      TextEditingController();
  final TextEditingController perimetroAbdominalController =
      TextEditingController();
  final TextEditingController largoCuelloController = TextEditingController();
  final TextEditingController cuelloPerimetroSupController =
      TextEditingController();
  final TextEditingController cuelloPerimetroInfController =
      TextEditingController();
  final TextEditingController largoOrejaController = TextEditingController();
  final TextEditingController largoColaController = TextEditingController();
  final TextEditingController diametroCaniaAntController =
      TextEditingController();
  final TextEditingController diametroCaniaPostController =
      TextEditingController();

  final Usuarioservice usuarioservice = Usuarioservice();

  // Ejemplo lista evaluadores
  // final List<String> evaluadores = [
  //   "Evaluador 1",
  //   "Evaluador 2",
  //   "Evaluador 3",
  // ];

  @override
  void initState() {
    super.initState();
    cargarUsuarios(); // Aquí cargas la lista apenas se abre el diálogo
  }

  List<Map<String, dynamic>> evaluadores = [];

  Future<void> cargarUsuarios() async {
    List<Map<String, dynamic>> usuarios = await usuarioservice.listaUsuarios();
    setState(() {
      evaluadores = usuarios;
    });
  }

  @override
  void dispose() {
    motivoController.dispose();
    fechaController.dispose();
    pesoController.dispose();
    alturaCruzController.dispose();
    alturaGrupaController.dispose();
    alturaCabezaController.dispose();
    anchoPechoController.dispose();
    anchoIsquionesController.dispose();
    perimetroToraxicoController.dispose();
    perimetroAbdominalController.dispose();
    largoCuelloController.dispose();
    cuelloPerimetroSupController.dispose();
    cuelloPerimetroInfController.dispose();
    largoOrejaController.dispose();
    largoColaController.dispose();
    diametroCaniaAntController.dispose();
    diametroCaniaPostController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );
    if (pickedDate != null) {
      setState(() {
        fechaController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      // Preparar datos para enviar al padre
      final Map<String, dynamic> datos = {
        "motivo": motivoController.text,
        "fecha": fechaController.text,
        "evaluador": evaluadorSeleccionado,
        "peso": pesoController.text,
        "altura_cruz": alturaCruzController.text,
        "altura_grupa": alturaGrupaController.text,
        "altura_cabeza": alturaCabezaController.text,
        "ancho_pecho": anchoPechoController.text,
        "ancho_isquiones": anchoIsquionesController.text,
        "perimetro_toraxico": perimetroToraxicoController.text,
        "perimetro_abdominal": perimetroAbdominalController.text,
        "largo_cuello": largoCuelloController.text,
        "cuello_perimetro_sup": cuelloPerimetroSupController.text,
        "cuello_perimetro_inf": cuelloPerimetroInfController.text,
        "largo_oreja": largoOrejaController.text,
        "largo_cola": largoColaController.text,
        "diametro_cania_ant": diametroCaniaAntController.text,
        "diametro_cania_post": diametroCaniaPostController.text,
      };
      widget.onGuardar(datos);
      Navigator.pop(context);
    }
  }

  Widget _campoTexto(
    String label,
    TextEditingController controller, {
    bool requerido = true,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      readOnly: readOnly,
      keyboardType: keyboardType,
      validator: (value) {
        if (requerido && (value == null || value.isEmpty)) {
          return 'Complete este campo';
        }
        return null;
      },
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Registro Biométrico"),
      content: SizedBox(
        width: 350,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _campoTexto("Motivo", motivoController, requerido: true),
                GestureDetector(
                  onTap: () => _seleccionarFecha(context),
                  child: AbsorbPointer(
                    child: _campoTexto(
                      "Fecha",
                      fechaController,
                      requerido: true,
                      readOnly: true,
                    ),
                  ),
                ),
                // DropdownButtonFormField<String>(
                //   decoration: InputDecoration(labelText: "Evaluador"),
                //   value: evaluadorSeleccionado,
                //   items:
                //       evaluadores.map((usuario) {
                //         return DropdownMenuItem<String>(
                //           value: usuario['usuario_id'].toString(),
                //           child: Text(
                //             usuario['nombre'],
                //             overflow: TextOverflow.ellipsis,
                //             maxLines: 1,
                //           ),
                //         );
                //       }).toList(),
                //   onChanged: (val) {
                //     setState(() {
                //       evaluadorSeleccionado = val;
                //     });
                //   },
                //   validator: (val) => val == null ? 'Seleccione evaluador' : null,
                // ),
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        width: double.infinity,
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(labelText: "Evaluador"),
                          value: evaluadorSeleccionado,
                          items:
                              evaluadores.map((usuario) {
                                return DropdownMenuItem<String>(
                                  value: usuario['usuario_id'].toString(),
                                  child: Text(
                                    usuario['nombre'],
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                );
                              }).toList(),
                          onChanged: (val) {
                            setState(() {
                              evaluadorSeleccionado = val;
                            });
                          },
                          validator:
                              (val) =>
                                  val == null ? 'Seleccione evaluador' : null,
                        ),
                      ),
                    ),
                  ],
                ),
                _campoTexto(
                  "Peso",
                  pesoController,
                  requerido: false,
                  keyboardType: TextInputType.number,
                ),
                _campoTexto(
                  "Altura Cruz",
                  alturaCruzController,
                  requerido: false,
                  keyboardType: TextInputType.number,
                ),
                _campoTexto(
                  "Altura Grupa",
                  alturaGrupaController,
                  requerido: false,
                  keyboardType: TextInputType.number,
                ),
                _campoTexto(
                  "Altura Cabeza",
                  alturaCabezaController,
                  requerido: false,
                  keyboardType: TextInputType.number,
                ),
                _campoTexto(
                  "Ancho Pecho",
                  anchoPechoController,
                  requerido: false,
                  keyboardType: TextInputType.number,
                ),
                _campoTexto(
                  "Ancho Isquiones",
                  anchoIsquionesController,
                  requerido: false,
                  keyboardType: TextInputType.number,
                ),
                _campoTexto(
                  "Perímetro Torácico",
                  perimetroToraxicoController,
                  requerido: false,
                  keyboardType: TextInputType.number,
                ),
                _campoTexto(
                  "Perímetro Abdominal",
                  perimetroAbdominalController,
                  requerido: false,
                  keyboardType: TextInputType.number,
                ),
                _campoTexto(
                  "Largo Cuello",
                  largoCuelloController,
                  requerido: false,
                  keyboardType: TextInputType.number,
                ),
                _campoTexto(
                  "Cuello Perímetro Sup.",
                  cuelloPerimetroSupController,
                  requerido: false,
                  keyboardType: TextInputType.number,
                ),
                _campoTexto(
                  "Cuello Perímetro Inf.",
                  cuelloPerimetroInfController,
                  requerido: false,
                  keyboardType: TextInputType.number,
                ),
                _campoTexto(
                  "Largo Oreja",
                  largoOrejaController,
                  requerido: false,
                  keyboardType: TextInputType.number,
                ),
                _campoTexto(
                  "Largo Cola",
                  largoColaController,
                  requerido: false,
                  keyboardType: TextInputType.number,
                ),
                _campoTexto(
                  "Diámetro Cania Ant.",
                  diametroCaniaAntController,
                  requerido: false,
                  keyboardType: TextInputType.number,
                ),
                _campoTexto(
                  "Diámetro Cania Post.",
                  diametroCaniaPostController,
                  requerido: false,
                  keyboardType: TextInputType.number,
                ),

                SizedBox(height: 20),
                ElevatedButton(onPressed: _guardar, child: Text("Guardar")),
              ],
            ),
          ),
        ),
      ),

      // content: SingleChildScrollView(
      //   child: Form(
      //     key: _formKey,
      //     child: Column(
      //       mainAxisSize: MainAxisSize.min,
      //       children: [
      //         _campoTexto("Motivo", motivoController, requerido: true),
      //         GestureDetector(
      //           onTap: () => _seleccionarFecha(context),
      //           child: AbsorbPointer(
      //             child: _campoTexto(
      //               "Fecha",
      //               fechaController,
      //               requerido: true,
      //               readOnly: true,
      //             ),
      //           ),
      //         ),
      //         // DropdownButtonFormField<String>(
      //         //   decoration: InputDecoration(labelText: "Evaluador"),
      //         //   value: evaluadorSeleccionado,
      //         //   items:
      //         //       evaluadores.map((usuario) {
      //         //         return DropdownMenuItem<String>(
      //         //           value: usuario['usuario_id'].toString(),
      //         //           child: Text(
      //         //             usuario['nombre'],
      //         //             overflow: TextOverflow.ellipsis,
      //         //             maxLines: 1,
      //         //           ),
      //         //         );
      //         //       }).toList(),
      //         //   onChanged: (val) {
      //         //     setState(() {
      //         //       evaluadorSeleccionado = val;
      //         //     });
      //         //   },
      //         //   validator: (val) => val == null ? 'Seleccione evaluador' : null,
      //         // ),
      //         Row(
      //           children: [
      //             Expanded(
      //               child: DropdownButtonFormField<String>(
      //                 decoration: InputDecoration(labelText: "Evaluador"),
      //                 value: evaluadorSeleccionado,
      //                 items:
      //                     evaluadores.map((usuario) {
      //                       return DropdownMenuItem<String>(
      //                         value: usuario['usuario_id'].toString(),
      //                         child: Text(
      //                           usuario['nombre'],
      //                           overflow: TextOverflow.ellipsis,
      //                           maxLines: 1,
      //                         ),
      //                       );
      //                     }).toList(),
      //                 onChanged: (val) {
      //                   setState(() {
      //                     evaluadorSeleccionado = val;
      //                   });
      //                 },
      //                 validator:
      //                     (val) => val == null ? 'Seleccione evaluador' : null,
      //               ),
      //             ),
      //           ],
      //         ),
      //         _campoTexto(
      //           "Peso",
      //           pesoController,
      //           requerido: false,
      //           keyboardType: TextInputType.number,
      //         ),
      //         _campoTexto(
      //           "Altura Cruz",
      //           alturaCruzController,
      //           requerido: false,
      //           keyboardType: TextInputType.number,
      //         ),
      //         _campoTexto(
      //           "Altura Grupa",
      //           alturaGrupaController,
      //           requerido: false,
      //           keyboardType: TextInputType.number,
      //         ),
      //         _campoTexto(
      //           "Altura Cabeza",
      //           alturaCabezaController,
      //           requerido: false,
      //           keyboardType: TextInputType.number,
      //         ),
      //         _campoTexto(
      //           "Ancho Pecho",
      //           anchoPechoController,
      //           requerido: false,
      //           keyboardType: TextInputType.number,
      //         ),
      //         _campoTexto(
      //           "Ancho Isquiones",
      //           anchoIsquionesController,
      //           requerido: false,
      //           keyboardType: TextInputType.number,
      //         ),
      //         _campoTexto(
      //           "Perímetro Torácico",
      //           perimetroToraxicoController,
      //           requerido: false,
      //           keyboardType: TextInputType.number,
      //         ),
      //         _campoTexto(
      //           "Perímetro Abdominal",
      //           perimetroAbdominalController,
      //           requerido: false,
      //           keyboardType: TextInputType.number,
      //         ),
      //         _campoTexto(
      //           "Largo Cuello",
      //           largoCuelloController,
      //           requerido: false,
      //           keyboardType: TextInputType.number,
      //         ),
      //         _campoTexto(
      //           "Cuello Perímetro Sup.",
      //           cuelloPerimetroSupController,
      //           requerido: false,
      //           keyboardType: TextInputType.number,
      //         ),
      //         _campoTexto(
      //           "Cuello Perímetro Inf.",
      //           cuelloPerimetroInfController,
      //           requerido: false,
      //           keyboardType: TextInputType.number,
      //         ),
      //         _campoTexto(
      //           "Largo Oreja",
      //           largoOrejaController,
      //           requerido: false,
      //           keyboardType: TextInputType.number,
      //         ),
      //         _campoTexto(
      //           "Largo Cola",
      //           largoColaController,
      //           requerido: false,
      //           keyboardType: TextInputType.number,
      //         ),
      //         _campoTexto(
      //           "Diámetro Cania Ant.",
      //           diametroCaniaAntController,
      //           requerido: false,
      //           keyboardType: TextInputType.number,
      //         ),
      //         _campoTexto(
      //           "Diámetro Cania Post.",
      //           diametroCaniaPostController,
      //           requerido: false,
      //           keyboardType: TextInputType.number,
      //         ),

      //         SizedBox(height: 20),
      //         ElevatedButton(onPressed: _guardar, child: Text("Guardar")),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}
