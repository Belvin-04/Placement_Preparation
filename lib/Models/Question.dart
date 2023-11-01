import 'package:flutter/foundation.dart';

import 'Topic.dart';

class Question{
  int id;
  String question;
  String type;
  Topic? topic;
  int level;
  List<String> options = [];
  String correctAnswer = "";
  Question(this.question,this.type,this.level,[this.id = 0]);

  set setId(int id){
    this.id = id;
  }

  set setQuestion(String question){
    this.question = question;
  }

  set setType(String type){
    this.type = type;
  }

  set setTopic(Topic topic){
    this.topic = topic;
  }

  set setOptions(List<String> options){
    this.options = options;
  }

  set setLevel(int level){
    this.level = level;
  }

  set setCorrectAnswer(String correctAnswer){
    this.correctAnswer = correctAnswer;
  }

  String get getCorrectAnswer{
    return correctAnswer;
  }

  int get getId{
    return id;
  }

  String get getQuestion{
    return question;
  }

  String get getType{
    return type;
  }

  Topic? get getTopic{
    return topic;
  }

  List<String> get getOptions{
    return options;
  }

  int get getLevel{
    return level;
  }

  static Map<String,dynamic> toMap(Question q){
    Map<String,dynamic> questionMap = {};
    questionMap["id"] = q.id;
    questionMap["question"] = q.question;
    questionMap["type"] = q.type;
    questionMap["topic"] = q.topic?.toMap();
    questionMap["level"] = q.getLevel;
    questionMap["correctAnswer"] = q.correctAnswer;
    if(q.type == "MCQ"){
      questionMap["options"] = q.options;
    }
    else{
      questionMap["options"] = ["NA"];
    }
    return questionMap;
  }

  static Question toQuestion(Map<String,dynamic> questionMap,Topic t){
    List<String> options = [];
    int id = questionMap["id"];
    String question = questionMap["question"];
    String type = questionMap["type"];
    int level = questionMap["level"];

    Question q = Question(question, type,level,id);
    q.setTopic = t;
    q.setCorrectAnswer = questionMap["correctAnswer"];

    if(questionMap.length == 6){
      options = (questionMap["options"] as List).map((item) => item as String).toList();
      q.setOptions = options;
    }

    return q;
  }

  String toString(){
    return "id:$id\nquestion:$question\ntype:$type\ntopic:$topic\noptions:$options\ncorrect_option:$correctAnswer\nlevel:$level";
  }
}