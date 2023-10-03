<?php
include "./dbconn.php";
const DUPLICATE_KEY_NO = 1062;
header("Access-Control-Allow-Origin: *");


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
    }
    
    else if(isset($_GET["t_id"]) && isset($_GET["type"]) && $_GET["type"] == "WRITTEN"){
        $sql = $conn->prepare("SELECT * FROM question_details WHERE topic_id = ? AND type_id = ?");
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
                array_push($response,array("id"=>$data["id"],"question"=>$data["question"],"type"=>"WRITTEN","level"=>$data["level"]));
            }
            header("Content-Type:application/json");
            http_response_code(200);
            echo json_encode(array("message"=>"Questions found","total"=>$res->num_rows,"body"=>$response));
        }
    }

    else if(isset($_GET["t_id"]) && isset($_GET["type"]) && $_GET["type"] == "MCQ"){
        $sql = $conn->prepare("SELECT * FROM (SELECT qd.id as id,qd.question as question,qd.topic_id as topic_id,qd.level as level,
        GROUP_CONCAT(mo.choice) as `choices`FROM `question_details` qd JOIN `mcq_options` mo ON qd.id = mo.question_id JOIN 
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
                "options"=>explode(",",$data["choices"]),"correctAnswer"=>$data["choice"]));
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
    else{

    }
}
else if($_SERVER["REQUEST_METHOD"] == "POST"){
    if(isset($_POST["question"]) && isset($_POST["level"]) && isset($_POST["topic"]) && isset($_POST["type"]) && isset($_POST["options"])
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
        
        header("Content-Type:application/json");
        http_response_code(201);
        echo json_encode(array("message"=>"Question Added Successfully","question_id"=>$quesId));
    }
    else if(isset($_POST["total"]) && isset($_POST["questions"])){
        $questions = $_POST["questions"];
        $total = $_POST["total"];

        print_r($questions);
        // print_r(json_decode($questions));
        // for($i = 0; $i<$total; $i++){
        //     echo($questions[$i]);
        // }

        header("Content-Type:application/json");
        
    }
    else{
        header("Content-Type:application/json");
        http_response_code(400);
        echo json_encode(array("message"=>"Empty Fields"));
    }
}
else if($_SERVER["REQUEST_METHOD"] == "PATCH"){

}
else if($_SERVER["REQUEST_METHOD"] == "DELETE"){

}


?>