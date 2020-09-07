import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatsapp/model/Usuario.dart';
import 'model/Conversa.dart';
import 'model/Mensagem.dart';

class Mensagens extends StatefulWidget {
  Usuario contato; //DESTINATARIO
  Mensagens(this.contato);
  @override
  _MensagensState createState() => _MensagensState();
}

class _MensagensState extends State<Mensagens> {
  TextEditingController _controllerMensagem = TextEditingController();
  String _idUsuarioLogado;
  String _idUsuarioDestinatario;
  Firestore db = Firestore.instance;
  File _imagem;
  bool _subindoImagem = false;
  final _controller = StreamController<QuerySnapshot>.broadcast();
  ScrollController  _scrollController = ScrollController();
  Map<String,dynamic> _dadosUsuarioLogado;


  _enviarMensagem() {
    String textoMensagem = _controllerMensagem.text;
    if (textoMensagem.isNotEmpty) {
      Mensagem mensagem = Mensagem();
      mensagem.idUsuario = _idUsuarioLogado;
      mensagem.mensagem = textoMensagem;
      mensagem.urlImagem = "";
      mensagem.tipo = "texto";
      mensagem.data = Timestamp.now().toString();

      // SALVANDO PARA O REMETENTE
      _salvarMensagem(_idUsuarioLogado, _idUsuarioDestinatario, mensagem);

      //SALVANDO PARA O DESTINÁTARIO
      _salvarMensagem(_idUsuarioDestinatario, _idUsuarioLogado, mensagem);

      //Salvar conversa
      _salvarConvesa(mensagem);
    }
  }

  _salvarConvesa(Mensagem msg){
   Conversa cRemetente = Conversa();
   cRemetente.idRemetente = _idUsuarioLogado;
   cRemetente.idDestinatario = _idUsuarioDestinatario;
   cRemetente.mensagem = msg.mensagem;
   cRemetente.nome = widget.contato.nome; //nome do destinatario
   cRemetente.caminhoFoto = widget.contato.urlImagem; //foto destinatario
   cRemetente.tipoMensagem = msg.tipo;
   cRemetente.salvar();


   Conversa cDestinatario = Conversa();
   cDestinatario.idRemetente = _idUsuarioDestinatario;
   cDestinatario.idDestinatario = _idUsuarioLogado;
   cDestinatario.mensagem = msg.mensagem;
   cDestinatario.nome = _dadosUsuarioLogado["nome"];  // nome do remetente
   cDestinatario.caminhoFoto = _dadosUsuarioLogado["urlImagem"];  //foto remetente
   cDestinatario.tipoMensagem = msg.tipo;
   cDestinatario.salvar();
  }

  _salvarMensagem(
      String idRemetente, String idDestinatario, Mensagem msg) async {
    await db
        .collection("mensagens")
        .document(idRemetente)
        .collection(idDestinatario)
        .add(msg.toMap());
    _controllerMensagem.clear();
  }

  _enviarFoto() async{
    File imagemSelecionada;
    imagemSelecionada = await ImagePicker.pickImage(source: ImageSource.gallery);
    _subindoImagem = true;
    _uploadImagem(imagemSelecionada);
  }

  _uploadImagem(File imagemSelecionada) async {
    String nomeImagem = DateTime.now().millisecondsSinceEpoch.toString();
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();
    StorageReference arquivo = pastaRaiz
        .child("mensagens")
        .child(_idUsuarioLogado)
        .child( nomeImagem +".jpg");

    StorageUploadTask task = arquivo.putFile(imagemSelecionada);

    task.events.listen((StorageTaskEvent storageEvent){
      if( storageEvent.type == StorageTaskEventType.progress ){
        setState(() {
          _subindoImagem = true;
        });
      }else if( storageEvent.type == StorageTaskEventType.success ){
        setState(() {
          _subindoImagem = false;
        });
      }
    });
    task.onComplete.then((StorageTaskSnapshot snapshot){
      _recuperarUrlImagem(snapshot);
    });
  }

