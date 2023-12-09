import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:placement_preparation/Models/AnswerHistory.dart';

import 'Models/Question.dart';
import 'constants.dart';
import 'package:http/http.dart' as http;

class FacultyReview extends StatefulWidget{
  Question q;
  FacultyReview(this.q);
  @override
  State<FacultyReview> createState() => _FacultyReviewState();
}

class _FacultyReviewState extends State<FacultyReview>{
  int q = 0;
  //bool loaded;
  String btnText = "Next";
  late Future<List<AnswerHistory>> responses;


  TextEditingController answerController = TextEditingController();
  TextEditingController ratingController = TextEditingController();
  TextEditingController stdAnsController = TextEditingController();
  TextEditingController studentNameController = TextEditingController();

  TextEditingController facultyRatingController = TextEditingController();
  TextEditingController facultyFeedbackController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    responses = getResponses(widget.q.getId);
    getStandardAnswer();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(
        title: Text("Review"),

      ),
      body: Center(
          child: FutureBuilder(
            future: responses,
            builder: (context,snapshot){
              if(snapshot.hasData){
                var questionData = snapshot.data;
                if(questionData!.length == 1){
                  btnText = "Submit";
                }
                if(q==0){
                  stdAnsController.text = widget.q.getCorrectAnswer;
                  answerController.text = snapshot.data?[0].answer;
                  studentNameController.text = snapshot.data![0].studentName;
                  ratingController.text = snapshot.data![0].userRating.toString();
                }

                return Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        Text(widget.q.getQuestion,style: TextStyle(fontSize: 20.0),),
                        Container(height: 10.0,),
                        TextFormField(
                          style: TextStyle(color: Colors.black),
                          enabled: false,
                          controller: studentNameController,
                          decoration: InputDecoration(
                              labelText: "Student Name",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0)
                              )
                          ),

                        ),
                        Container(height: 10.0,),
                        TextFormField(
                          style: TextStyle(color: Colors.black),
                          enabled: false,
                          maxLines: 6,
                          controller: stdAnsController,
                          decoration: InputDecoration(
                              labelText: "Standard Answer",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0)
                              )
                          ),
                        ),
                        Container(height: 10.0,),
                        TextFormField(
                          style: TextStyle(color: Colors.black),
                          enabled: false,
                          maxLines: 6,
                          controller: answerController,
                          decoration: InputDecoration(
                              labelText: "Answer",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0)
                              )
                          ),

                        ),
                        Container(height: 10.0,),
                        TextFormField(
                          style: TextStyle(color: Colors.black),
                          enabled: false,
                          controller: ratingController,
                          decoration: InputDecoration(
                              labelText: "Rating",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0)
                              )
                          ),
                        ),
                        Container(height: 10.0,),

                        TextFormField(
                          style: TextStyle(color: Colors.black),
                          keyboardType: TextInputType.number,
                          controller: facultyRatingController,
                          validator: (val){
                            if(val!.trim().isEmpty){
                              return "Please Enter Rating";
                            }
                            else if(int.parse(val) < 0 || int.parse(val) > 10){
                              return "Rate between 1-10";
                            }
                          },
                          decoration: InputDecoration(
                              labelText: "Faculty Rating",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0)
                              )
                          ),
                        ),
                        Container(height: 10.0,),
                        TextFormField(
                          style: TextStyle(color: Colors.black),
                          controller: facultyFeedbackController,
                          validator: (val){
                            if(val!.trim().isEmpty){
                              return "Please Feedback";
                            }
                          },
                          decoration: InputDecoration(
                              labelText: "Feedback",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0)
                              )
                          ),
                        ),
                        Container(height: 10.0,),


                        ElevatedButton(onPressed: (){
                          if(_formKey.currentState!.validate()){
                            submitFeedback(snapshot.data![q].id);
                            if(q+2 == questionData!.length){
                                q = q+1;
                                btnText = "Submit";

                            }
                            else if(q+1 < questionData!.length){
                                q = q+1;

                            }
                            else if(q+1 == questionData!.length){
                              Navigator.pop(context,1);
                            }
                            setState(() {
                              answerController.text = snapshot.data?[q].answer;
                              studentNameController.text = snapshot.data![q].studentName;
                              ratingController.text = snapshot.data![q].userRating.toString();

                              facultyFeedbackController.text = "";
                              facultyRatingController.text = "";
                            });

                          }
                        }, child: Text(btnText))
                      ],
                    )
                );
              }
              else{
                return CircularProgressIndicator();
              }
            },
          )
      ),
    );
  }

  Future<List<AnswerHistory>> getResponses(int questionId) async {
    List<AnswerHistory> answers = [];
    var url = Uri.http(Constants.baseURL, Constants.checkPath, {"check": "1","faculty_id":Constants.userEmail,"questionId":questionId.toString()});
    var response = await http.get(url);


    if (response.statusCode != 204) {
      List b = jsonDecode(response.body)["body"];
      int total = jsonDecode(response.body)["total"];
      for (int i = 0; i < total; i++) {
        answers.add(AnswerHistory.toAnswerHistory(b[i]));
      }
      return answers;
    }
    return answers;
  }

  void getStandardAnswer() async{
    var url = Uri.http(Constants.baseURL, Constants.questionPath,{"standardAnswer":widget.q.getId.toString()});

    var response = await http.get(url);
    if(response.statusCode == 200){
      var data = jsonDecode(response.body);
      var data1 = data["body"];
      String correct = data1["correctAnswer"];
      setState(() {
        widget.q.setCorrectAnswer = correct;
      });

    }

  }

  submitFeedback(int id) async{
    var url = Uri.http(Constants.baseURL,Constants.checkPath);
    var response = http.post(url,body: {"id":id.toString(),"faculty_id":Constants.userEmail,"faculty_rating":facultyRatingController.value.text,
      "faculty_feedback":facultyFeedbackController.value.text});
  }
}