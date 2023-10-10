<?php
include "./dbconn.php";
const DUPLICATE_KEY_NO = 1062;
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PATCH, DELETE");

if($_SERVER["REQUEST_METHOD"] == "POST"){
    if(isset($_POST["email"]) && isset($_POST["pswd"])){
        $email = $_POST["email"];
        $pwd = $_POST["pswd"];
        $sql = $conn->prepare("SELECT fn,ln FROM student WHERE email = ? AND pswd = ?");
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
            echo json_encode(array("message"=>"User Found","body"=>array("email"=>$email,"Name"=>$name)));
        }
    }
    else{
        header("Content-Type:application/json");
        http_response_code(400);
        echo json_encode(array("message"=>"Empty Fields"));
    }
}


?>