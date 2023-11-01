<?php
include "./dbconn.php";
const DUPLICATE_KEY_NO = 1062;
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PATCH, DELETE");

function parse_raw_http_request(array &$a_data)
{
  // read incoming data
  $input = file_get_contents('php://input');
  
  // grab multipart boundary from content type header
  preg_match('/boundary=(.*)$/', $_SERVER['CONTENT_TYPE'], $matches);
  $boundary = $matches[1];
  
  // split content by boundary and get rid of last -- element
  $a_blocks = preg_split("/-+$boundary/", $input);
  array_pop($a_blocks);
      
  // loop data blocks
  foreach ($a_blocks as $id => $block)
  {
    if (empty($block))
      continue;
    
    // you'll have to var_dump $block to understand this and maybe replace \n or \r with a visibile char
    
    // parse uploaded files
    if (strpos($block, 'application/octet-stream') !== FALSE)
    {
      // match "name", then everything after "stream" (optional) except for prepending newlines 
      preg_match('/name=\"([^\"]*)\".*stream[\n|\r]+([^\n\r].*)?$/s', $block, $matches);
    }
    // parse all other fields
    else
    {
      // match "name" and optional value in between newline sequences
      preg_match('/name=\"([^\"]*)\"[\n|\r]+([^\n\r].*)?\r$/s', $block, $matches);
    }
    $a_data[$matches[1]] = $matches[2];
  }        
}



function addQuestion(){
    $conn = $GLOBALS["conn"];
    // $sql = $conn->prepare("INSERT INTO question_details(`question`,`type_id`,`topic_id`,`level`) VALUES(?,?,?,?)");
        $type = 1;
        if($_POST["type"] == "WRITTEN"){
            $type = 2;
        }

        $sql = "INSERT INTO question_details(`question`,`type_id`,`topic_id`,`level`) VALUES('".$_POST["question"]."',".$type.",".$_POST["topic"].",".$_POST["level"].")";
        $conn->query($sql);

        // $sql->bind_param("siii",$_POST["question"],$type,$_POST["topic"],$_POST["level"]);
        // $quesId = $sql->insert_id;
        $quesId = $conn->insert_id;
        
        
        if($_POST["type"] == "MCQ"){
            $correctId = 0;
            $optionsString = $_POST["options"];
            $optionsString = substr($optionsString,1,-1);
            $arr = explode(",",$optionsString);

            for($i=0; $i<count($arr); $i++){
                // $sql = $conn->prepare("INSERT INTO mcq_options(`question_id`,`choice`) VALUES(?,?)");
                // $sql->bind_param("is",$quesId,$arr[0]);
                // $sql->execute();
                $sql = "INSERT INTO mcq_options(`question_id`,`choice`) VALUES(".$quesId.",'".$arr[$i]."')";
                $conn->query($sql);
                if($arr[$i] == $_POST["correctAnswer"]){
                    // $correctId = $sql->insert_id;
                    $correctId = $conn->insert_id;
                }
            }

            // $sql = $conn->prepare("INSERT INTO question_answer_relation VALUES(?,?)");
            // $sql->bind_param("ii",$quesId,$correctId);
            // $sql->execute();
            $sql = "INSERT INTO question_answer_relation VALUES(".$quesId.",".$correctId.")";
            $conn->query($sql);

        }
        return $quesId;
}


