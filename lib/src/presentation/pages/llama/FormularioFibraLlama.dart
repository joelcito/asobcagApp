import 'package:FENCAMEL/src/domain/EquipoService.dart';
import 'package:FENCAMEL/src/domain/LaboratorioService.dart';
import 'package:flutter/material.dart';

class FormularioFibraLlama extends StatefulWidget {
  // final List<String> laboratorios;
  // final List<String> equipos;
  final void Function(Map<String, dynamic>) onGuardar;

  const FormularioFibraLlama({
    Key? key,
    // required this.laboratorios,
    // required this.equipos,
    required this.onGuardar,
  }) : super(key: key);

  @override
  _FormularioFibraState createState() => _FormularioFibraState();
}

class _FormularioFibraState extends State<FormularioFibraLlama> {
  final _formKey = GlobalKey<FormState>();

  String? laboratorioSeleccionado;
  String? equipoSeleccionado;
  DateTime? fechaMuestreo;
  DateTime? fechaAnalisis;

  final TextEditingController zonaCorporalController = TextEditingController();
  final TextEditingController fdController = TextEditingController();
  final TextEditingController sdController = TextEditingController();
  final TextEditingController cvController = TextEditingController();
  final TextEditingController fcController = TextEditingController();
  final TextEditingController pmController = TextEditingController();
  final TextEditingController mfdController = TextEditingController();

  final Laboratorioservice laboratorioservice = Laboratorioservice();
  final Equiposervice equiposervice = Equiposervice();

  @override
  void dispose() {
    zonaCorporalController.dispose();
    fdController.dispose();
    sdController.dispose();
    cvController.dispose();
    fcController.dispose();
    pmController.dispose();
    mfdController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(BuildContext context, bool esMuestreo) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );
    if (picked != null) {
      setState(() {
        if (esMuestreo) {
          fechaMuestreo = picked;
        } else {
          fechaAnalisis = picked;
        }
      });
    }
  }

  void _guardar() {
    if (_formKey.currentState!.validate() &&
        laboratorioSeleccionado != null &&
        equipoSeleccionado != null &&
        fechaMuestreo != null &&
        fechaAnalisis != null) {
      final datos = {
        'laboratorio': laboratorioSeleccionado,
        'equipo': equipoSeleccionado,
        'fecha_muestreo': fechaMuestreo!.toIso8601String(),
        'fecha_analisis': fechaAnalisis!.toIso8601String(),
        'zona_corporal': zonaCorporalController.text,
        'fd': fdController.text,
        'sd': sdController.text,
        'cv': cvController.text,
        'fc': fcController.text,
        'pm': pmController.text,
        'mfd': mfdController.text,
      };
      widget.onGuardar(datos);
      Navigator.pop(context);
    } else {
      // Puedes mostrar mensajes de error si quieres
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Complete todos los campos requeridos')),
      );
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
  void initState() {
    super.initState();
    cargarLaboratorios();
    cargarEquipos();
  }

  List<Map<String, dynamic>> _laboratorios = [];

  Future<void> cargarLaboratorios() async {
    List<Map<String, dynamic>> laboratorios =
        await laboratorioservice.listaLaboratorios();
    setState(() {
      _laboratorios = laboratorios;
    });
  }

  List<Map<String, dynamic>> _equipos = [];

  Future<void> cargarEquipos() async {
    List<Map<String, dynamic>> equipos = await equiposervice.listaEquipos();
    setState(() {
      _equipos = equipos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Registro Fibras'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth:
                          constraints
                              .maxWidth, // se ajusta al tamaño del dialog
                    ),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: "Laboratorio"),
                      isExpanded: true,
                      value: laboratorioSeleccionado,
                      items:
                          _laboratorios.map((usuario) {
                            return DropdownMenuItem<String>(
                              value: usuario['laboratorio_id'].toString(),
                              child: Text(
                                usuario['nombre'],
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            );
                          }).toList(),
                      onChanged: (val) {
                        setState(() {
                          laboratorioSeleccionado = val;
                        });
                      },
                      validator:
                          (val) =>
                              val == null ? 'Seleccione laboratorio' : null,
                    ),
                  );
                },
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth:
                          constraints
                              .maxWidth, // se ajusta al tamaño del dialog
                    ),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: "Equipo"),
                      isExpanded: true,
                      value: equipoSeleccionado,
                      items:
                          _equipos.map((usuario) {
                            return DropdownMenuItem<String>(
                              value: usuario['equipo_id'].toString(),
                              child: Text(
                                usuario['nombre'],
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            );
                          }).toList(),
                      onChanged: (val) {
                        setState(() {
                          equipoSeleccionado = val;
                        });
                      },
                      validator:
                          (val) => val == null ? 'Seleccione equipo' : null,
                    ),
                  );
                },
              ),
              GestureDetector(
                onTap: () => _seleccionarFecha(context, true),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Fecha Muestreo'),
                    controller: TextEditingController(
                      text:
                          fechaMuestreo == null
                              ? ''
                              : "${fechaMuestreo!.toLocal()}".split(' ')[0],
                    ),
                    validator:
                        (val) =>
                            (val == null || val.isEmpty)
                                ? 'Seleccione fecha'
                                : null,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _seleccionarFecha(context, false),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Fecha Análisis'),
                    controller: TextEditingController(
                      text:
                          fechaAnalisis == null
                              ? ''
                              : "${fechaAnalisis!.toLocal()}".split(' ')[0],
                    ),
                    validator:
                        (val) =>
                            (val == null || val.isEmpty)
                                ? 'Seleccione fecha'
                                : null,
                  ),
                ),
              ),
              _campoTexto(
                'Zona corporal',
                zonaCorporalController,
                requerido: false,
              ),
              _campoTexto(
                'FD',
                fdController,
                requerido: false,
                keyboardType: TextInputType.number,
              ),
              _campoTexto(
                'SD',
                sdController,
                requerido: false,
                keyboardType: TextInputType.number,
              ),
              _campoTexto(
                'CV',
                cvController,
                requerido: false,
                keyboardType: TextInputType.number,
              ),
              _campoTexto(
                'FC',
                fcController,
                requerido: false,
                keyboardType: TextInputType.number,
              ),
              _campoTexto(
                'PM',
                pmController,
                requerido: false,
                keyboardType: TextInputType.number,
              ),
              _campoTexto(
                'MFD',
                mfdController,
                requerido: false,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _guardar, child: Text('Guardar')),
            ],
          ),
        ),
      ),
    );
  }
}
