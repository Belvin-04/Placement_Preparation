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
  bool loaded = false;
  String btnText = "Next";
  List<Question> questions = [];
  String selectedAnswer = "";
  bool check = false;
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz"),
      ),
      body: Center(
        child: FutureBuilder(
          future: getQuestions(widget.topic.getId),
          builder: (context,snapshot){
            if(snapshot.hasData && !loaded){
              questions = snapshot.data!;
              return Form(
                  child: Column(
                    children: [
                      Text("${q+1}.${questions[q].question}"),
                      ListView.builder(
                          shrinkWrap: true,
                          itemCount: questions[q].getOptions.length,
                          itemBuilder: (context, index) {
                            if(check){
                              if(questions[q].getOptions[index] == questions[q].getCorrectAnswer){
                                return RadioListTile(tileColor: Colors.green,title:Text(questions[q].getOptions[index]),value: questions[q].getOptions[index], groupValue: selectedAnswer, onChanged: (val){
                                  setState(() {
                                    selectedAnswer = val!;
                                  });
                                });
                              }
                              else{
                                return RadioListTile(tileColor: Colors.red,title:Text(questions[q].getOptions[index]),value: questions[q].getOptions[index], groupValue: selectedAnswer, onChanged: (val){
                                  setState(() {
                                    selectedAnswer = val!;
                                  });
                                });
                              }
                            }
                            else{
                              return RadioListTile(title:Text(questions[q].getOptions[index]),value: questions[q].getOptions[index], groupValue: selectedAnswer, onChanged: (val){
                                setState(() {
                                  selectedAnswer = val!;
                                });
                              });
                            }
                          }),
                      ElevatedButton(onPressed: (){
                        setState(() {
                          check = true;
                        });
                      }, child: Text("Check")),
                      ElevatedButton(onPressed: (){
                        if(q+2 == questions.length){
                          setState(() {
                            check = false;
                            q = q+1;
                            btnText = "Submit";
                          });
                        }
                        else if(q+1 < questions.length){
                          setState(() {
                            check = false;
                            q = q+1;
                          });
                        }
                        else if(q+1 == questions.length){
                          Navigator.pop(context);
                        }
                      }, child: Text(btnText))
                    ],
                  )
              );
            }
            else if(loaded){
              return Form(
                  child: Column(
                    children: [
                      Text("${q+1}.${questions[q].question}"),
                      ListView.builder(
                          shrinkWrap: true,
                          itemCount: questions[q].getOptions.length,
                          itemBuilder: (context, index) {
                            if(check){
                              if(questions[q].getOptions[index] == questions[q].getCorrectAnswer){
                                return RadioListTile(tileColor: Colors.green,title:Text(questions[q].getOptions[index]),value: questions[q].getOptions[index], groupValue: selectedAnswer, onChanged: (val){
                                  setState(() {
                                    selectedAnswer = val!;
                                  });
                                });
                              }
                              else{
                                return RadioListTile(tileColor: Colors.red,title:Text(questions[q].getOptions[index]),value: questions[q].getOptions[index], groupValue: selectedAnswer, onChanged: (val){
                                  setState(() {
                                    selectedAnswer = val!;
                                  });
                                });
                              }
                            }
                            else{
                              return RadioListTile(title:Text(questions[q].getOptions[index]),value: questions[q].getOptions[index], groupValue: selectedAnswer, onChanged: (val){
                                setState(() {
                                  selectedAnswer = val!;
                                });
                              });
                            }
                          }),
                      ElevatedButton(onPressed: (){
                        setState(() {
                          check = true;
                        });
                      }, child: Text("Check")),
                      ElevatedButton(onPressed: (){
                        if(q+2 == questions.length){
                          setState(() {
                            check = false;
                            q = q+1;
                            btnText = "Submit";
                          });
                        }
                        else if(q+1 < questions.length){
                          setState(() {
                            check = false;
                            q = q+1;
                          });
                        }
                        else if(q+1 == questions.length){
                          Navigator.pop(context);
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

  Future<List<Question>?> getQuestions(int topicId) async {
    List<Question> questions = [];
    var url = Uri.http(Constants.baseURL, Constants.questionPath,
        {"t_id": "$topicId","type":"MCQ"});

    print(url);
    var response = await http.get(url);

    if (response.statusCode != 204) {
      List b = jsonDecode(response.body)["body"];
      int total = jsonDecode(response.body)["total"];
      for (int i = 0; i < total; i++) {
        questions.add(Question.toQuestion(b[i], widget.topic));
      }


      return questions;
    } else {
      return null;
    }
  }
}


/*

Form(
                child: Column(
                  children: [
                    Text("${q+1}.${questions[q].question}"),
                    TextFormField(),
                    TextFormField(),
                    ElevatedButton(onPressed: (){
                      if(q+2 == questions.length){
                        setState(() {
                          q = q+1;
                          btnText = "Submit";
                        });
                      }
                      else if(q+1 < questions.length){
                        setState(() {
                          q = q+1;
                        });
                      }
                      else if(q+1 == questions.length){
                        Navigator.pop(context);
                      }
                    }, child: Text(btnText))
                  ],
                )
              );
            }
            else if(loaded){
              return Form(
                  child: Column(
                    children: [
                      Text("${q+1}.${questions[q].question}"),
                      TextFormField(),
                      TextFormField(),
                      ElevatedButton(onPressed: (){
                        if(q+2 == questions.length){
                          setState(() {
                            q = q+1;
                            btnText = "Submit";
                          });
                        }
                        else if(q+1 < questions.length){
                          setState(() {
                            q = q+1;
                          });
                        }
                        else if(q+1 == questions.length){
                          Navigator.pop(context);
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


 */
