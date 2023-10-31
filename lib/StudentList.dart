import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:placement_preparation/QuizFeedbackList.dart';
import 'package:placement_preparation/constants.dart';
import 'package:http/http.dart' as http;
import 'Models/AnswerHistory.dart';

class StudentList extends StatefulWidget {
  int sem;
  StudentList(this.sem);

  @override
  State<StudentList> createState() => _StudentListState();
}

class _StudentListState extends State<StudentList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Students"),
      ),
      body: FutureBuilder(future: getStudentList(), builder: (context,snapshot){
        if(snapshot.hasData){
          return ListView.builder(itemCount: snapshot.data!.length,itemBuilder: (context,index){
            return GestureDetector(
              onTap: (){
                Constants.studentNo = snapshot.data![index]["id"];
                Constants.studentName = snapshot.data![index]["name"];
                Navigator.push(context, MaterialPageRoute(builder: (context)=>QuizFeedbackList()));
              },
              child: Card(
                child: ListTile(
                  leading: Text(snapshot.data![index]["name"]),
                ),
              ),
            );
          });
        }
        else{
          return Center(child: Text("No Records"),);
        }
      }),
    );
  }

  Future<AnswerHistory?> getQuestions() async{
    var url = Uri.http(Constants.baseURL,Constants.questionPath,{"allQuestions":"true","sem":widget.sem.toString()});
    var response = await http.get(url);
  }

  Future<List<Map<String,dynamic>>?> getStudentList() async{
    List<Map<String,dynamic>> list = [];
    var url = Uri.http(Constants.baseURL,Constants.studentPath,{"sem":widget.sem.toString(),"course":Constants.courseType});
    var response = await http.get(url);

    if(response.statusCode == 200){
      var total = jsonDecode(response.body)["total"];
      var data = jsonDecode(response.body)["body"];

      for(int i=0; i<total; i++){
        list.add(data[i]);
      }
      return list;
    }
    else{
      print(response.body);
    }
    return null;

  }
}
