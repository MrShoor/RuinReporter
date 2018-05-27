<?php
require 'db_connect.php';

$input_json = filter_input(INPUT_POST, 'data');
if (empty($input_json)) {
    die('No input data');
}

$data = json_decode($input_json, true, 4);
if (empty($data)) {
    die('Bad json');
}

$mysql_conn = new mysqli($mysql_servername, $mysql_username, $mysql_password, $mysql_dbname);
if ($mysql_conn->connect_error) {
    die("Connection failed: (".$mysql_conn->connect_errno.") ".$mysql_conn->connect_error);
} 

$mysql_stmt = $mysql_conn->prepare("INSERT INTO tbl_reports (UserID, Object, Message, Stack) VALUES (?,?,?,?)");
if (!$mysql_stmt) {
    die("Prepare statement failed: (".$mysql_conn->errno.") ".$mysql_conn->error);
}

if (!$mysql_stmt->bind_param('ssss', $data['UserID'], $data['Object'], $data['Message'], $data['Stack'])) {
    die("Bind params failed: (".$mysql_conn->errno.") ".$mysql_conn->error);
}

if (!$mysql_stmt->execute()) {
    die("Executre failed: (".$mysql_conn->errno.") ".$mysql_conn->error);
}

echo 'OK';
?>