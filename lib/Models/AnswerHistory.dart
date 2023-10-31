class AnswerHistory{
  int _id;
  String _question,_studentId;
  int? _userRating,_feedback;
  String?  _answer,_facultyReview,_facultyName,_studentName;

  AnswerHistory(this._id, this._userRating,this._feedback,this._facultyName,this._question,this._answer,this._facultyReview,this._studentName,this._studentId);


  int get id => _id;

  set id(int value) {
    _id = value;
  }

  get userRating => _userRating;

  set userRating(value) {
    _userRating = value;
  }

  get studentId => _studentId;

  set studentId(value) {
    _studentId = value;
  }

  get feedback => _feedback;

  set feedback(value) {
    _feedback = value;
  }

  String get question => _question;

  set question(String value) {
    _question = value;
  }

  get answer => _answer;

  set answer(value) {
    _answer = value;
  }

  get facultyReview => _facultyReview;

  set facultyReview(value) {
    _facultyReview = value;
  }

  get facultyName => _facultyName;

  set facultyName(value) {
    _facultyName = value;
  }

  get studentName => _studentName;

  set studentName(value) {
    _studentName = value;
  }

  static Map<String,dynamic> toMap(AnswerHistory ah){
    Map<String,dynamic> map = Map();

    map["id"] = ah.id;
    map["question"] = ah.question;
    map["answer"] = ah.answer;
    map["userRating"] = ah.userRating;
    map["feedback"] = ah.feedback;
    map["facultyReview"] = ah.facultyReview;
    map["facultyName"] = ah.facultyName;
    map["studentName"] = ah.studentName;
    map["studentId"] = ah.studentId;

    return map;
  }

  static AnswerHistory toAnswerHistory(Map<String,dynamic> ah){
    int id = int.parse(ah["id"]);
    String question = ah["question"];
    int? feedback = ah["feedback"]==null?null:int.parse(ah["feedback"]);
    int userRating = int.parse(ah["userRating"]);
    String answer = ah["answer"];
    String? facultyName = ah["facultyName"];
    String? facultyReview = ah["facultyReview"];
    String studentName = ah["studentName"];
    String studentId = ah["studentId"];

    AnswerHistory answerHistory = AnswerHistory(id, userRating, feedback, facultyName, question, answer, facultyReview,studentName,studentId);

    return answerHistory;

  }

  @override
  String toString() {
    return 'AnswerHistory{_id: $_id, _question: $_question, _studentId: $_studentId, _userRating: $_userRating, _feedback: $_feedback, _answer: $_answer, _facultyReview: $_facultyReview, _facultyName: $_facultyName, _studentName: $_studentName}';
  }
}