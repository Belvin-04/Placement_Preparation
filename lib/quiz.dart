import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Models/Question.dart';
import 'Models/Topic.dart';
import 'constants.dart';


class Quiz extends StatefulWidget{
  Topic topic;
  Quiz(this.topic);
  @override
  State<Quiz> createState()=>_QuizState();
}

class _QuizState extends State<Quiz>{
  int q = 0;
  //bool loaded;
  String btnText = "Next";
  late Future<List<Question>> questions;
  String selectedAnswer = "";
  bool check = false;

  bool stdAns = false;
  bool editable = true;

  TextEditingController answerController = TextEditingController();
  TextEditingController ratingController = TextEditingController();
  TextEditingController stdAnsController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    questions = getQuestions(widget.topic.getId);
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz"),

      ),
      body: Center(
        child: FutureBuilder(
          future: questions,
          builder: (context,snapshot){
            if(snapshot.hasData){
              var questionData = snapshot.data;
              if(questionData!.length == 1){
                btnText = "Submit";
              }
              if(q<snapshot.data!.length){
                stdAnsController.text = questionData![q].getCorrectAnswer;
              }

              return Constants.quizType == "MCQ"?Form(
                  child: Column(
                    children: [
                      Text("${q+1}.${questionData?[q].question}"),
                      ListView.builder(
                          shrinkWrap: true,
                          itemCount: questionData?[q].getOptions.length,
                          itemBuilder: (context, index) {
                            if(check){
                              if(questionData?[q].getOptions[index] == questionData?[q].getCorrectAnswer){
                                return RadioListTile(tileColor: Colors.green,title:Text(questionData![q].getOptions[index]),value: questionData?[q].getOptions[index], groupValue: selectedAnswer, onChanged: (val){
                                  setState(() {
                                    selectedAnswer = val!;
                                  });
                                });
                              }
                              else{
                                return RadioListTile(tileColor: Colors.red,title:Text(questionData![q].getOptions[index]),value: questionData?[q].getOptions[index], groupValue: selectedAnswer, onChanged: (val){
                                  setState(() {
                                    selectedAnswer = val!;
                                  });
                                });
                              }
                            }
                            else{
                              return RadioListTile(title:Text(questionData![q].getOptions[index]),value: questionData?[q].getOptions[index], groupValue: selectedAnswer, onChanged: (val){
                                setState(() {
                                  selectedAnswer = val!;
                                });
                              });
                            }
                          }),
                      Container(height: 10.0,),
                      ElevatedButton(onPressed: (){
                        setState(() {
                          check = true;
                        });
                      }, child: Text("Check")),
                      Container(height: 10.0,),
                      ElevatedButton(onPressed: (){

                        if(q+2 == questionData?.length){
                          setState(() {
                            check = false;
                            q = q+1;
                            btnText = "Submit";
                          });
                        }
                        else if(q+1 < questionData!.length){
                          setState(() {
                            check = false;
                            q = q+1;
                          });
                        }
                        else if(q+1 == questionData!.length){
                          Navigator.pop(context,1);
                        }
                      }, child: Text(btnText))
                    ],
                  )
              ):Form(
                key: _formKey,
                  child: Column(
                    children: [
                      Text("${q+1}.${questionData?[q].question}"),
                      TextFormField(
                        enabled: editable,
                        controller: answerController,
                        validator: (val){
                          if(val!.trim().isEmpty){
                            return "Please Enter Answer";
                          }
                        },
                        decoration: InputDecoration(
                          labelText: "Answer",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0)
                            )
                        ),

                      ),
                      Container(height: 10.0,),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        enabled: stdAns,
                        controller: ratingController,
                        validator: (val){
                          if(val!.trim().isEmpty){
                            return "Please Enter Rating";
                          }
                          else if(int.parse(val) < 0 || int.parse(val) > 10){
                            return "Rate between 1-10";
                          }
                        },
                        decoration: InputDecoration(
                          labelText: "Rating",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0)
                          )
                        ),
                      ),
                      Container(height: 10.0,),
                      Visibility(
                        visible: stdAns,
                        child: TextFormField(
                          enabled: false,
                          controller: stdAnsController,
                          decoration: InputDecoration(
                              labelText: "Standard Answer",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0)
                              )
                          ),
                        ),
                      ),
                      Container(height: 10.0,),
                      ElevatedButton(onPressed: (){
                        editable = false;
                        stdAns = true;
                        if(answerController.value.text.isEmpty){
                          Constants.showSnackBar("Please Type answer to verify", context);
                        }
                        else{
                          setState(() {

                          });
                        }

                      }, child: Text("Verify")),
                      Container(height: 10.0,),
                      ElevatedButton(onPressed: (){
                        editable = true;
                        stdAns = false;

                        if(_formKey.currentState!.validate()){
                          submitAnswer(questionData![q].getId);
                          answerController.text = "";
                          ratingController.text = "";
                          if(q+2 == questionData!.length){
                            print("q+2");
                            setState(() {
                              q = q+1;
                              btnText = "Submit";
                            });
                          }
                          else if(q+1 < questionData!.length){
                            print("q+1");
                            setState(() {
                              q = q+1;
                            });
                          }
                          else if(q+1 == questionData!.length){
                            print("q+1_1");
                            Navigator.pop(context,1);
                          }
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

  Future<List<Question>> getQuestions(int topicId) async {
    List<Question> questions = [];
    var url = Uri.http(Constants.baseURL, Constants.questionPath,
        {"t_id": "$topicId","type":Constants.quizType});

    print(url);
    var response = await http.get(url);

    if (response.statusCode != 204) {
      List b = jsonDecode(response.body)["body"];
      int total = jsonDecode(response.body)["total"];
      for (int i = 0; i < total; i++) {
        questions.add(Question.toQuestion(b[i], widget.topic));
      }
      return questions;
    }
    return questions;
  }

  submitAnswer(int id) async{
    var url = Uri.http(Constants.baseURL, Constants.questionPath);

    // Await the http get response, then decode the json-formatted response.
    var response = await http.post(url, body: {"question_id": id.toString(),"answer":answerController.value.text,"rating":ratingController.value.text,"id":Constants.userEmail});
    print(response.body);
  }
}






