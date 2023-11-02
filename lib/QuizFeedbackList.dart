import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:placement_preparation/Models/AnswerHistory.dart';
import 'package:placement_preparation/QuestionReview.dart';
import 'package:placement_preparation/constants.dart';
import 'package:http/http.dart' as http;

class QuizFeedbackList extends StatefulWidget {
  const QuizFeedbackList({super.key});

  @override
  State<QuizFeedbackList> createState() => _QuizFeedbackListState();
}

class _QuizFeedbackListState extends State<QuizFeedbackList> {
  String selectedVal = "Unchecked";
  late Future<List<AnswerHistory>?> checkedQuestions;
  late Future<List<AnswerHistory>?> uncheckedQuestions;

  @override
  void initState() {
    super.initState();
    checkedQuestions = (Constants.userType == 2)?getQuizFeedbackQuestions("Checked"):getQuizFeedbackQuestionsFaculty("Checked");
    uncheckedQuestions = (Constants.userType == 2)?getQuizFeedbackQuestions("Unchecked"):getQuizFeedbackQuestionsFaculty("Unchecked");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz Questions"),
      ),
      body: ListView(
        children: [
          Row(
            children: [
              Expanded(
                child: RadioListTile(title:Text("Unchecked"),value: "Unchecked", groupValue: selectedVal, onChanged: (val){
                  setState(() {
                    selectedVal = val!;
                  });
                }),
              ),
              Expanded(
                child: RadioListTile(title:Text("Checked"),value: "Checked", groupValue: selectedVal, onChanged: (val){
                  setState(() {
                    selectedVal = val!;
                  });
                }),
              )
            ],
          ),
          FutureBuilder(future: (selectedVal == "Unchecked")?uncheckedQuestions:checkedQuestions, builder: (context,snapshot){
            if(snapshot.hasData){
              return ListView.builder(
                shrinkWrap: true,
                  itemCount: snapshot.data?.length,itemBuilder: (context,index){
                return GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>QuestionReview(snapshot.data![index])));
                  },
                  child: Card(
                    child: ListTile(
                      leading: Text(snapshot.data![index].question),
                    ),
                  ),
                );
              });
            }
            else{
              return Center(child: Text("No Records"),);
            }
          })

        ],
      ),
    );
  }



  Future<List<AnswerHistory>?> getQuizFeedbackQuestions(String selectedVal) async {
    List<AnswerHistory> ans = [];
    var url = Uri.http(Constants.baseURL,Constants.questionPath,{"user":Constants.userEmail,"type":selectedVal});
    var response = await http.get(url);

    if(response.statusCode == 200){
      int total = jsonDecode(response.body)["total"];
      var data = jsonDecode(response.body)["body"];
      for(int i=0; i<total; i++){
        data[i]["studentName"] = Constants.userName;
        data[i]["studentId"] = Constants.userEmail;
        ans.add(AnswerHistory.toAnswerHistory(data[i]));
      }

      return ans;
    }
    return null;
  }

  Future<List<AnswerHistory>?> getQuizFeedbackQuestionsFaculty(String s) async {
    List<AnswerHistory> ans = [];
    var url = Uri.http(Constants.baseURL,Constants.questionPath,{"student":Constants.studentNo,"type":selectedVal,"userType":"Faculty"});
    var response = await http.get(url);

    if(response.statusCode == 200){
      int total = jsonDecode(response.body)["total"];
      var data = jsonDecode(response.body)["body"];
      for(int i=0; i<total; i++){
        data[i]["studentId"] = Constants.studentNo;
        data[i]["studentName"] = Constants.studentName;
        data[i]["facultyName"] = Constants.userName;
        data[i]["feedback"] = "0";
        data[i]["facultyReview"] = "";
        ans.add(AnswerHistory.toAnswerHistory(data[i]));
      }

      return ans;
    }
    return null;
  }
}
