import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Question q = Question("","WRITTEN",0);
          q.setTopic = widget.topic;
          Navigator.push(context, MaterialPageRoute(builder: (context)=>QuestionDetail(q)));
          // addQuestionsFromFile();
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
                            IconButton(icon: Icon(Icons.edit,color: Colors.blue,),onPressed: (){
                              Question q = snapshot.data![index];
                              q.setTopic = widget.topic;
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>QuestionDetail(q)));
                            },),
                            IconButton(icon: Icon(Icons.delete,color: Colors.red,),onPressed: (){
                              showDialog(context: context, builder: (context){
                                return AlertDialog(
                                  title: Text("Delete Question ?"),
                                  content: Text("This action cannot be undone..."),
                                  actions: [TextButton(onPressed: (){
                                    deleteQuestion(snapshot.data![index].getId);
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
      for (int i = 0; i < total; i++) {
        questions.add(Question.toQuestion(b[i], widget.topic));
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
    // print(pickedFile);
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
            var op = excel[table].cell(CellIndex.indexByString("$c${i+2}")).value.toString().split(",");
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
      questionRequestMap["total"] = questions.length;
      questionRequestMap["questions"] = questionsMap;

      var url = Uri.http(Constants.baseURL, Constants.questionPath);
      var response = await http.post(url,body: questionRequestMap);

      // if (response.statusCode != 204) {
      //   List b = jsonDecode(response.body)["body"];
      //   int total = jsonDecode(response.body)["total"];
      //   for (int i = 0; i < total; i++) {
      //     questions.add(Question.toQuestion(b[i], widget.topic));
      //   }
      //   return questions;
      // } else {
      //   return [];
      // }
    }
  }

  void deleteQuestion(int id) {
  }
}


