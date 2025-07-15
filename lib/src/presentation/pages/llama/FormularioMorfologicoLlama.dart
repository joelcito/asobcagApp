import 'package:flutter/material.dart';

class FormularioMorfologicoLlama extends StatefulWidget {
  final List<String> evaluadores;
  final void Function(Map<String, dynamic> datos) onGuardar;

  FormularioMorfologicoLlama({
    required this.evaluadores,
    required this.onGuardar,
  });

  @override
  _FormularioMorfologicoLlamaState createState() =>
      _FormularioMorfologicoLlamaState();
}

class _FormularioMorfologicoLlamaState
    extends State<FormularioMorfologicoLlama> {
  final _formKey = GlobalKey<FormState>();

  // Campos
  String? motivoSeleccionado;
  DateTime? fechaSeleccionada;
  String? evaluadorSeleccionado;

  final TextEditingController orejaController = TextEditingController();
  final TextEditingController cuelloController = TextEditingController();
  final TextEditingController cabezaController = TextEditingController();
  final TextEditingController alzadaController = TextEditingController();
  final TextEditingController largoCuerpoController = TextEditingController();
  final TextEditingController amplitudPechoController = TextEditingController();
  final TextEditingController fortalezaController = TextEditingController();
  final TextEditingController balanceController = TextEditingController();
  final TextEditingController caniasController = TextEditingController();
  final TextEditingController copeteController = TextEditingController();
  final TextEditingController lineaSuperiorController = TextEditingController();
  final TextEditingController grupaController = TextEditingController();

  final List<String> motivos = [
    "Destete",
    "1 Esquila",
    "2 Esquila",
    "3 Esquila",
    "4 Esquila",
    "5 Esquila",
    "Otro",
  ];

  @override
  void dispose() {
    orejaController.dispose();
    cuelloController.dispose();
    cabezaController.dispose();
    alzadaController.dispose();
    largoCuerpoController.dispose();
    amplitudPechoController.dispose();
    fortalezaController.dispose();
    balanceController.dispose();
    caniasController.dispose();
    copeteController.dispose();
    lineaSuperiorController.dispose();
    grupaController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );
    if (picked != null) {
      setState(() {
        fechaSeleccionada = picked;
      });
    }
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      final datos = {
        "motivo": motivoSeleccionado,
        "fecha": fechaSeleccionada?.toIso8601String(),
        "evaluador": evaluadorSeleccionado,
        "oreja": orejaController.text,
        "cuello": cuelloController.text,
        "cabeza": cabezaController.text,
        "alzada": alzadaController.text,
        "largo_cuerpo": largoCuerpoController.text,
        "amplitud_pecho": amplitudPechoController.text,
        "fortaleza": fortalezaController.text,
        "balance": balanceController.text,
        "canias": caniasController.text,
        "copete": copeteController.text,
        "linea_superior": lineaSuperiorController.text,
        "grupa": grupaController.text,
      };
      widget.onGuardar(datos);
      Navigator.pop(context);
    }
  }

  Widget _campoTexto(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator:
          (value) =>
              (value == null || value.isEmpty) ? 'Complete este campo' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Formulario de Registro Morfológico - Llama"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Motivo Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "Motivo"),
                items:
                    motivos
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                value: motivoSeleccionado,
                onChanged: (val) => setState(() => motivoSeleccionado = val),
                validator: (val) => val == null ? 'Seleccione un motivo' : null,
              ),

              SizedBox(height: 10),

              // Fecha picker
              GestureDetector(
                onTap: () => _seleccionarFecha(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: "Fecha",
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    controller: TextEditingController(
                      text:
                          fechaSeleccionada == null
                              ? ''
                              : "${fechaSeleccionada!.toLocal()}".split(' ')[0],
                    ),
                    validator:
                        (val) =>
                            (val == null || val.isEmpty)
                                ? 'Seleccione fecha'
                                : null,
                  ),
                ),
              ),

              SizedBox(height: 10),

              // Evaluador Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "Evaluador"),
                items:
                    widget.evaluadores
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                value: evaluadorSeleccionado,
                onChanged: (val) => setState(() => evaluadorSeleccionado = val),
                validator:
                    (val) => val == null ? 'Seleccione un evaluador' : null,
              ),

              SizedBox(height: 10),

              // Campos morfologicos
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  SizedBox(
                    width: 120,
                    child: _campoTexto("Oreja", orejaController),
                  ),
                  SizedBox(
                    width: 120,
                    child: _campoTexto("Cuello", cuelloController),
                  ),
                  SizedBox(
                    width: 120,
                    child: _campoTexto("Cabeza", cabezaController),
                  ),
                  SizedBox(
                    width: 120,
                    child: _campoTexto("Alzada", alzadaController),
                  ),
                  SizedBox(
                    width: 120,
                    child: _campoTexto("Largo Cuerpo", largoCuerpoController),
                  ),
                  SizedBox(
                    width: 120,
                    child: _campoTexto(
                      "Amplitud Pecho",
                      amplitudPechoController,
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: _campoTexto("Fortaleza", fortalezaController),
                  ),
                  SizedBox(
                    width: 120,
                    child: _campoTexto("Balance", balanceController),
                  ),
                  SizedBox(
                    width: 120,
                    child: _campoTexto("Canias", caniasController),
                  ),
                  SizedBox(
                    width: 120,
                    child: _campoTexto("Copete", copeteController),
                  ),
                  SizedBox(
                    width: 120,
                    child: _campoTexto(
                      "Línea Superior",
                      lineaSuperiorController,
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: _campoTexto("Grupa", grupaController),
                  ),
                ],
              ),

              SizedBox(height: 20),
              ElevatedButton(onPressed: _guardar, child: Text("Guardar")),
            ],
          ),
        ),
      ),
    );
  }
}
