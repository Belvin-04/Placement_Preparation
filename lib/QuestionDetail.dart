import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:placement_preparation/Models/Question.dart';

import 'package:http/http.dart' as http;
import 'constants.dart';

enum Type { mcq, written }

class QuestionDetail extends StatefulWidget {
  Question question;

  QuestionDetail(this.question, {super.key});

  @override
  State<QuestionDetail> createState() => _QuestionDetailState();
}

class _QuestionDetailState extends State<QuestionDetail> {
  late String correctOption;
  bool visible = false;
  Type selectedValue = Type.written;
  late List<String> options;


  TextEditingController questionController = TextEditingController();
  TextEditingController optionController = TextEditingController();
  TextEditingController levelController = TextEditingController();
  TextEditingController standardAnswerController = TextEditingController();


  final _formKey = GlobalKey<FormState>();
  final _optionKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    questionController.text = widget.question.getQuestion;
    levelController.text = widget.question.getLevel.toString();
     correctOption = widget.question.getCorrectAnswer;
    options = widget.question.getOptions;

    if(widget.question.getType == "MCQ"){
      selectedValue = Type.mcq;
      visible = true;
      getOptions(widget.question);
    }
    else{
      getStandardAnswer();
    }
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        Navigator.pop(context,1);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Question Detail"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    onChanged: (val){
                      widget.question.setQuestion = val;
                    },
                    validator: (val){
                      if(val!.isEmpty){
                        return "Please enter Question";
                      }
                      return null;
                    },
                    controller: questionController,
                    decoration: InputDecoration(
                        labelText: "Question",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0))),
                  ),
                  Container(margin: EdgeInsets.only(bottom: 10.0),),
                  TextFormField(
                    onChanged: (val){
                      if(val.isNotEmpty){
                        int level = int.parse(val);
                        widget.question.setLevel = level;
                      }
                      else{
                        widget.question.setLevel = 0;
                      }
                    },
                    validator: (val){
                      if(val!.isEmpty){
                        return "Please enter Level";
                      }
                      return null;
                    },
                    controller: levelController,
                    decoration: InputDecoration(
                        labelText: "Level",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0))),
                  ),
                  Container(margin: EdgeInsets.only(bottom: 10.0),),
                  Visibility(
                    visible: !visible,
                    child: TextFormField(
                      onChanged: (val){
                          widget.question.correctAnswer = val;
                          print(widget.question.getCorrectAnswer);
                      },
                      validator: (val){
                        if(val!.isEmpty){
                          return "Please enter a standard answer";
                        }
                        return null;
                      },
                      controller: standardAnswerController,
                      decoration: InputDecoration(
                          labelText: "Standard Answer",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0))),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: RadioListTile(
                            tileColor: Colors.grey[300],
                            title: Text("MCQ"),
                            value: Type.mcq,
                            groupValue: selectedValue,
                            onChanged: (val) {
                              setState(() {
                                widget.question.setType = "MCQ";
                                selectedValue = val!;
                                visible = true;
                              });
                            }),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 10.0),
                      ),
                      Expanded(
                        child: RadioListTile(
                            tileColor: Colors.grey[300],
                            title: Text("Written"),
                            value: Type.written,
                            groupValue: selectedValue,
                            onChanged: (val) {
                              setState(() {
                                widget.question.setType = "WRITTEN";
                                selectedValue = val!;
                                visible = false;
                              });
                            }),
                      ),
                    ],
                  ),
                  Visibility(
                      visible: visible,
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: widget.question.getOptions.length,
                          itemBuilder: (context, index) {
                            return Row(
                              children: [
                                Expanded(
                                  flex:10,
                                  child: RadioListTile(title:Text(options[index]),value: options[index], groupValue: correctOption, onChanged: (val){
                                    setState(() {
                                      correctOption = val!;
                                      widget.question.setCorrectAnswer = val;
                                    });
                                  },),
                                ),
                                Expanded(
                                  flex:1,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Expanded(
                                          child:IconButton(icon: Icon(Icons.edit),color: Colors.blue, onPressed: () {
                                            showUpdateOptionDialog(options[index],index);
                                          },)
                                      ),
                                      Expanded(
                                          child:IconButton(icon: Icon(Icons.delete),color: Colors.red, onPressed: () {
                                            setState(() {
                                              options.removeAt(index);
                                            });
                                          },)
                                      )
                                    ],
                                  ),
                                )
                              ],
                            );
                          })),
                  Container(margin: EdgeInsets.only(bottom: 10.0),),
                  Visibility(visible: visible,child: ElevatedButton(child: Text("Add Option"),onPressed: (){
                    showAddOptionDialog("");
                  },)),
                  Container(margin: EdgeInsets.only(bottom: 10.0),),
                  ElevatedButton(onPressed: (){
                    if(_formKey.currentState!.validate()){
                      if(selectedValue == Type.written){
                        if(Constants.questionOperation){
                          editQuestion(widget.question);
                        }
                        else{
                          addQuestion(widget.question);
                        }
                      }
                      else if(options.length < 2){
                        showDialog(context: context, builder: (context){
                          return AlertDialog(
                            title: Text("Error"),
                            content: Text("Add atleast two options"),
                            actions: [
                              TextButton(onPressed: (){Navigator.pop(context);}, child: Text("OK"))
                            ],
                          );
                        });
                      }
                      else{
                        if(Constants.questionOperation){
                          editQuestion(widget.question);
                        }
                        else{
                          addQuestion(widget.question);
                        }
                      }
                    }
                  }, child: Text(Constants.questionOperation?"Edit Question":"Add Question"))
                ],
              )),
        ),
      ),
    );
  }

  void showAddOptionDialog(String s) {
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text("Option"),
        content: Form(
          key:_optionKey,
          child: TextFormField(
            controller: optionController,
              validator:(val){
                if(val!.isEmpty){
                  return "Please enter option";
                }
                return null;
              },
            decoration: InputDecoration(labelText:"Option",border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
          ),
        ),
        actions: [
          TextButton(onPressed: (){
            if(_optionKey.currentState!.validate()){
              setState(() {
                options.add(optionController.value.text);
                widget.question.setOptions = options;
                optionController.text = "";
                if(correctOption == ""){
                  correctOption = options[0];
                  widget.question.setCorrectAnswer = correctOption;
                }
                Navigator.pop(context);
              });
            }
          }, child: Text("Ok")),
          TextButton(onPressed: (){Navigator.pop(context);}, child: Text("Cancel")),
        ],
      );
    });
  }

  void addQuestion(Question question) async{
    var url = Uri.http(Constants.baseURL, Constants.questionPath);
    var questionMap = Question.toMap(widget.question);
     var op = "";

     for(int i=0; i<question.getOptions.length;i++){
       if(i == question.getOptions.length - 1){
         op = "$op${question.getOptions[i]}";
       }
       else{
         op = "$op${question.getOptions[i]}/////";
       }

     }

     op = "["+op+"]";


    questionMap["topic"] = questionMap["topic"]["id"].toString();
    questionMap["id"] = questionMap["id"].toString();
    questionMap["level"] = questionMap["level"].toString();
    questionMap["options"] = op;


    print(questionMap);
    // Await the http get response, then decode the json-formatted response.
    var jsonQuestionMap = jsonEncode(questionMap);


    var response = await http.post(url, body: questionMap);


    if (response.statusCode == 201) {
      int questionId = jsonDecode(response.body)["question_id"];
      showSnackBar("Question Added");
      setState(() {
        visible = false;
        questionController.text = "";
        levelController.text = "0";
        standardAnswerController.text = "";
        options = [];
        selectedValue = Type.written;
        widget.question.setOptions = options;
      });

    } else if(response.statusCode == 409) {
      //return Topic("409",409);
    }
    else{
      //return topic;
      print(response.statusCode);
      print(response.body);
    }
  }
  void showSnackBar(String message) {
    SnackBar snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showUpdateOptionDialog(String option,int index) {
    optionController.text = option;
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text("Option"),
        content: Form(
          key:_optionKey,
          child: TextFormField(
            controller: optionController,
            validator:(val){
              if(val!.isEmpty){
                return "Please enter option";
              }
              return null;
            },
            decoration: InputDecoration(labelText:"Option",border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
          ),
        ),
        actions: [
          TextButton(onPressed: (){
            if(_optionKey.currentState!.validate()){
              setState(() {
                options[index] = optionController.value.text;
                widget.question.setOptions = options;
                optionController.text = "";
                if(correctOption == ""){
                  correctOption = options[0];
                  widget.question.setCorrectAnswer = correctOption;
                }
                Navigator.pop(context);
              });
            }
          }, child: Text("Ok")),
          TextButton(onPressed: (){Navigator.pop(context);}, child: Text("Cancel")),
        ],
      );
    });
  }

  void getOptions(Question question) async{
    var url = Uri.http(Constants.baseURL, Constants.questionPath,{"options":question.getId.toString()});

    var response = await http.get(url);
    if(response.statusCode == 200){
      var data = jsonDecode(response.body);
      var data1 = data["body"];
      String options1 = data1["options"];
      String correct = data1["correctAnswer"];
      question.setOptions = options1.split("/////");
      question.setCorrectAnswer = correct;

      setState(() {
        widget.question = question;
        options = widget.question.getOptions;
        correctOption = widget.question.getCorrectAnswer;
      });
    }
  }

  void getStandardAnswer() async{
    var url = Uri.http(Constants.baseURL, Constants.questionPath,{"standardAnswer":widget.question.getId.toString()});

    var response = await http.get(url);
    if(response.statusCode == 200){
      var data = jsonDecode(response.body);
      var data1 = data["body"];
      String correct = data1["correctAnswer"];
      widget.question.setCorrectAnswer = correct;

      print(widget.question);
      setState(() {
        standardAnswerController.text = correct;
      });
    }
  }

  void editQuestion(Question question) async {
    var questionMap = Question.toMap(widget.question);
    print(questionMap);

    var op = "";

    for(int i=0; i<question.getOptions.length;i++){
      if(i == question.getOptions.length - 1){
        op = "$op${question.getOptions[i]}";
      }
      else{
        op = "$op${question.getOptions[i]}/////";
      }

    }

    op = "["+op+"]";

    questionMap["topic"] = questionMap["topic"]["id"].toString();
    questionMap["id"] = questionMap["id"].toString();
    questionMap["level"] = questionMap["level"].toString();
    questionMap["options"] = op;

    var url = Uri.http(Constants.baseURL, Constants.questionPath,{"q_id":question.getId.toString()});
    var response = await http.patch(url,body: questionMap);
    if(response.statusCode == 200){
      Navigator.pop(context,1);
    }
    else{
      print(response.body);
    }
  }
}
