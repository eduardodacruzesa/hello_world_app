import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ATENCAO: ajuste esta URL para o endereco real da pasta "api" no seu
// provedor de hospedagem (a mesma pasta onde voce enviou listar.php,
// inserir.php, atualizar.php e excluir.php).
const String apiBaseUrl = 'https://projeto0007.agescape.com.br/api';

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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ConsultarPage(),
                      ),
                    );
                  },
                  child: const Text('Consultar'),
                ),
              ],
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
// elas sao preenchidas automaticamente pelo backend (NOW()) no momento do insert.
class InserirPage extends StatefulWidget {
  const InserirPage({super.key});

  @override
  State<InserirPage> createState() => _InserirPageState();
}

class _InserirPageState extends State<InserirPage> {
  final TextEditingController _descricaoController = TextEditingController();
  bool _salvando = false;

  @override
  void dispose() {
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final descricao = _descricaoController.text.trim();

    if (descricao.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite uma descrição antes de salvar')),
      );
      return;
    }

    setState(() {
      _salvando = true;
    });

    try {
      // Chamada HTTP POST para o inserir.php, que faz o INSERT no banco.
      final response = await http.post(
        Uri.parse('$apiBaseUrl/inserir.php'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({'vehicle_material_group_description': descricao}),
      );

      final resultado = jsonDecode(response.body);

      if (response.statusCode == 200 && resultado['sucesso'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Registro salvo com sucesso! ID: ${resultado['vehicle_material_group_identification']}',
            ),
          ),
        );
        Navigator.pop(context);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: ${resultado['erro'] ?? 'desconhecido'}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha na comunicação com o servidor: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _salvando = false;
        });
      }
    }
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
              onPressed: _salvando ? null : _salvar,
              child: _salvando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}

// Tela de consulta: lista todos os registros de "vehicle_material_group",
// exibindo todos os campos da tabela (identificacao, descricao e as duas datas).
class ConsultarPage extends StatefulWidget {
  const ConsultarPage({super.key});

  @override
  State<ConsultarPage> createState() => _ConsultarPageState();
}

class _ConsultarPageState extends State<ConsultarPage> {
  late Future<List<dynamic>> _registrosFuture;

  @override
  void initState() {
    super.initState();
    _registrosFuture = _carregarRegistros();
  }

  Future<List<dynamic>> _carregarRegistros() async {
    // Chamada HTTP GET para o listar.php, que faz o SELECT no banco.
    final response = await http.get(Uri.parse('$apiBaseUrl/listar.php'));

    if (response.statusCode != 200) {
      throw Exception('Erro HTTP ${response.statusCode} ao consultar os dados');
    }

    final decodificado = jsonDecode(response.body);

    if (decodificado is Map && decodificado.containsKey('erro')) {
      throw Exception(decodificado['erro']);
    }

    return decodificado as List<dynamic>;
  }

  void _recarregar() {
    setState(() {
      _registrosFuture = _carregarRegistros();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultar grupos de material'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _recarregar,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _registrosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Erro ao consultar os dados:\n${snapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _recarregar,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          final registros = snapshot.data ?? [];

          if (registros.isEmpty) {
            return const Center(child: Text('Nenhum registro encontrado'));
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Descrição')),
                  DataColumn(label: Text('Data inclusão')),
                  DataColumn(label: Text('Última atualização')),
                ],
                rows: registros.map((registro) {
                  return DataRow(cells: [
                    DataCell(Text('${registro['vehicle_material_group_identification']}')),
                    DataCell(Text('${registro['vehicle_material_group_description']}')),
                    DataCell(Text('${registro['dt_inclusao']}')),
                    DataCell(Text('${registro['dt_ultima_atualizacao']}')),
                  ]);
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