if($_SERVER["REQUEST_METHOD"] == "GET"){
    if(isset($_GET["q_id"])){
        $sql = $conn->prepare("SELECT * FROM (SELECT qd.id as id,qd.question as question,qd.topic_id as topic_id,qd.level as level,
        GROUP_CONCAT(mo.choice  SEPARATOR '/////') as `choices`FROM `question_details` qd JOIN `mcq_options` mo ON qd.id = mo.question_id JOIN 
        `question_answer_relation` qar ON qar.question_id = qd.id AND qd.topic_id=? AND qd.type_id = ? GROUP BY qd.id) a JOIN 
        (SELECT qd.id as id,mo.choice as choice FROM `question_details` qd JOIN `mcq_options` mo ON qd.id = mo.question_id JOIN 
        `question_answer_relation` qar ON qar.question_id = qd.id AND qd.topic_id=? AND qd.type_id = ? AND mo.id = qar.answer_id GROUP BY 
        qd.id) b ON a.id = b.id");
    }

    if(isset($_GET["options"])){
        $sql = $conn->prepare("SELECT * FROM (SELECT mo.question_id as q_id,GROUP_CONCAT(mo.choice  SEPARATOR '/////') as choices,qar.answer_id as a_id FROM 
        mcq_options mo JOIN question_answer_relation qar ON qar.question_id = mo.question_id AND mo.question_id = ? GROUP BY mo.question_id) a 
        JOIN (SELECT mo.choice as correct FROM mcq_options mo JOIN question_answer_relation qar ON qar.answer_id = mo.id AND mo.question_id = ? 
        GROUP BY mo.question_id ) b;");


        $sql->bind_param("ii",$_GET["options"],$_GET["options"]);
        $sql->execute();
        $res = $sql->get_result();

        if($res->num_rows == 0){
            header("Content-Type:application/json");
            http_response_code(204);
        }
        else{
            $data = $res->fetch_assoc();
            header("Content-Type:application/json");
            http_response_code(200);
            echo json_encode(array("message"=>"Options Found","body"=>array("options"=>$data["choices"],"correctAnswer"=>$data["correct"])));
        }
    }

    else if(isset($_GET["standardAnswer"])){
        $sql = $conn->prepare("SELECT * FROM `question_details` qd JOIN `descriptive_answer` da ON qd.id = da.q_id WHERE qd.id = ?");
        $sql->bind_param("i",$_GET["standardAnswer"]);

        $sql->execute();
        $res = $sql->get_result();

        if($res->num_rows == 0){
            header("Content-Type:application/json");
            http_response_code(204);
        }
        else{
            $data = $res->fetch_assoc();
            header("Content-Type:application/json");
            http_response_code(200);
            echo json_encode(array("message"=>"Answer Found","body"=>array("correctAnswer"=>$data["answer"])));
        }
    }

    else if(isset($_GET["check"]) && isset($_GET["id"])){
        $type = 1;
        $sql = $conn->prepare("SELECT * FROM question_details WHERE topic_id = ? AND type_id = ?");
        $sql->bind_param("ii",$_GET["id"],$type);
        $sql->execute();
        $res = $sql->get_result();

        $mcqQues = $res->num_rows;
        
        $type = 2;
        $sql = $conn->prepare("SELECT * FROM question_details WHERE topic_id = ? AND type_id = ?");
        $sql->bind_param("ii",$_GET["id"],$type);
        $sql->execute();
        $res = $sql->get_result();

        $writtenQues = $res->num_rows;

        header("Content-Type:application/json");
        http_response_code(200);
        echo json_encode(array("mcq"=>$mcqQues,"written"=>$writtenQues));
    }
    
    else if(isset($_GET["t_id"]) && isset($_GET["type"]) && $_GET["type"] == "WRITTEN"){
        $sql = $conn->prepare("SELECT * FROM `question_details` qd JOIN `descriptive_answer` da ON qd.id = da.q_id AND qd.topic_id = ? AND qd.type_id = ?");
        $type_id = 2;
        $sql->bind_param("ii",$_GET["t_id"],$type_id);
        $sql->execute();
        $res = $sql->get_result();

        if($res->num_rows == 0){   
            header("Content-Type:application/json");
            http_response_code(204);
        }
        else{
            $response = array();
            while($data = $res->fetch_assoc()){
                array_push($response,array("id"=>$data["id"],"question"=>$data["question"],"type"=>"WRITTEN","level"=>$data["level"],"correctAnswer"=>$data["answer"]));
            }
            header("Content-Type:application/json");
            http_response_code(200);
            echo json_encode(array("message"=>"Questions found","total"=>$res->num_rows,"body"=>$response));
        }
    }

    else if(isset($_GET["t_id"]) && isset($_GET["type"]) && $_GET["type"] == "MCQ"){
        $sql = $conn->prepare("SELECT * FROM (SELECT qd.id as id,qd.question as question,qd.topic_id as topic_id,qd.level as level,
        GROUP_CONCAT(mo.choice  SEPARATOR '/////') as `choices`FROM `question_details` qd JOIN `mcq_options` mo ON qd.id = mo.question_id JOIN 
        `question_answer_relation` qar ON qar.question_id = qd.id AND qd.topic_id=? AND qd.type_id = ? GROUP BY qd.id) a JOIN 
        (SELECT qd.id as id,mo.choice as choice FROM `question_details` qd JOIN `mcq_options` mo ON qd.id = mo.question_id JOIN 
        `question_answer_relation` qar ON qar.question_id = qd.id AND qd.topic_id=? AND qd.type_id = ? AND mo.id = qar.answer_id GROUP BY 
        qd.id) b ON a.id = b.id");

        $type_id = 1;
        $sql->bind_param("iiii",$_GET["t_id"],$type_id,$_GET["t_id"],$type_id);
        $sql->execute();
        $res = $sql->get_result();

        if($res->num_rows == 0){   
            header("Content-Type:application/json");
            http_response_code(204);
        }
        else{
            $response = array();
            while($data = $res->fetch_assoc()){
                array_push($response,array("id"=>$data["id"],"question"=>$data["question"],"type"=>"MCQ","level"=>$data["level"],
                "options"=>explode("/////",$data["choices"]),"correctAnswer"=>$data["choice"]));
            }
            header("Content-Type:application/json");
            http_response_code(200);
            echo json_encode(array("message"=>"Questions found","total"=>$res->num_rows,"body"=>$response));
        }
    }

    else if(isset($_GET["t_id"])){
        $sql = $conn->prepare("SELECT * FROM question_details WHERE topic_id = ?");
        $sql->bind_param("i",$_GET["t_id"]);
        $sql->execute();
        $res = $sql->get_result();
        

        if($res->num_rows == 0){
            
            header("Content-Type:application/json");
            http_response_code(204);
        }
        else{
            $response = array();
            while($data = $res->fetch_assoc()){
                array_push($response,array("id"=>$data["id"],"question"=>$data["question"],"type"=>$data["type_id"]==1?"MCQ":"WRITTEN","level"=>$data["level"]));
            }
            header("Content-Type:application/json");
            http_response_code(200);
            echo json_encode(array("message"=>"Questions found","total"=>$res->num_rows,"body"=>$response));
        }
    }

    else if(isset($_GET["t_id"]) && isset($_GET["quiz"])){
        $sql = $conn->prepare("SELECT * FROM `question_details` qd JOIN `mcq_options` mo ON qd.id = mo.question_id JOIN `question_answer_relation` qar ON qar.question_id = qd.id AND qd.topic_id=?");
        $sql->bind_param($_GET["t_id"]);
        
    }
    else if(isset($_GET["user"]) && isset($_GET["type"])){
        $sql = "";
        if($_GET["type"] == "Unchecked"){
            $sql = "SELECT * FROM answer_history ah JOIN question_details qd ON qd.id = ah.question_id AND student_id = ".$_GET["user"]." AND faculty_id IS NULL";
            $res = $conn->query($sql);

            if($res->num_rows == 0){
                header("Content-Type:application/json");
                http_response_code(400);
                echo json_encode(array("message"=>"No Questions found","total"=>0));
            }
            else{
                $response = array();

                while($row = $res->fetch_assoc()){
                    array_push($response,array("id"=>$row["id"],"question"=>$row["question"],"answer"=>$row["answer"],
                    "feedback"=>$row["feedback"],"facultyName"=>$row["faculty_id"],"userRating"=>$row["user_rating"],
                    "facultyReview"=>$row["faculty_review"]));
                }
                header("Content-Type:application/json");
                http_response_code(200);
                echo json_encode(array("message"=>"Questions found","total"=>$res->num_rows,"body"=>$response));
            }
        }
        else{
            $sql = "SELECT * FROM (SELECT ah.id,qd.question,ah.answer,ah.feedback,ah.faculty_id fid,ah.user_rating,ah.student_id,
            ah.faculty_review FROM answer_history ah JOIN question_details qd ON qd.id = ah.question_id AND ah.student_id = ".$_GET["user"].") a 
            JOIN (SELECT fid,fn,ln FROM faculty) b ON a.fid = b.fid;";

            if($res->num_rows == 0){
                header("Content-Type:application/json");
                http_response_code(400);
                echo json_encode(array("message"=>"No Questions found","total"=>0));
            }
            else{
                $response = array();

                while($row = $res->fetch_assoc()){
                    array_push($response,array("id"=>$row["id"],"question"=>$row["question"],"answer"=>$row["answer"],
                    "feedback"=>$row["feedback"],"facultyName"=>$row["faculty_id"],"userRating"=>$row["user_rating"],
                    "facultyReview"=>$row["faculty_review"]));
                }
                header("Content-Type:application/json");
                http_response_code(200);
                echo json_encode(array("message"=>"Questions found","total"=>$res->num_rows,"body"=>$response));
            }
        }
        
        
    }

    else if(isset($_GET["course"]) && isset($_GET["sem"])){
        echo "Hello";
        $sql = "SELECT fn,ln,enroll FROM `student` WHERE sem = ".$_GET["sem"]." AND course = '".($_GET["course"] == "Diploma")?'d':'b'."' AND enroll IN (SELECT student_id FROM `answer_history` WHERE feedback IS NULL);";
        echo $sql;
        $res = $conn->query($sql);

        if($res->num_rows == 0){
            header("Content-Type:application/json");
            http_response_code(400);
            echo json_encode(array("message"=>"No Data found","total"=>0));
        }
        else{
            $response = array();

                while($row = $res->fetch_assoc()){
                    $name = ucfirst($row["fn"])." ".ucfirst($row["ln"]);
                    $enroll = $row["enroll"];
                    array_push($response,array("id"=>$enroll,"name"=>$name));
                }
                header("Content-Type:application/json");
                http_response_code(200);
                echo json_encode(array("message"=>"Users found","total"=>$res->num_rows,"body"=>$response));
        }
    }

    else if(isset($_GET["student"]) && isset($_GET["type"]) && isset($_GET["userType"])){
        $sql = "SELECT * FROM (SELECT ah.id id,ah.question_id as qid,ah.answer answer,ah.user_rating user_rating,s.fn fn,s.ln,ah.student_id FROM 
        `answer_history` ah JOIN `student` s ON student_id = s.enroll AND ah.feedback IS NULL AND ah.student_id = '".$_GET["student"]."') a JOIN 
        (SELECT qd.question,qd.id FROM `question_details` qd) b ON a.qid = b.id;";

        $res = $conn->query($sql);

        if($res->num_rows == 0){
            header("Content-Type:application/json");
            http_response_code(404);
            echo json_encode(array("message"=>"No Data found","total"=>0));
        }
        else{
                $response = array();

                while($row = $res->fetch_assoc()){
                    array_push($response,array("id"=>$row["id"],"question"=>$row["question"],"answer"=>$row["answer"],
                    "userRating"=>$row["user_rating"]));
                }
                header("Content-Type:application/json");
                http_response_code(200);
                echo json_encode(array("message"=>"Questions found","total"=>$res->num_rows,"body"=>$response));
        }
    }
}
else if($_SERVER["REQUEST_METHOD"] == "POST"){

    if(isset($_POST["question_id"]) && isset($_POST["answer"]) && isset($_POST["rating"]) && isset($_POST["id"])){
        $sql = "INSERT INTO answer_history (question_id,answer,student_id,user_rating) VALUES (".$_POST["question_id"].",'".$_POST["answer"]."',".$_POST["id"].",".$_POST["rating"].")";
        $conn->query($sql);
        echo $sql;
    }

    else if(isset($_POST["question"]) && isset($_POST["level"]) && isset($_POST["topic"]) && isset($_POST["type"]) && isset($_POST["options"])
     && isset($_POST["correctAnswer"])){

        // $sql = $conn->prepare("INSERT INTO question_details(`question`,`type_id`,`topic_id`,`level`) VALUES(?,?,?,?)");
        $type = 1;
        if($_POST["type"] == "WRITTEN"){
            $type = 2;
        }

        $sql = "INSERT INTO question_details(`question`,`type_id`,`topic_id`,`level`) VALUES('".$_POST["question"]."',".$type.",".$_POST["topic"].",".$_POST["level"].")";
        $conn->query($sql);

        // $sql->bind_param("siii",$_POST["question"],$type,$_POST["topic"],$_POST["level"]);
        // $quesId = $sql->insert_id;
        $quesId = $conn->insert_id;
        
        
        if($_POST["type"] == "MCQ"){
            $correctId = 0;
            $optionsString = $_POST["options"];
            $optionsString = substr($optionsString,1,-1);
            $arr = explode("/////",$optionsString);

            for($i=0; $i<count($arr); $i++){
                // $sql = $conn->prepare("INSERT INTO mcq_options(`question_id`,`choice`) VALUES(?,?)");
                // $sql->bind_param("is",$quesId,$arr[0]);
                // $sql->execute();
                $sql = "INSERT INTO mcq_options(`question_id`,`choice`) VALUES(".$quesId.",'".$arr[$i]."')";
                
                $conn->query($sql);
                if($arr[$i] == $_POST["correctAnswer"]){
                    // $correctId = $sql->insert_id;
                    $correctId = $conn->insert_id;
                }
            }

            // $sql = $conn->prepare("INSERT INTO question_answer_relation VALUES(?,?)");
            // $sql->bind_param("ii",$quesId,$correctId);
            // $sql->execute();
            $sql = "INSERT INTO question_answer_relation VALUES(".$quesId.",".$correctId.")";
            $conn->query($sql);
        }
        else{
            $sql = "INSERT INTO descriptive_answer(q_id,answer) VALUES (".$quesId.",'".$_POST["correctAnswer"]."')";
            $conn->query($sql);
        }
        
        header("Content-Type:application/json");
        http_response_code(201);
        echo json_encode(array("message"=>"Question Added Successfully","question_id"=>$quesId));
    }
    
    else if(isset($_POST["data"])){
        $data = json_decode($_POST["data"],true);
        $questions = $data["questions"];
        $total = $data["total"];

       for($i = 0; $i< $total; $i++){
            $q = $questions[$i];

            $type = 1;
            if($q["type"] == "WRITTEN"){
                $type = 2;
            }

            $sql = "INSERT INTO question_details(`question`,`type_id`,`topic_id`,`level`) VALUES('".$q["question"]."',".$type.",".$q["topic"]["id"].",".$q["level"].")";
            $conn->query($sql);
            $quesId = $conn->insert_id;
        
        
            if($q["type"] == "MCQ"){
                $correctId = 0;
                $optionsString = implode("/////",$q["options"]);
                //$optionsString = substr($optionsString,1,-1);
                $arr = explode("/////",$optionsString);

                for($j=0; $j<count($arr); $j++){
                    $sql = "INSERT INTO mcq_options(`question_id`,`choice`) VALUES(".$quesId.",'".$arr[$j]."')";
                    
                    $conn->query($sql);
                    if($arr[$j] == $q["correctAnswer"]){
                        // $correctId = $sql->insert_id;
                        $correctId = $conn->insert_id;
                    }
                }
                $sql = "INSERT INTO question_answer_relation VALUES(".$quesId.",".$correctId.")";
                $conn->query($sql);
            }
       }

        header("Content-Type:application/json");
        http_response_code(201);
        echo json_encode(array("message"=>"Question Added Successfully"));
    }
    else{
        header("Content-Type:application/json");
        http_response_code(400);
        echo json_encode(array("message"=>"Empty Fields"));
    }
}
else if($_SERVER["REQUEST_METHOD"] == "PATCH"){
    $_PATCH = [];
    parse_str(file_get_contents('php://input'), $_PATCH);
    parse_raw_http_request($_PATCH);

    if(isset($_GET["q_id"]) && isset($_PATCH["question"]) && isset($_PATCH["level"]) && isset($_PATCH["topic"]) && isset($_PATCH["type"]) && isset($_PATCH["options"])
     && isset($_PATCH["correctAnswer"])){
        $sql = $conn->prepare("DELETE FROM question_details WHERE id = ?");
        $sql->bind_param("i",$_GET["q_id"]);
        if($sql->execute()){
            header("Content-Type:application/json");
            http_response_code(200);

        // $sql = $conn->prepare("INSERT INTO question_details(`question`,`type_id`,`topic_id`,`level`) VALUES(?,?,?,?)");
        $type = 1;
        if($_PATCH["type"] == "WRITTEN"){
            $type = 2;
        }

        $sql = "INSERT INTO question_details(`question`,`type_id`,`topic_id`,`level`) VALUES('".$_PATCH["question"]."',".$type.",".$_PATCH["topic"].",".$_PATCH["level"].")";
        $conn->query($sql);

        // $sql->bind_param("siii",$_POST["question"],$type,$_POST["topic"],$_POST["level"]);
        // $quesId = $sql->insert_id;
        $quesId = $conn->insert_id;
        
        
        if($_PATCH["type"] == "MCQ"){
            $correctId = 0;
            $optionsString = $_PATCH["options"];
            $optionsString = substr($optionsString,1,-1);
            $arr = explode("/////",$optionsString);

            for($i=0; $i<count($arr); $i++){
                // $sql = $conn->prepare("INSERT INTO mcq_options(`question_id`,`choice`) VALUES(?,?)");
                // $sql->bind_param("is",$quesId,$arr[0]);
                // $sql->execute();
                $sql = "INSERT INTO mcq_options(`question_id`,`choice`) VALUES(".$quesId.",'".$arr[$i]."')";
                
                $conn->query($sql);
                if($arr[$i] == $_PATCH["correctAnswer"]){
                    // $correctId = $sql->insert_id;
                    $correctId = $conn->insert_id;
                }
            }

            // $sql = $conn->prepare("INSERT INTO question_answer_relation VALUES(?,?)");
            // $sql->bind_param("ii",$quesId,$correctId);
            // $sql->execute();
            $sql = "INSERT INTO question_answer_relation VALUES(".$quesId.",".$correctId.")";
            $conn->query($sql);

        }
        else{
            $sql = "INSERT INTO descriptive_answer(q_id,answer) VALUES (".$quesId.",'".$_PATCH["correctAnswer"]."')";
            $conn->query($sql);
        }
        
        header("Content-Type:application/json");
        http_response_code(200);
        echo json_encode(array("message"=>"Question Updated Successfully"));    
        }
    }
    else{
        header("Content-Type:application/json");
        http_response_code(400);
        echo json_encode(array("message"=>"Empty Fields"));
    }
}
else if($_SERVER["REQUEST_METHOD"] == "DELETE"){
    if(isset($_GET["q_id"])){
        $sql = $conn->prepare("SELECT * FROM question_details WHERE id = ?");
        $sql->bind_param("i",$_GET["q_id"]);

        $sql->execute();
        $res = $sql->get_result();

        if($res->num_rows == 0){
            header("Content-Type:application/json");
            http_response_code(404);
            echo json_encode(array("message"=>"Question Not Found"));
        }
        else{
            $sql = $conn->prepare("DELETE FROM question_details WHERE id = ?");
            $sql->bind_param("i",$_GET["q_id"]);
            if($sql->execute()){
                header("Content-Type:application/json");
                http_response_code(200);
                echo json_encode(array("message"=>"Question Deleted Successfully"));    
            }
        }        
    }
    else{
         header("Content-Type:application/json");
        http_response_code(400);
        echo json_encode(array("message"=>"Empty Fields"));
    }
}


?>