import 'package:FENCAMEL/src/domain/ProductoVeterrinarioService.dart';
import 'package:FENCAMEL/src/domain/UsuarioService.dart';
import 'package:flutter/material.dart';

class FormularioMedicacionLlama extends StatefulWidget {
  final void Function(Map<String, dynamic>) onGuardar;

  const FormularioMedicacionLlama({required this.onGuardar});

  @override
  _FormularioMedicacionState createState() => _FormularioMedicacionState();
}

class _FormularioMedicacionState extends State<FormularioMedicacionLlama> {
  final _formKey = GlobalKey<FormState>();

  String? productoSeleccionado;
  String? responsableSeleccionado;
  DateTime? fecha;

  final tipoController = TextEditingController();
  final dosisController = TextEditingController();
  final unidadesController = TextEditingController();
  final observacionController = TextEditingController();

  final Usuarioservice usuarioservice = Usuarioservice();
  final Productoveterrinarioservice productoveterrinarioservice =
      Productoveterrinarioservice();

  @override
  void dispose() {
    tipoController.dispose();
    dosisController.dispose();
    unidadesController.dispose();
    observacionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fecha ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );
    if (picked != null) {
      setState(() {
        fecha = picked;
      });
    }
  }

  void _guardar() {
    if (_formKey.currentState!.validate() &&
        productoSeleccionado != null &&
        responsableSeleccionado != null &&
        fecha != null) {
      final datos = {
        'producto_veterinario_id': productoSeleccionado,
        'responsable_id': responsableSeleccionado,
        'fecha': fecha!.toIso8601String(),
        'tipo': tipoController.text,
        'dosis': int.tryParse(dosisController.text) ?? 0,
        'unidades': unidadesController.text,
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
    cargarProductoVeterrinarios();
  }

  List<Map<String, dynamic>> _responsables = [];

  Future<void> cargarUsuarios() async {
    List<Map<String, dynamic>> usuarios = await usuarioservice.listaUsuarios();
    setState(() {
      _responsables = usuarios;
    });
  }

  List<Map<String, dynamic>> _producto_veterrinarios = [];

  Future<void> cargarProductoVeterrinarios() async {
    List<Map<String, dynamic>> productos =
        await productoveterrinarioservice.listaProductoVeterrinarios();
    setState(() {
      _producto_veterrinarios = productos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registro Medicación'),
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
                      decoration: InputDecoration(
                        labelText: "Producto Veterrinario",
                      ),
                      isExpanded: true,
                      value: productoSeleccionado,
                      items:
                          _producto_veterrinarios.map((producto) {
                            return DropdownMenuItem<String>(
                              value:
                                  producto['producto_veterrinario_id']
                                      .toString(),
                              child: Text(
                                producto['nombre'],
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            );
                          }).toList(),
                      onChanged: (val) {
                        setState(() {
                          productoSeleccionado = val;
                        });
                      },
                      validator:
                          (val) => val == null ? 'Seleccione esquilador' : null,
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
                      decoration: InputDecoration(labelText: "Responsable"),
                      isExpanded: true,
                      value: responsableSeleccionado,
                      items:
                          _responsables.map((usuario) {
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
                          responsableSeleccionado = val;
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
                          fecha == null
                              ? ''
                              : "${fecha!.toLocal()}".split(' ')[0],
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
                "Tipo",
                tipoController,
                requerido: false,
                keyboardType: TextInputType.text,
              ),
              TextFormField(
                controller: dosisController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Dosis'),
                validator:
                    (val) =>
                        (val == null || val.isEmpty) ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: unidadesController,
                decoration: const InputDecoration(labelText: 'Unidades'),
                validator:
                    (val) =>
                        (val == null || val.isEmpty) ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: observacionController,
                decoration: const InputDecoration(labelText: 'Observación'),
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
