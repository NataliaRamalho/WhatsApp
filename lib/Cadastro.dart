import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/model/Usuario.dart';

import 'Home.dart';

class Cadastro extends StatefulWidget {
  @override
  _CadastroState createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  TextEditingController _controllerNome = TextEditingController();
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  String _mensagemErro = "";

  _validarCampo(){
    String nome = _controllerNome.text;
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

    if(nome.isNotEmpty && email.isNotEmpty && senha.isNotEmpty){
      if(senha.length < 5){
        setState(() {
          _mensagemErro = "A senha deve ter no minimo 6 cacteres";
        });
      }
      else{
        setState(() {
          _mensagemErro = "";
        });
        Usuario usuario = new Usuario();
        usuario.nome = nome;
        usuario.email = email;
        usuario.senha = senha;
        _cadastrarUsuario(usuario);
      }
    }else{
      setState(() {
        _mensagemErro = "Todos os campos devem estar preenchidos";
      });
    }
  }

  _cadastrarUsuario(Usuario usuario){
    FirebaseAuth auth = FirebaseAuth.instance;
    auth.createUserWithEmailAndPassword(email: usuario.email, password: usuario.senha)
         .then((firebaseUser){
           Firestore db = Firestore.instance;
            db.collection("usuarios").document(firebaseUser.uid).setData(
              {
                "nome": usuario.nome,
                "email": usuario.email,
              }
            );
           Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
           })
        .catchError( (erro){
          setState(() {
           _mensagemErro = "Erro ao cadastrar verifique se os dados foram digitados corretamente";
         });});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cadastro"),),
      body: Container(
        decoration: BoxDecoration(color: Color(0Xff075E54)),
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 32),
                  child:
                  Image.asset("imagens/usuario.png",
                      width:200,
                      height: 150),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: TextField(
                    onSubmitted: (String texto){},
                    controller: _controllerNome,
                    autofocus: true,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: "Nome",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 12),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: TextField(
                    onSubmitted: (String texto){},
                    controller: _controllerEmail,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "E-mail",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 12),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: TextField(
                    onSubmitted: (String texto){},
                    controller: _controllerSenha,
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Senha",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 12),
                      filled: true,
                      fillColor: Colors.white,
                    ),

                  ),
                ),
                RaisedButton(
                  color: Colors.green,
                  child: Text("Cadastrar", style: TextStyle(color: Colors.white),),
                  onPressed:(){ _validarCampo();},
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                Center(
                  child: Text(_mensagemErro, style: TextStyle(color: Colors.red, fontSize: 20),textAlign: TextAlign.center,),
                )
              ],
            ),
          ),
        )
      ),
    );
  }
}
