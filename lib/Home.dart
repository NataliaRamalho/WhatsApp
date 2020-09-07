import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/telas/AbaContatos.dart';
import 'package:whatsapp/telas/AbaConversas.dart';

import 'Login.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin{
  TabController _tabController;

  List<String> _listaItemMenu = ["Configurações", "Deslogar"];

  _escolhaMenuItem(String escolha){
    switch(escolha){
      case "Configurações":
        Navigator.pushNamed(context, "/configuracoes");
        break;
      case "Deslogar":
        _deslogarUsuario();
        break;
    }
  }

  _deslogarUsuario() async{
    FirebaseAuth auth = FirebaseAuth.instance;
    auth.signOut();
    Navigator.pushReplacementNamed(context, "/login");
  }

  Future _estaLogado() async{
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser logado = await auth.currentUser();
    if( logado == null){
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  @override
  void initState() {
    super.initState();
    _estaLogado();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("WhatsApp"),
      bottom: TabBar(
        indicatorWeight: 4,
        labelStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold
        ),
        indicatorColor: Colors.white,
        controller: _tabController,
        tabs: <Widget>[
          Tab(text: "Conversas"),
          Tab(text: "Contatos"),
        ],
      ),
      actions: <Widget>[
        PopupMenuButton(
          onSelected: _escolhaMenuItem,
          itemBuilder: (contex){
            return _listaItemMenu.map((String item){
              return PopupMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList();
          },
        )
      ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          AbaConversas(),
          AbaContatos()
        ],

      ),
    );
  }
}

