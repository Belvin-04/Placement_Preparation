<?php
include "./dbconn.php";
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PATCH, DELETE");

$conn->query("CALL `clearDatabase`(@p0);");
$res = $conn->query("SELECT @p0 AS `status`");

if($res->num_rows != 0){
    echo "DONE";
}


?>