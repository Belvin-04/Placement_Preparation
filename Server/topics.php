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
    $_PATCH = [];
    parse_str(file_get_contents('php://input'), $_PATCH);
    parse_raw_http_request($_PATCH);

    if(isset($_PATCH['name']) && isset($_PATCH['id'])){
        try{
            $sql = $conn->prepare("UPDATE topics SET name = ? WHERE id = ?");
            $sql->bind_param("si",$_PATCH["name"],$_PATCH["id"]);
            
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
    if(isset($_GET["t_id"])){
        $sql = $conn->prepare("SELECT * FROM topics WHERE id = ?");
        $sql->bind_param("i",$_GET["t_id"]);

        $sql->execute();
        $res = $sql->get_result();

        if($res->num_rows == 0){
            header("Content-Type:application/json");
            http_response_code(404);
            echo json_encode(array("message"=>"Topic Not Found"));
        }
        else{
            $sql = $conn->prepare("DELETE FROM topics WHERE id = ?");
            $sql->bind_param("i",$_GET["t_id"]);
            if($sql->execute()){
                header("Content-Type:application/json");
                http_response_code(200);
                echo json_encode(array("message"=>"Topic Deleted Successfully"));    
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