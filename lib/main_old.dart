import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hello World App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HelloWorldPage(),
    );
  }
}

class HelloWorldPage extends StatelessWidget {
  const HelloWorldPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Aplicacao Flutter'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'esta é a v2 do Hello World!',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InserirPage(),
                  ),
                );
              },
              child: const Text('Inserir'),
            ),
          ],
        ),
      ),
    );
  }
}

// Tela de insercao de um novo registro em "vehicle_material_group".
// O campo "vehicle_material_group_identification" nao aparece aqui porque
// e gerado automaticamente pelo banco (AUTO_INCREMENT).
// As colunas dt_inclusao e dt_ultima_atualizacao tambem nao aparecem aqui:
// elas serao preenchidas automaticamente pelo backend (NOW()) no momento do insert.
class InserirPage extends StatefulWidget {
  const InserirPage({super.key});

  @override
  State<InserirPage> createState() => _InserirPageState();
}

class _InserirPageState extends State<InserirPage> {
  final TextEditingController _descricaoController = TextEditingController();

  @override
  void dispose() {
    _descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inserir novo grupo de material'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Descrição do grupo de material'),
            const SizedBox(height: 8),
            TextField(
              controller: _descricaoController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Digite a descrição aqui',
              ),
              maxLength: 250,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              // Por enquanto este botao ainda nao chama o backend.
              // A chamada HTTP para o inserir.php sera feita na proxima etapa.
              onPressed: () {},
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
