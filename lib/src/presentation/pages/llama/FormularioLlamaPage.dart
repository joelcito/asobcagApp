import 'package:flutter/material.dart';
import 'package:indrive_clone_flutter/src/data/EjemplarService.dart';

class FormularioLlamaPage extends StatefulWidget {
  @override
  _FormularioLlamaPageState createState() => _FormularioLlamaPageState();
}

class _FormularioLlamaPageState extends State<FormularioLlamaPage> {
  final _formKey = GlobalKey<FormState>();
  String _nombre = '';
  String _especie = '';
  String _descripcion = '';
  final EjemplarService ejemplarService = EjemplarService();

  void _guardarEjemplar() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Aquí llamas al servicio para enviar los datos a la API
      print("Guardando ejemplar: $_nombre, $_especie, $_descripcion");

      final success = await ejemplarService.registroEjemplar(_nombre, _especie, _descripcion);

      if(success){
        // Regresar a la pantalla anterior después de guardar
        Navigator.pop(context);
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Ocurrio un error al registrar el ejemplar!",
            ),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Llama al método de sincronización automática cuando se inicie la pantalla
    ejemplarService.enviarEjemplaresPendientes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Registrar de Llama")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "Nombre del Ejemplar"),
                validator: (value) => value!.isEmpty ? "Ingrese un nombre" : null,
                onSaved: (value) => _nombre = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Especie"),
                validator: (value) => value!.isEmpty ? "Ingrese una especie" : null,
                onSaved: (value) => _especie = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Descripción"),
                validator: (value) => value!.isEmpty ? "Ingrese una descripción" : null,
                onSaved: (value) => _descripcion = value!,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarEjemplar,
                child: Text("Guardar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
