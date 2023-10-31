import 'package:flutter/material.dart';
import 'package:placement_preparation/StudentList.dart';
import 'package:placement_preparation/constants.dart';

class SemesterList extends StatefulWidget {
  const SemesterList({super.key});

  @override
  State<SemesterList> createState() => _SemesterListState();
}

class _SemesterListState extends State<SemesterList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Semester"),
      ),
      body: ListView.builder(itemCount:(Constants.courseType == "Diploma"?6:8),itemBuilder: (context,index){
        return GestureDetector(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>StudentList(index+1)));
          },
          child: Card(
            child: ListTile(
              title: Text("Semester: ${index + 1}"),
            ),
          ),
        );
      }),
    );
  }
}
