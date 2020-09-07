import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/Cadastro.dart';
import 'package:whatsapp/Configuracoes.dart';
import 'package:whatsapp/Mensagens.dart';

import '../Home.dart';
import '../Login.dart';

class RouteGenerator{
  static Route<dynamic> generateRoute(RouteSettings settings){

    final args = settings.arguments;

    switch(settings.name){
      case "/":
         return MaterialPageRoute(
                builder: (context) => Login()
            );
        break;
      case "/login":
        return MaterialPageRoute(
            builder: (context) => Login()
        );
        break;
      case "/home":
        return MaterialPageRoute(
            builder: (context) => Home()
        );
        break;
      case "/cadastro":
        return MaterialPageRoute(
            builder: (context) => Cadastro()
        );
        break;

      case "/configuracoes":
        return MaterialPageRoute(
            builder: (context) => Configuracoes()
        );
        break;

      case "/mensagens":
        return MaterialPageRoute(
            builder: (context) => Mensagens(args)
        );
        break;


    }
  }
}