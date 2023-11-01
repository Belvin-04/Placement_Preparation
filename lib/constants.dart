import 'package:flutter/material.dart';

class Constants{
  // static String baseURL = "192.168.0.103";
  static String baseURL = "10.80.8.114";

  static String questionPath = "Placement Preparation/Server/questions.php";
  static String topicPath = "Placement Preparation/Server/topics.php";
  static String studentPath = "Placement Preparation/Server/student.php";

  static int userType = 0;

  static String userEmail = "";
  static String userName = "";

  static String quizType = "";

  static bool questionOperation = false;

  static String courseType = "";
  static int sem = 0;

  static String studentNo = "";
  static String studentName = "";


  static void showSnackBar(String message, BuildContext context) {
    SnackBar snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}