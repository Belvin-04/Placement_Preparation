<?php
include "./dbconn.php";
const DUPLICATE_KEY_NO = 1062;
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PATCH, DELETE");

if($_SERVER["REQUEST_METHOD"] == "GET"){
    if(isset($_GET["check"]) && isset($_GET["questionId"]) && isset($_GET["faculty_id"])){

        // $sql = $conn->prepare("SELECT aa.id,aa.answer,aa.user_rating,aa.student_id,CONCAT(UCASE(LEFT(s.fn, 1)), LCASE(SUBSTRING(s.fn, 2)),' ',UCASE(LEFT(s.ln, 1)), LCASE(SUBSTRING(s.ln, 2))) as name FROM (SELECT a.id,a.answer,a.user_rating,a.student_id FROM 
        //                         (SELECT * FROM `answer_history` ah WHERE question_id = ?) a
        //                             LEFT JOIN `faculty_feedback` ff 
        //                         ON a.id = ff.answer_id AND ff.id != ?) aa JOIN student s ON aa.student_id = s.enroll;;");

        // $sql = $conn->prepare("SELECT ah.*,CONCAT(UCASE(LEFT(s.fn, 1)), LCASE(SUBSTRING(s.fn, 2)),' ',UCASE(LEFT(s.ln, 1)), LCASE(SUBSTRING(s.ln, 2))) as name FROM `faculty_feedback` ff 
        //                 RIGHT JOIN `answer_history` ah 
        //                 ON ff.answer_id = ah.id 
        //                 JOIN `student` s ON ah.student_id = s.enroll
        //                 WHERE ah.question_id = ? AND (ff.faculty_id IS NULL OR ff.faculty_id != ?);");

        $sql = $conn->prepare("SELECT ah.*,CONCAT(UCASE(LEFT(s.fn, 1)), LCASE(SUBSTRING(s.fn, 2)),' ',UCASE(LEFT(s.ln, 1)), LCASE(SUBSTRING(s.ln, 2))) as name FROM `faculty_feedback` ff 
                        RIGHT JOIN `answer_history` ah 
                        ON ff.answer_id = ah.id AND ff.faculty_id = ?
                        JOIN `student` s ON ah.student_id = s.enroll
                        WHERE ah.question_id = ? AND (ff.faculty_id IS NULL);");

        $sql->bind_param("ss",$_GET["faculty_id"],$_GET["questionId"]);
        $sql->execute();
        $res = $sql->get_result();
        
        if($res->num_rows == 0){
            header("Content-Type:application/json");
            http_response_code(204);
        }
        else{
            $response = array();
            while($row = $res->fetch_assoc()){
                array_push($response,array("id"=>$row["id"],"answer"=>$row["answer"],"userRating"=>$row["user_rating"],"studentName"=>$row["name"]));
            }
            header("Content-Type:application/json");
            http_response_code(200);
            echo json_encode(array("message"=>"Responses found","total"=>$res->num_rows,"body"=>$response));
        }
        

    }

    else if(isset($_GET["questionId"]) && isset($_GET["faculty_id"]) && isset($_GET["checkColor"])){
        // $sql = $conn->prepare("SELECT aa.id,aa.answer,aa.user_rating,aa.student_id,CONCAT(UCASE(LEFT(s.fn, 1)), LCASE(SUBSTRING(s.fn, 2)),' ',UCASE(LEFT(s.ln, 1)), LCASE(SUBSTRING(s.ln, 2))) as name FROM (SELECT a.id,a.answer,a.user_rating,a.student_id FROM 
        //                         (SELECT * FROM `answer_history` ah WHERE question_id = ?) a
        //                             LEFT JOIN `faculty_feedback` ff 
        //                         ON a.id = ff.answer_id AND ff.id != ?) aa JOIN student s ON aa.student_id = s.enroll;;");

        $sql = $conn->prepare("SELECT ah.*,CONCAT(UCASE(LEFT(s.fn, 1)), LCASE(SUBSTRING(s.fn, 2)),' ',UCASE(LEFT(s.ln, 1)), LCASE(SUBSTRING(s.ln, 2))) as name FROM `faculty_feedback` ff 
                        RIGHT JOIN `answer_history` ah 
                        ON ff.answer_id = ah.id AND ff.faculty_id = ?
                        JOIN `student` s ON ah.student_id = s.enroll
                        WHERE ah.question_id = ? AND (ff.faculty_id IS NULL);");

        $sql->bind_param("ss",$_GET["faculty_id"],$_GET["questionId"]);
        $sql->execute();
        $res = $sql->get_result();
        header("Content-Type:application/json");
        echo json_encode(array("total"=>$res->num_rows));
    }

    else{
        header("Content-Type:application/json");
        http_response_code(400);
        echo json_encode(array("message"=>"Empty Fields"));
    }
}

else if($_SERVER["REQUEST_METHOD"] == "POST"){
    if(isset($_POST["id"]) && isset($_POST["faculty_id"]) && isset($_POST["faculty_rating"]) && isset($_POST["faculty_feedback"])){
        $sql = "INSERT INTO faculty_feedback (answer_id,faculty_id,rating,review) VALUES (".$_POST["id"].",".$_POST["faculty_id"].",".$_POST["faculty_rating"].",'".$_POST["faculty_feedback"]."')";
        $conn->query($sql);
    }

    else if(isset($_POST["tid"]) && isset($_POST["sid"])){
        $sql = $conn->prepare("SELECT qd.question,da.answer as stdAns,ah.answer,ah.user_rating,ff.rating,ff.review,CONCAT('Prof. ',UCASE(LEFT(s.fn, 1)), LCASE(SUBSTRING(s.fn, 2)),' ',UCASE(LEFT(s.ln, 1)), LCASE(SUBSTRING(s.ln, 2))) as name FROM `faculty_feedback` ff 
                        JOIN `answer_history` ah 
                        ON ff.answer_id = ah.id
                        JOIN `faculty` s ON ff.faculty_id = s.fid
                        JOIN `question_details` qd ON ah.question_id = qd.id
                        JOIN `descriptive_answer` da ON da.q_id = qd.id
                        WHERE qd.topic_id = ? AND ah.student_id = ?;");

        $sql->bind_param("is",$_POST["tid"],$_POST["sid"]);
        $sql->execute();
        $res = $sql->get_result();
        $response = array();
        if($res->num_rows == 0){
            header("Content-Type:application/json");
            http_response_code(204);
        }
        else{
            $response = array();
            while($row = $res->fetch_assoc()){
                array_push($response,array("question"=>$row["question"],"stdAnswer"=>$row["stdAns"],"answer"=>$row["answer"],"userRating"=>$row["user_rating"],"rating"=>$row["rating"],"review"=>$row["review"],"name"=>$row["name"]));
            }
            header("Content-Type:application/json");
            http_response_code(200);
            echo json_encode(array("message"=>"Responses found","total"=>$res->num_rows,"body"=>$response));
        }

    }

    else{
        header("Content-Type:application/json");
        http_response_code(400);
        echo json_encode(array("message"=>"Empty Fields"));
    }
}

?>