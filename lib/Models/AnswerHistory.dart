class AnswerHistory{
  int _id,_userRating;
  String _studentName,_answer;

  AnswerHistory(this._id, this._userRating, this._studentName, this._answer);


  @override
  String toString() {
    return 'AnswerHistory{_id: $_id, _userRating: $_userRating, _studentName: $_studentName, _answer: $_answer}';
  }

  int get id => _id;

  set id(int value) {
    _id = value;
  }

  get userRating => _userRating;

  set userRating(value) {
    _userRating = value;
  }

  String get studentName => _studentName;

  set studentName(String value) {
    _studentName = value;
  }

  get answer => _answer;

  set answer(value) {
    _answer = value;
  }

  static Map<String,dynamic> toMap(AnswerHistory ah){
    Map<String,dynamic> map = Map();

    map["id"] = ah.id;
    map["answer"] = ah.answer;
    map["userRating"] = ah.userRating;
    map["studentName"] = ah.studentName;

    return map;
  }

  static AnswerHistory toAnswerHistory(Map<String,dynamic> ah){
    int id = ah["id"];
    int userRating = ah["userRating"];
    String answer = ah["answer"];
    String studentName = ah["studentName"];

    AnswerHistory answerHistory = AnswerHistory(id, userRating, studentName, answer);

    return answerHistory;

  }
}