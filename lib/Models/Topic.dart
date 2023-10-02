class Topic{
  int id;
  String name;
  Topic(this.name,[this.id = 0]);

  void set setName(String name){
    this.name = name;
  }

  void set setId(int id){
    this.id = id;
  }

  String get getName{
    return name;
  }

  int get getId{
    return id;
  }

  String toString(){
    return "id:$id,name:$name";
  }

  Map<String,dynamic> toMap(){
    Map<String,dynamic> topicMap = Map();
    topicMap["id"] = id;
    topicMap["name"] = name;

    return topicMap;
  }

  static Topic toTopic(Map<String,dynamic> topicMap){
    int id = topicMap["id"];
    String name = topicMap["name"];

    return Topic(name,id);
  }

}