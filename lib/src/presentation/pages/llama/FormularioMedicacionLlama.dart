import 'package:flutter/material.dart';

class ProductoVeterinario {
  final String id;
  final String nombre;
  ProductoVeterinario({required this.id, required this.nombre});
}

class Responsable {
  final String id;
  final String nombreCompleto;
  Responsable({required this.id, required this.nombreCompleto});
}

class FormularioMedicacionLlama extends StatefulWidget {
  final List<ProductoVeterinario> productos;
  final List<Responsable> responsables;
  final void Function(Map<String, dynamic>) onGuardar;

  const FormularioMedicacionLlama({
    Key? key,
    required this.productos,
    required this.responsables,
    required this.onGuardar,
  }) : super(key: key);

  @override
  _FormularioMedicacionState createState() => _FormularioMedicacionState();
}

class _FormularioMedicacionState extends State<FormularioMedicacionLlama> {
  final _formKey = GlobalKey<FormState>();

  ProductoVeterinario? productoSeleccionado;
  Responsable? responsableSeleccionado;
  DateTime? fecha;

  final tipoController = TextEditingController();
  final dosisController = TextEditingController();
  final unidadesController = TextEditingController();
  final observacionController = TextEditingController();

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
        'producto_veterinario_id': productoSeleccionado!.id,
        'responsable_id': responsableSeleccionado!.id,
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Formulario de Medicación'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<ProductoVeterinario>(
                decoration: const InputDecoration(
                  labelText: 'Producto Veterinario',
                ),
                value: productoSeleccionado,
                items:
                    widget.productos
                        .map(
                          (p) =>
                              DropdownMenuItem(value: p, child: Text(p.nombre)),
                        )
                        .toList(),
                onChanged: (val) => setState(() => productoSeleccionado = val),
                validator:
                    (val) => val == null ? 'Seleccione un producto' : null,
              ),
              DropdownButtonFormField<Responsable>(
                decoration: const InputDecoration(labelText: 'Responsable'),
                value: responsableSeleccionado,
                items:
                    widget.responsables
                        .map(
                          (r) => DropdownMenuItem(
                            value: r,
                            child: Text(r.nombreCompleto),
                          ),
                        )
                        .toList(),
                onChanged:
                    (val) => setState(() => responsableSeleccionado = val),
                validator:
                    (val) => val == null ? 'Seleccione un responsable' : null,
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
              TextFormField(
                controller: tipoController,
                decoration: const InputDecoration(labelText: 'Tipo'),
                validator:
                    (val) =>
                        (val == null || val.isEmpty) ? 'Campo requerido' : null,
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