  Future _recuperarUrlImagem(StorageTaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();

    Mensagem mensagem = Mensagem();
    mensagem.idUsuario = _idUsuarioLogado;
    mensagem.mensagem = "";
    mensagem.urlImagem = url;
    mensagem.tipo = "imagem";
    mensagem.data = Timestamp.now().toString();//marco temporal

    // SALVANDO PARA O REMETENTE
    _salvarMensagem(_idUsuarioLogado, _idUsuarioDestinatario, mensagem);

    //SALVANDO PARA O DESTINÁTARIO
    _salvarMensagem(_idUsuarioDestinatario, _idUsuarioLogado, mensagem);

    //Salvar conversa
    _salvarConvesa(mensagem);
  }


  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    _idUsuarioLogado = usuarioLogado.uid;
    _idUsuarioDestinatario = widget.contato.idUsuario;

    Firestore db = Firestore.instance;
    DocumentSnapshot snaphot =  await db.collection("usuarios").document(_idUsuarioLogado).get();
    if(snaphot.data.isNotEmpty){
      _dadosUsuarioLogado = snaphot.data;
    }
    _adicionarListenerMensagens();
  }

  Stream<QuerySnapshot> _adicionarListenerMensagens() {
    final stream = db.collection("mensagens")
        .document(_idUsuarioLogado)
        .collection(_idUsuarioDestinatario)
        .orderBy("data", descending: false)
        .snapshots();

    stream.listen((dados) {
      _controller.add(dados);
      Timer(Duration(seconds: 1), (){
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);// max final da lista
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    var _caixaMensagem = Container(
      padding: EdgeInsets.all(18),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 8),
              child: TextField(
                controller: _controllerMensagem,
                autofocus: true,
                keyboardType: TextInputType.text,
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                    hintText: "Digite uma mensagem.....",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32)
                    ),
                    suffixIcon: _subindoImagem ?
                    CircularProgressIndicator() :
                    IconButton(
                      icon: Icon(Icons.camera_alt),
                      onPressed: _enviarFoto,
                    ),
                  prefixIcon: IconButton(
                    icon: Icon(Icons.insert_emoticon),
                    onPressed: (){},
                  )
                ),
              ),
            ),
          ),
          FloatingActionButton(
            backgroundColor: Color(0xff075E54),
            child: Icon(
              Icons.send,
              color: Colors.white,
            ),
            mini: true,
            onPressed: _enviarMensagem,
          )
        ],
      ),
    );

    var _stream = StreamBuilder(
        stream: _controller.stream,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Column(
                  children: <Widget>[
                    Text("Carregando conversas"),
                    CircularProgressIndicator()
                  ],
                ),
              );
              break;
            case ConnectionState.active:
            case ConnectionState.done:
              QuerySnapshot querySnapshot = snapshot.data;
              if (snapshot.hasError) {
                return Text("Erro ao carregar dados");
              } else {
                return Expanded(
                  child: ListView.builder(
                      controller: _scrollController,
                      itemCount: querySnapshot.documents.length,
                      itemBuilder: (context, indice) {
                        List<DocumentSnapshot> mensagens = querySnapshot.documents.toList();
                        DocumentSnapshot item = mensagens[indice];

                        double larguraContainer = MediaQuery.of(context).size.width * 0.8;
                        Alignment alinhamento = Alignment.centerRight;
                        Color cor = Color(0xffd2ffa5);
                        if (item["idUsuario"] != _idUsuarioLogado) {
                          alinhamento = Alignment.bottomLeft;
                          cor = Colors.white;
                        }
                        return Align(
                          alignment: alinhamento,
                          child: Padding(
                            padding: EdgeInsets.all(6),
                            child: Container(
                              width: larguraContainer,
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                  color: cor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8))),
                              child:
                              item["tipo"] == "texto" ?
                              Text(
                                item["mensagem"],
                                style: TextStyle(fontSize: 18),
                              ) : Image.network(item["urlImagem"]),
                            ),
                          ),
                        );
                      }),
                );
              }
              break;
          }
        });

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            CircleAvatar(
                maxRadius: 30,
                backgroundColor: Colors.grey,
                backgroundImage: widget.contato.urlImagem != null
                    ? NetworkImage(widget.contato.urlImagem)
                    : null),
            Padding(
              padding: EdgeInsets.only(left: 6),
              child: Text(widget.contato.nome),
            ),
          ],
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("imagens/bg.png"), fit: BoxFit.cover),
        ),
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.all(8),
            child: Column(
              children: <Widget>[
                _stream,
                _caixaMensagem,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
