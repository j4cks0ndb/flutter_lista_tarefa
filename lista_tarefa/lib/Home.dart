import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List _listaTarefas = [];
  TextEditingController _controllerTarefa = TextEditingController();

  Future<File> _getFile() async {
    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path}/dados.json");
  }

  _salvarArquivo() async {

    var arquivo =  await _getFile();

    String dados = json.encode(_listaTarefas);
    arquivo.writeAsString(dados);
    //print("Caminho: " + diretorio.path);
  }

  _lerArquivo() async {
    try{
      final arquivo =  await _getFile();
      return arquivo.readAsString();
    }catch(e){
      return null;
    }
  }
  _salvarTarefa(){
    String textoDigitado = _controllerTarefa.text;

    //Criar os dados
    Map<String,dynamic> tarefa = Map();
    tarefa["titulo"] = textoDigitado;
    tarefa["realizada"] = false;
    setState(() {
      _listaTarefas.add(tarefa);
    });

    _controllerTarefa.text = "";

    _salvarArquivo();
  }

  Widget criarItemLista(context, index){
    final item = _listaTarefas[index]["titulo"]+"_"+index.toString()+"_"+DateTime.now().millisecondsSinceEpoch.toString();
    return Dismissible(
      key: Key(item),
      onDismissed: (direction){

        Map<String,dynamic> ultimaTarefaRemovida = Map();


        ultimaTarefaRemovida = _listaTarefas[index];

        setState(() {
          _listaTarefas.removeAt(index);
        });
        _salvarArquivo();

        final snackbar = SnackBar(
          backgroundColor: Colors.green,
          duration: Duration(seconds: 5),
          content: Text("Tarefa Removida"),
          action: SnackBarAction(
            label: "Desfazer",
            onPressed: (){
              setState(() {
                _listaTarefas.insert(index,ultimaTarefaRemovida);
              });
              _salvarArquivo();
            },
          ),
        );

        Scaffold.of(context).showSnackBar(snackbar);

      },
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(
              Icons.delete_sweep,
              color: Colors.white,
            )
          ],
        ),
      ),
      child: CheckboxListTile(
        title: Text(_listaTarefas[index]["titulo"]),
        value: _listaTarefas[index]["realizada"],
        onChanged: (valorAlterado){
          setState(() {
            _listaTarefas[index]["realizada"] = valorAlterado;
          });
          _salvarArquivo();
        },
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _lerArquivo().then((dados){
      setState(() {
        _listaTarefas = json.decode(dados);
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.purple,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          showDialog(
              context: context,
            builder: (context){
                return AlertDialog(
                  title: Text("Adicionar Tarefa"),
                  content: TextField(
                    controller: _controllerTarefa,
                    decoration: InputDecoration(
                      labelText: "Digite sua terefa"
                    ),
                    onChanged: (text){

                    },
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("Cancelar"),
                      onPressed: (){
                         Navigator.pop(context);
                      },
                    ),
                    FlatButton(
                      child: Text("Salvar"),
                      onPressed: (){
                        _salvarTarefa();
                         Navigator.pop(context);
                      },
                    )
                  ],
                );
            }
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _listaTarefas.length ,
              itemBuilder: criarItemLista
            ),
          )
        ],
      ),
    );
  }
}
