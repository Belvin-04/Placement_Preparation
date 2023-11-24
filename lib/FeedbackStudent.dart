import 'package:flutter/material.dart';

class FeedbackStudent extends StatefulWidget {
  var quizFeedback;

  FeedbackStudent(this.quizFeedback, {super.key});

  @override
  State<FeedbackStudent> createState() => _FeedbackStudentState();
}

class _FeedbackStudentState extends State<FeedbackStudent> {

  int q = 0;

  //bool loaded;
  String btnText = "Next";


  TextEditingController answerController = TextEditingController();
  TextEditingController ratingController = TextEditingController();
  TextEditingController stdAnsController = TextEditingController();
  TextEditingController facultyNameController = TextEditingController();

  TextEditingController facultyRatingController = TextEditingController();
  TextEditingController facultyFeedbackController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    if (widget.quizFeedback!.length == 1) {
      btnText = "Finish";
    }
    if (q == 0) {
      stdAnsController.text = widget.quizFeedback[0]["stdAnswer"];
      answerController.text = widget.quizFeedback[0]["answer"];
      facultyNameController.text = widget.quizFeedback[0]["name"];
      ratingController.text = widget.quizFeedback[0]["userRating"].toString();
      facultyRatingController.text = widget.quizFeedback[0]["rating"].toString();
      facultyFeedbackController.text = widget.quizFeedback[0]["review"];
    }

    return Scaffold(
        appBar: AppBar(
          title: Text("Review"),

        ),
        body: Center(
            child: Form(
                child: Column(
                  children: [
                    Text(widget.quizFeedback[q]["question"],
                      style: TextStyle(fontSize: 20.0),),
                    Container(height: 10.0,),
                    TextFormField(
                      enabled: false,
                      controller: facultyNameController,
                      decoration: InputDecoration(
                          labelText: "Faculty Name",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)
                          )
                      ),

                    ),
                    Container(height: 10.0,),
                    TextFormField(
                      enabled: false,
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
                      enabled: false,
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
                      enabled: false,
                      controller: facultyRatingController,
                      decoration: InputDecoration(
                          labelText: "Faculty Rating",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)
                          )
                      ),
                    ),
                    Container(height: 10.0,),
                    TextFormField(
                      enabled: false,
                      controller: facultyFeedbackController,
                      decoration: InputDecoration(
                          labelText: "Feedback",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)
                          )
                      ),
                    ),
                    Container(height: 10.0,),


                    ElevatedButton(onPressed: () {
                      if (q + 2 == widget.quizFeedback!.length) {
                        q = q + 1;
                        btnText = "Submit";
                      }
                      else if (q + 1 < widget.quizFeedback!.length) {
                        q = q + 1;
                      }
                      else if (q + 1 == widget.quizFeedback!.length) {
                        Navigator.pop(context, 1);
                      }
                      setState(() {
                        stdAnsController.text = widget.quizFeedback[q]["stdAnswer"];
                        answerController.text = widget.quizFeedback[q]["answer"];
                        facultyNameController.text = widget.quizFeedback[q]["name"];
                        ratingController.text = widget.quizFeedback[q]["userRating"].toString();
                        facultyRatingController.text = widget.quizFeedback[q]["rating"].toString();
                        facultyFeedbackController.text = widget.quizFeedback[q]["review"];

                      });
                    }, child: Text(btnText))
                  ],
                )
            )
        )
    );
  }
}
