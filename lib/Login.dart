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
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(title: Center(child: Text("Login",style: TextStyle(fontSize: 40.0),)),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Center(
            child: Container(
              padding: EdgeInsets.all(100.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black)
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    keyboardType: TextInputType.number,
                    validator: (val){
                      if(val!.isEmpty){
                        return "Please Enter Enroll No. Or Faculty ID";
                      }
                    },
                    controller: emailController,
                    decoration: InputDecoration(
                    labelText: "Enroll | Faculty Id",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))
                  ),),
                  Container(margin: EdgeInsets.only(bottom: 10.0),),
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
                  Container(margin: EdgeInsets.only(bottom: 10.0),),
                  ElevatedButton(onPressed: () async {
                    if(_formKey.currentState!.validate()){
                       int code = await login(emailController.value.text,passwordController.value.text);
                       if(code == 404){
                         Constants.showSnackBar("User does not exist", context);
                       }
                       else{
                         Constants.userType = code;
                         Navigator.push(context, MaterialPageRoute(builder: (context)=>Topics()));
                       }
                    }
                  }, child: Text("Login"),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<int> login(String email, String password) async {
    var url = Uri.http(Constants.baseURL, Constants.studentPath);

    // Await the http get response, then decode the json-formatted response.
    var response = await http.post(url, body: {"email": email,"pswd":"${md5.convert(utf8.encode(password))}"});

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      Constants.userEmail = data["body"]["id"];

      if(data["body"]["user"] == "Faculty"){
        return 1;
      }
      else if(data["body"]["user"] == "Student"){
        return 2;
      }
      return 404;
    }
    else{
      return 404;
    }
  }
}
