import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:placement_preparation/questions.dart';
import 'package:placement_preparation/quiz.dart';
import 'Models/Topic.dart';
import 'constants.dart';

class Topics extends StatefulWidget {
  const Topics({super.key});

  @override
  State<Topics> createState() => _TopicsState();
}

class _TopicsState extends State<Topics> {
  var topicController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Visibility(
        visible: Constants.userType == 1,
        child: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              showSaveTopicDialog(Topic(""));
            }),
      ),
      appBar: AppBar(
        title: Text("Topics"),
      ),
      body: FutureBuilder(
          future: getTopics(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: snapshot.data?.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        if(Constants.userType == 1){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>Questions(Topic(snapshot.data![index].getName,snapshot.data![index].getId))));
                        }
                        else{
                          showDialog(context: context, builder: (context){
                            return AlertDialog(
                              content: Container(
                                height: 80,
                                child: Column(
                                  children: [
                                    ElevatedButton(onPressed: (){
                                      Constants.quizType = "MCQ";
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => Quiz(Topic(snapshot.data![index].getName, snapshot.data![index].getId))));
                                    }, child: Text("MCQ")),
                                    Container(
                                      margin: EdgeInsets.only(bottom: 20.0),
                                    ),
                                    ElevatedButton(onPressed: (){
                                      Constants.quizType = "WRITTEN";
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => Quiz(Topic(snapshot.data![index].getName, snapshot.data![index].getId))));
                                    }, child: Text("WRITTEN"))
                                  ],
                                ),
                              ),
                            );
                          });
                        }
                      },
                      child: Card(
                        child: ListTile(
                          title: Text(snapshot.data![index].getName),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Visibility(
                                visible: Constants.userType == 1,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    showSaveTopicDialog(snapshot.data![index]);
                                  },
                                ),
                              ),
                              Visibility(
                                visible: Constants.userType == 1,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text("Delete Topic ?"),
                                            content: Text(
                                                "This action cannot be undone..."),
                                            actions: [
                                              TextButton(
                                                  onPressed: () async {
                                                    if (await deleteTopic(snapshot
                                                            .data![index]
                                                            .getId) ==
                                                        1) {
                                                      Navigator.pop(context);
                                                      setState(() {});
                                                    }
                                                  },
                                                  child: Text("Yes")),
                                              TextButton(
                                                  onPressed: () async {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text("No"))
                                            ],
                                          );
                                        });
                                  },
                                ),
                              ),
                            ],
                          ),
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

  Future<List<Topic>> getTopics() async {
    List<Topic> topics = [];
    var url = Uri.http(Constants.baseURL, Constants.topicPath);

    var response = await http.get(url);

    if (response.statusCode != 204) {
      List b = jsonDecode(response.body)["body"];
      int total = jsonDecode(response.body)["total"];
      for (int i = 0; i < total; i++) {
        topics.add(Topic.toTopic(b[i]));
      }

      return topics;
    } else {
      return [];
    }
  }

  Future<Topic> addTopic(Topic topic) async {
    var url = Uri.http(Constants.baseURL, Constants.topicPath);

    // Await the http get response, then decode the json-formatted response.
    var response = await http.post(url, body: {"name": topic.getName});
    if (response.statusCode == 201) {
      int topicId = jsonDecode(response.body)["topic_id"];
      topic.setId = topicId;
      return topic;
    } else if (response.statusCode == 409) {
      return Topic("409", 409);
    } else {
      return topic;
    }
  }

  showSaveTopicDialog(Topic topic) {
    topicController.text = topic.getName;
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState1) {
            bool existsMsg = false;
            return AlertDialog(
              title: Text("Topic Detail"),
              content: Form(
                  key: _formKey,
                  child: Container(
                    height: 80.0,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: topicController,
                          onChanged: (value) {
                            topic.setName = value;
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please Enter Topic Name";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              labelText: "Topic Name",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              )),
                        ),
                        Visibility(
                            visible: existsMsg,
                            child: Text(
                              "Topic Already Exists",
                            ))
                      ],
                    ),
                  )),
              actions: [
                TextButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if(topic.getId != 0){
                          topicController.text = "";
                          Topic t = await updateTopic(topic);
                          if (topic.getId == 409 && topic.getName == "409") {
                            Navigator.pop(context);
                            showSnackBar("Topic Already Exists", context);
                          } else if (t.getName == "Error") {
                            Navigator.pop(context);
                            showSnackBar("Problem In Updating Topic", context);
                          } else {
                            topicController.text = "";
                            Navigator.pop(context);
                            showSnackBar("Topic Updated Successfully", context);
                            setState(() {});
                          }
                        }
                        else{
                          Topic t = await addTopic(topic);
                          if (t.getId == 409 && t.getName == "409") {
                            Navigator.pop(context);
                            //setState1((){existsMsg = !existsMsg;})
                            showSnackBar("Topic Already Exists", context);
                          } else if (t.getId == 0) {
                            Navigator.pop(context);
                            showSnackBar("Problem In Adding Topic", context);
                          } else {
                            topicController.text = "";
                            Navigator.pop(context);
                            showSnackBar("Topic Added Successfully", context);
                            setState(() {});
                          }
                        }
                      }
                    },
                    child: Text("Save"))
              ],
            );
          });
        });
  }

  void showSnackBar(String message, BuildContext context) {
    SnackBar snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<int> deleteTopic(int id) async {
    var url = Uri.http(Constants.baseURL, Constants.topicPath, {"t_id": "$id"});
    print(url);
    // Await the http get response, then decode the json-formatted response.
    var response = await http.delete(url);
    if (response.statusCode == 200) {
      return 1;
    } else {
      print(response.body);
      return 0;
    }
  }

  Future<Topic> updateTopic(Topic topic) async{
    var url = Uri.http(Constants.baseURL, Constants.topicPath);

    // Await the http get response, then decode the json-formatted response.
    var response = await http.patch(url, body: {"name": topic.getName,"id":"${topic.getId}"});
    print(response.statusCode);
    if (response.statusCode == 201) {
      return topic;
    } else if (response.statusCode == 409) {
      return Topic("409", 409);
    } else {
      return Topic("Error",topic.getId);
    }
  }
}
