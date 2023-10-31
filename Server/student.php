<?php
include "./dbconn.php";
const DUPLICATE_KEY_NO = 1062;
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PATCH, DELETE");

if($_SERVER["REQUEST_METHOD"] == "GET"){
    if(isset($_GET["course"]) && isset($_GET["sem"])){
        $sql = "SELECT fn,ln,enroll FROM `student` WHERE sem = ".$_GET["sem"]." AND course = '".$_GET["course"]."' 
        AND enroll IN (SELECT student_id FROM `answer_history` WHERE feedback IS NULL);";
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

}

else if($_SERVER["REQUEST_METHOD"] == "POST"){
    if(isset($_POST["email"]) && isset($_POST["pswd"])){
        $email = $_POST["email"];
        $pwd = $_POST["pswd"];
        $sql = $conn->prepare("SELECT fn,ln FROM student WHERE enroll = ? AND pswd = ?");
        $sql->bind_param("ss",$email,$pwd);
        $sql->execute();

        $res = $sql->get_result();

        if($res->num_rows == 0){
            $sql = $conn->prepare("SELECT fn,ln FROM faculty WHERE fid = ? AND pswd = ?");
            $sql->bind_param("ss",$email,$pwd);
            $sql->execute();

            $res = $sql->get_result();
            if($res->num_rows == 0){
                header("Content-Type:application/json");
                http_response_code(404);
                echo json_encode(array("message"=>"User Not Found"));
            }
            else{
                $data = $res->fetch_assoc();
                $name = ucfirst($data["fn"]) ." ". ucfirst($data["ln"]);
                header("Content-Type:application/json");
                http_response_code(200);
                echo json_encode(array("message"=>"User Found","body"=>array("id"=>$email,"Name"=>$name,"user"=>"Faculty")));    
            }
            
        }
        else{
            $data = $res->fetch_assoc();
            $name = ucfirst($data["fn"]) ." ". ucfirst($data["ln"]);
            header("Content-Type:application/json");
            http_response_code(200);
            echo json_encode(array("message"=>"User Found","body"=>array("id"=>$email,"Name"=>$name,"user"=>"Student")));
        }
    }
    else{
        header("Content-Type:application/json");
        http_response_code(400);
        echo json_encode(array("message"=>"Empty Fields"));
    }
}


?>