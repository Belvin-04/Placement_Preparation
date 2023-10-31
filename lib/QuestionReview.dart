import 'package:flutter/material.dart';
import 'package:placement_preparation/Models/AnswerHistory.dart';

class QuestionReview extends StatefulWidget {
  AnswerHistory ah;
  QuestionReview(this.ah);

  @override
  State<QuestionReview> createState() => _QuestionReviewState();
}

class _QuestionReviewState extends State<QuestionReview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Question Review"),),
      body: Column(
        children: [
          Center(child: Text(widget.ah.question)),
          Text("Your Answer: ${widget.ah.answer}"),
          Text("Your Rating: ${widget.ah.userRating}")
        ],
      ),
    );
  }
}
