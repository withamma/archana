<?php
	$url = 'https://api.quizlet.com/2.0/sets';
	$data = json_decode(file_get_contents("php://input"));
	$curl = curl_init($url);
	curl_setopt($curl, CURLOPT_HTTPHEADER, array('Authorization: Bearer 314b1f8b590fbf8b123ff778fc7915863e81df23'));
	curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($curl, CURLOPT_POSTFIELDS, http_build_query($data));
	header('Content-Type: application/json');
	echo curl_exec($curl);
	curl_close($curl);
?>
