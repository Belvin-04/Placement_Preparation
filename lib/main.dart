import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:placement_preparation/QuestionDetail.dart';
import 'package:placement_preparation/quiz.dart';
import 'Login.dart';
import 'Models/Question.dart';
import 'topics.dart';
//SELECT * FROM (SELECT qd.id as id,qd.question as question,qd.topic_id as topic_id,qd.level as level,GROUP_CONCAT(mo.choice) as `choices`FROM `question_details` qd JOIN `mcq_options` mo ON qd.id = mo.question_id JOIN `question_answer_relation` qar ON qar.question_id = qd.id AND qd.topic_id=1 AND qd.type_id = 1 GROUP BY qd.id) a JOIN (SELECT qd.id as id,mo.choice as choice FROM `question_details` qd JOIN `mcq_options` mo ON qd.id = mo.question_id JOIN `question_answer_relation` qar ON qar.question_id = qd.id AND qd.topic_id=1 AND qd.type_id = 1 AND mo.id = qar.answer_id GROUP BY qd.id) b ON a.id = b.id;
void main(){
  runApp(Home());
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Login(),
      ),
    );
  }
}