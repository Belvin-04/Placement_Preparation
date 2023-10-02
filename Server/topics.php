<?php
include "./dbconn.php";
const DUPLICATE_KEY_NO = 1062;
header("Access-Control-Allow-Origin: *");
if($_SERVER['REQUEST_METHOD'] == "GET"){
    if(isset($_GET["id"])){

    }
    else{
        $sql = $conn->prepare("SELECT * FROM topics");
        $sql->execute();
        $res = $sql->get_result();
        

        if($res->num_rows == 0){
            
            header("Content-Type:application/json");
            http_response_code(204);
        }
        else{
            $response = array();
            while($data = $res->fetch_assoc()){
                array_push($response,array("id"=>$data["id"],"name"=>$data["name"]));
            }
            header("Content-Type:application/json");
            http_response_code(200);
            echo json_encode(array("message"=>"Topics found","total"=>$res->num_rows,"body"=>$response));
        }
    }
}

else if($_SERVER['REQUEST_METHOD'] == "POST"){
    if(isset($_POST['name'])){
        try{
            $sql = $conn->prepare("INSERT INTO topics(`name`) VALUES(?)");
            $sql->bind_param("s",$_POST["name"]);
            
            if($sql->execute()){
                header("Content-Type:application/json");
                http_response_code(201);
                echo json_encode(array("message"=>"Topic Added Successfully","topic_id"=>$sql->insert_id));
            }
            else if($conn->errno == DUPLICATE_KEY_NO){
                header("Content-Type:application/json");
                http_response_code(409);
                echo json_encode(array("message"=>"Duplicate Entry"));
            }
            
        }
        catch(mysqli_sql_exception $e){
            echo $e->getMessage();
            die;
        }
    }
    else{
        header("Content-Type:application/json");
        http_response_code(400);
        echo json_encode(array("message"=>"Empty Fields"));
    }
}

else if($_SERVER['REQUEST_METHOD'] == "PATCH"){
    if(isset($_POST['name']) && isset($_POST['id'])){
        try{
            $sql = $conn->prepare("UPDATE topics SET name = ? WHERE id = ?");
            $sql->bind_param("si",$_POST["name"],$_POST["id"]);
            
            if($sql->execute()){
                header("Content-Type:application/json");
                http_response_code(201);
                echo json_encode(array("message"=>"Topic Updated Successfully","topic_id"=>$sql->insert_id));
            }
            else if($conn->errno == DUPLICATE_KEY_NO){
                header("Content-Type:application/json");
                http_response_code(409);
                echo json_encode(array("message"=>"Duplicate Entry"));
            }
        }catch(mysqli_sql_exception $e){
            echo $e->getMessage();
            die;
        }
    }
    else{
        header("Content-Type:application/json");
        http_response_code(400);
        echo json_encode(array("message"=>"Empty Fields"));
    }
}

else if($_SERVER['REQUEST_METHOD'] == "DELETE"){

}

?>