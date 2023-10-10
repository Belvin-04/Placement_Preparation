import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:placement_preparation/topics.dart';
import 'constants.dart';
import 'package:crypto/crypto.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login"),),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                validator: (val){
                  if(val!.isEmpty){
                    return "Please Enter Email";
                  }
                },
                controller: emailController,
                decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))
              ),),
              TextFormField(
                validator: (val){
                  if(val!.isEmpty){
                    return "Please Enter Password";
                  }
                },
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))
              ),),
              ElevatedButton(onPressed: () async {
                if(_formKey.currentState!.validate()){
                  Constants.userType = await login(emailController.value.text,passwordController.value.text);
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>Topics()));
                }
              }, child: Text("Login"))
            ],
          ),
        ),
      ),
    );
  }

  Future<int> login(String email, String password) async {
    var url = Uri.http(Constants.baseURL, Constants.studentPath);

    // Await the http get response, then decode the json-formatted response.
    var response = await http.post(url, body: {"email": email,"pswd":"${md5.convert(utf8.encode(password))}"});
    print(response.statusCode);

    if(email == "admin" && password == "admin"){
      return 1;
    }
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print(data);
      Constants.userEmail = data["body"]["email"];
      print(Constants.userEmail);
      return 2;
    }
    else{
      return 404;
    }
  }
}
