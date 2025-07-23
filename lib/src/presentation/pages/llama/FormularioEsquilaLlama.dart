import 'package:FENCAMEL/src/domain/UsuarioService.dart';
import 'package:flutter/material.dart';

class FormularioEsquilaLlama extends StatefulWidget {
  // final List<String> esquiladores;
  final void Function(Map<String, dynamic>) onGuardar;

  const FormularioEsquilaLlama({
    Key? key,
    // required this.esquiladores,
    required this.onGuardar,
  }) : super(key: key);

  @override
  _FormularioEsquilaState createState() => _FormularioEsquilaState();
}

class _FormularioEsquilaState extends State<FormularioEsquilaLlama> {
  final _formKey = GlobalKey<FormState>();

  String? esquiladorSeleccionado;
  DateTime? fechaEsquila;

  final tipoEsquilaController = TextEditingController();
  final pesoMantoController = TextEditingController();
  final pesoCuelloController = TextEditingController();
  final pesoBragaController = TextEditingController();
  final pesoTotalController = TextEditingController();
  final longitudController = TextEditingController();
  final observacionController = TextEditingController();

  bool incaEsquila = false;

  final Usuarioservice usuarioservice = Usuarioservice();

  @override
  void dispose() {
    tipoEsquilaController.dispose();
    pesoMantoController.dispose();
    pesoCuelloController.dispose();
    pesoBragaController.dispose();
    pesoTotalController.dispose();
    longitudController.dispose();
    observacionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fechaEsquila ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );
    if (picked != null) {
      setState(() {
        fechaEsquila = picked;
      });
    }
  }

  void _guardar() {
    if (_formKey.currentState!.validate() &&
        esquiladorSeleccionado != null &&
        fechaEsquila != null) {
      final datos = {
        'esquilador': esquiladorSeleccionado,
        'fecha_esquila': fechaEsquila!.toIso8601String(),
        'tipo_esquila': tipoEsquilaController.text,
        'inca_esquila': incaEsquila,
        'peso_manto': pesoMantoController.text,
        'peso_cuello': pesoCuelloController.text,
        'peso_braga': pesoBragaController.text,
        'peso_total': pesoTotalController.text,
        'longitud': longitudController.text,
        'observacion': observacionController.text,
      };
      widget.onGuardar(datos);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete todos los campos requeridos')),
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
    cargarUsuarios(); // Aquí cargas la lista apenas se abre el diálogo
  }

  List<Map<String, dynamic>> _esquiladores = [];

  Future<void> cargarUsuarios() async {
    List<Map<String, dynamic>> usuarios = await usuarioservice.listaUsuarios();
    setState(() {
      _esquiladores = usuarios;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registro Esquilas'),
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
                      decoration: InputDecoration(labelText: "Esquilador"),
                      isExpanded: true,
                      value: esquiladorSeleccionado,
                      items:
                          _esquiladores.map((usuario) {
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
                          esquiladorSeleccionado = val;
                        });
                      },
                      validator:
                          (val) => val == null ? 'Seleccione esquilador' : null,
                    ),
                  );
                },
              ),
              GestureDetector(
                onTap: () => _seleccionarFecha(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'Fecha'),
                    controller: TextEditingController(
                      text:
                          fechaEsquila == null
                              ? ''
                              : "${fechaEsquila!.toLocal()}".split(' ')[0],
                    ),
                    validator:
                        (val) =>
                            (val == null || val.isEmpty)
                                ? 'Seleccione fecha'
                                : null,
                  ),
                ),
              ),
              _campoTexto('Tipo Esquila', tipoEsquilaController),
              SwitchListTile(
                title: const Text('Inca Esquila?'),
                value: incaEsquila,
                onChanged: (val) => setState(() => incaEsquila = val),
              ),
              _campoTexto(
                'Peso Manto',
                pesoMantoController,
                requerido: false,
                keyboardType: TextInputType.number,
              ),
              _campoTexto(
                'Peso Cuello',
                pesoCuelloController,
                requerido: false,
                keyboardType: TextInputType.number,
              ),
              _campoTexto(
                'Peso Braga',
                pesoBragaController,
                requerido: false,
                keyboardType: TextInputType.number,
              ),
              _campoTexto(
                'Peso Total',
                pesoTotalController,
                requerido: false,
                keyboardType: TextInputType.number,
              ),
              _campoTexto(
                'Longitud',
                longitudController,
                requerido: false,
                keyboardType: TextInputType.number,
              ),
              _campoTexto(
                'Observación',
                observacionController,
                requerido: false,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _guardar, child: const Text('Guardar')),
            ],
          ),
        ),
      ),
    );
  }
}
