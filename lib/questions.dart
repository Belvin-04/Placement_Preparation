import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:placement_preparation/FacultyReview.dart';
import 'package:placement_preparation/Models/Question.dart';
import 'package:http/http.dart' as http;
import 'package:placement_preparation/QuestionDetail.dart';
import 'Models/Topic.dart';
import 'constants.dart';

class Questions extends StatefulWidget {
  Topic topic;

  Questions(this.topic, {super.key});

  @override
  State<Questions> createState() => _QuestionsState();
}

class _QuestionsState extends State<Questions> {
  List<bool> colors = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showDialog(context: context, builder: (context){
            return AlertDialog(
              content: Container(
                height: 80.0,
                child: Column(
                  children: [
                    ElevatedButton(onPressed: () async{
                      Constants.questionOperation = false;
                      Question q = Question("","WRITTEN",0);
                      q.setTopic = widget.topic;
                      int res = await Navigator.push(context, MaterialPageRoute(builder: (context)=>QuestionDetail(q)));
                      if(res == 1){
                        setState(() {

                        });
                      }
                    }, child: Text("Add Question")),
                    Container(margin: EdgeInsets.only(bottom: 10.0),),
                    ElevatedButton(onPressed: (){
                      addQuestionsFromFile();
                    }, child: Text("Add Questions from file")),
                  ],
                ),
              ),
            );
          });


        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text("Questions"),
      ),
      body: FutureBuilder(
          future: getQuestions(widget.topic.getId),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: snapshot.data?.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Text(snapshot.data![index].getQuestion),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            (snapshot.data![index].getType == "WRITTEN")?
                            IconButton(
                                onPressed: (colors[index])?() async{
                              int c = await Navigator.push(context, MaterialPageRoute(builder: (context)=>FacultyReview(snapshot.data![index])));
                              if(c == 1){
                                setState(() {

                                });
                              }
                            }:(){}, icon:
                            Icon(Icons.assessment,color: (colors[index])?Colors.greenAccent:Colors.grey,)):Container(),

                            IconButton(icon: Icon(Icons.edit,color: Colors.blue,),onPressed: () async{
                              Constants.questionOperation = true;
                              Question q = snapshot.data![index];
                              q.setTopic = widget.topic;
                              int c = await Navigator.push(context, MaterialPageRoute(builder: (context)=>QuestionDetail(q)));
                              if(c==1){
                                setState(() {

                                });
                              }

                            },),
                            IconButton(icon: Icon(Icons.delete,color: Colors.red,),onPressed: (){
                              showDialog(context: context, builder: (context){
                                return AlertDialog(
                                  title: Text("Delete Question ?"),
                                  content: Text("This action cannot be undone..."),
                                  actions: [TextButton(onPressed: () async{
                                    if (await deleteQuestion(snapshot.data![index].getId) == 1) {
                                      Navigator.pop(context);
                                      setState(() {});
                                    }
                                  },child:Text("Yes")),TextButton(onPressed: (){
                                    Navigator.pop(context);
                                  },child: Text("No"))],
                                );
                              });
                            },),
                          ],
                        ),
                      ),
                    );
                  });
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }

  Future<List<Question>> getQuestions(int topicId) async {
    List<Question> questions = [];
    var url = Uri.http(Constants.baseURL, Constants.questionPath,
        {"t_id": "$topicId"});

    var response = await http.get(url);


    if (response.statusCode != 204) {
      List b = jsonDecode(response.body)["body"];
      int total = jsonDecode(response.body)["total"];

      colors.clear();

      for (int i = 0; i < total; i++) {
        questions.add(Question.toQuestion(b[i], widget.topic));
        int color = await checkColor(questions[i].getId);
        colors.add(color != 0);
      }

      return questions;
    } else {
      return [];
    }
  }

  void addQuestionsFromFile() async {
    FilePickerResult? pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      allowMultiple: false,
    );
    List<Question> questions = [];

    /// file might be picked
    if (pickedFile != null) {
      var bytes = pickedFile.files.single.bytes;
      var excel = Excel.decodeBytes(bytes as List<int>);
      var table = "Sheet1";
      int maxRows = excel.tables[table]!.maxRows;
      int maxCols = excel.tables[table]!.maxCols;

      for(int i=0;i<maxRows-1; i++){
        Question q = Question("", "", 0);
        for(int j=0; j<maxCols; j++){
          String c = String.fromCharCode(65+j);
          if(c == "A"){
            q.setQuestion = excel[table].cell(CellIndex.indexByString("$c${i+2}")).value.toString();
          }
          else if(c == "B"){
            q.setType = excel[table].cell(CellIndex.indexByString("$c${i+2}")).value.toString();
          }
          else if(c == "C"){
            q.setTopic = Topic("",excel[table].cell(CellIndex.indexByString("$c${i+2}")).value);
          }else if(c == "D"){
            q.setLevel =  excel[table].cell(CellIndex.indexByString("$c${i+2}")).value as int;
          }else if(c == "E"){
            var op = excel[table].cell(CellIndex.indexByString("$c${i+2}")).value.toString().split("/////");
            if(op.length >= 2){
              q.setOptions = op;
            }
          }else if(c == "F"){
            q.setCorrectAnswer = excel[table].cell(CellIndex.indexByString("$c${i+2}")).value.toString();
          }
        }
        questions.add(q);

      }
      var questionsMap = [];
      for(int i=0; i<questions.length; i++){
        questionsMap.add(Question.toMap(questions[i]));
      }

      Map<String,dynamic> questionRequestMap = {};
      questionRequestMap["total"] = questions.length.toString();
      questionRequestMap["questions"] = questionsMap;

      var url = Uri.http(Constants.baseURL, Constants.questionPath);
      var response = await http.post(url,body: {"data":jsonEncode(questionRequestMap)});

      if (response.statusCode != 204) {
        // List b = jsonDecode(response.body)["body"];
        // int total = jsonDecode(response.body)["total"];
        // for (int i = 0; i < total; i++) {
        //   questions.add(Question.toQuestion(b[i], widget.topic));
        // }
        // return questions;
        Navigator.pop(context);
        setState(() {

        });
      } else {
        // return [];
      }
    }
  }

  Future<int> deleteQuestion(int id) async{
    var url = Uri.http(Constants.baseURL, Constants.questionPath, {"q_id": "$id"});

    // Await the http get response, then decode the json-formatted response.
    var response = await http.delete(url);
    if (response.statusCode == 200) {
      return 1;
    } else {

      return 0;
    }
  }

  Future<int> checkColor(int questionId) async{
    var url = Uri.http(Constants.baseURL,Constants.checkPath,
        {"checkColor":"1","questionId":questionId.toString(),"faculty_id":Constants.userEmail});
    var response = await http.get(url);


    return jsonDecode(response.body)["total"];
  }
}


