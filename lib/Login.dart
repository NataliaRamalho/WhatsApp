import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/Cadastro.dart';

import 'Home.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
   TextEditingController _controllerEmail = TextEditingController();
   TextEditingController _controllerSenha = TextEditingController();
   String _mensagemErro = "";

    _validarLogin() async{
      if(_controllerSenha.text.isNotEmpty && _controllerEmail.text.isNotEmpty){
        _logarUsuario();
      }
      else{
        setState(() {
          _mensagemErro = "Todos os campos devem estar preenchidos";
        });
      }
   }

   _logarUsuario(){
     FirebaseAuth auth = FirebaseAuth.instance;
     auth.signInWithEmailAndPassword(
         email: _controllerEmail.text,
         password: _controllerSenha.text).
     then((firebaseUser){
        Navigator.pushReplacementNamed(context, "/home");
       }).
     catchError((erro){
       setState(() {
         _mensagemErro = "Senha ou usuário incorreto";
       });
     });
   }

   Future _estaLogado() async{
     FirebaseAuth auth = FirebaseAuth.instance;
     FirebaseUser logado = await auth.currentUser();
     if( logado != null){
       Navigator.pushReplacementNamed(context, "/home");
     }
   }
   @override
  void initState() {
     _estaLogado();
      super.initState();
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Color(0Xff075E54)),
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child:
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 32),
                  child: Image.asset(
                      "imagens/logo.png",
                      width:200,
                      height: 150),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child:TextField(
                    autofocus: true,
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
                    controller: _controllerEmail,
                    onSubmitted: (String texto) {},
                  ),
                ),
                TextField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      labelText: "Senha",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32)),
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 12),
                      filled: true,
                      fillColor: Colors.white,
                  ),
                  controller: _controllerSenha,
                  onSubmitted: (String texto) {},
                  obscureText: true,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 10),
                  child: RaisedButton(
                    color: Colors.green,
                    child: Text(
                        "Entrar",
                        style: TextStyle(color: Colors.white, fontSize: 20)),
                    onPressed: (){
                      _validarLogin();
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                ),
                Center(
                  child: GestureDetector(
                    child: Text("Não tem conta?, cadastre-se!", style: TextStyle(color: Colors.white),),
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) => Cadastro()
                      ));
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child:Center(
                    child: Text(_mensagemErro, style: TextStyle(color: Colors.red, fontSize: 20),textAlign: TextAlign.center,),
                  ),
                )
              ],
            ),
          ),
        ),
      )
    );
  }
}
