import 'package:cloud_firestore/cloud_firestore.dart';

class Conversa{
  String _idRemetente;
  String _idDestinatario;
  String _nome;
  String _caminhoFoto;
  String _mensagem;
  String _tipoMensagem;

  Conversa();

  salvar() async{
    Firestore db = Firestore.instance;
    await db.collection("conversas")
        .document(this.idRemetente)
        .collection("ultima_conversa")
        .document(this.idDestinatario)
        .setData(this.toMap());
  }

  Map<String,dynamic> toMap(){
    Map<String,dynamic> map = {
      "idRemetente" : this.idRemetente,
      "idDestinatario" : this.idDestinatario,
      "nome": this.nome,
      "caminhoFoto" : this.caminhoFoto,
      "mensagem": this.mensagem,
      "tipoMensagem": this.tipoMensagem,
    };
    return map;
  }


  String get mensagem => _mensagem;

  set mensagem(String value) {
    _mensagem = value;
  }

  String get caminhoFoto => _caminhoFoto;

  set caminhoFoto(String value) {
    _caminhoFoto = value;
  }

  String get nome => _nome;

  set nome(String value) {
    _nome = value;
  }

  String get tipoMensagem => _tipoMensagem;

  set tipoMensagem(String value) {
    _tipoMensagem = value;
  }

  String get idDestinatario => _idDestinatario;

  set idDestinatario(String value) {
    _idDestinatario = value;
  }

  String get idRemetente => _idRemetente;

  set idRemetente(String value) {
    _idRemetente = value;
  }
}