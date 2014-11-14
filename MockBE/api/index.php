<?php

define('DEFAULTUSECASE','PRIVATE');

define('USECASEBUSINESS','BUSINESS');
define('USECASEPRIVATE','PRIVATE');
define('USECASEBOTH','BOTH');

require 'Slim/Slim.php';

$app = new Slim();

$app->post('/userToken', 'getUserTokenForEmail');
$app->post('/addPaymentInstrument', 'addPaymentInstrumentForUserToken');
$app->post('/listPaymentInstruments', 'listPaymentInstrumentsForUserToken');
$app->post('/setPaymentInstrumentsOrder', 'setPIOrderForUserToken');
$app->post('/removePaymentInstrumentForUseCase', 'removePaymentInstrumentForUseCase');
$app->post('/disablePaymentInstrument', 'disablePaymentInstrumentForUserToken');
$app->response()->header('Connection','close');

$app->run();



function getUserTokenForEmail() {

    $request = Slim::getInstance()->request();

    # error_log('RequestBody Staging:'.$request->getBody());

	$details = json_decode($request->getBody());
	
	if (!isset($details->bundleID)) {
		returnErrorWithDescription('Missing bundleID value in Request');
		return;
	}
	
	if (!isset($details->version)) {
		returnErrorWithDescription('Missing version value in Request');
		return;
	}
	
	if (!isset($details->email)) {
		returnErrorWithDescription('Missing email value in Request');
		return;
	}
	
	$apiKey = getAPIKeyForBundleAndVersion($details->bundleID,$details->version);
	
	if($apiKey and checkHMACForRequestAndSeed($details,$apiKey)) {
			
	       error_log('ApiKey: '. $apiKey);
	
		   # TODO check HMAC for this APIKey
		   
            $sql = "SELECT userToken FROM USERS WHERE email=:emailValue AND apiKey=:apiKeyValue";
            
            try {
                $db = getConnection();
                $stmt = $db->prepare($sql);  
                $stmt->bindParam("emailValue", $details->email);
                $stmt->bindParam("apiKeyValue", $apiKey);
                $stmt->execute();
                $token = $stmt->fetchObject();  
                $db = null;
                
                if($token) {
                        # KNOWN EMAIL FOR THIS API KEY 
						Slim::getInstance()->response()->status(200);
                        returnOKStatus(array('userToken'=>$token->userToken)); 
                } else {
                    # create new token 
                    $hash = sha1(mt_rand());
                    $token = substr($hash, 0,30);
                    $sql = "INSERT INTO USERS (userToken, email, apiKey) VALUES (:userTokenValue, :emailValue, :apiKeyValue)";
                    try {
                            $db = getConnection();
                            $stmt = $db->prepare($sql);  
                            $stmt->bindParam("userTokenValue", $token);
                            $stmt->bindParam("emailValue", $details->email);
                            $stmt->bindParam("apiKeyValue", $apiKey);
                            $stmt->execute();
        
                            if ($db->lastInsertId()) {
                                $db = null;
                                
                                returnOKStatus(array('userToken'=>$token)); 
                                
                            } else {
                                
                                returnErrorWithDescription($e->getMessage()); 
                                return;
                            }               
                            
                        } catch(PDOException $e) {
                        
                        # insert failed
                        returnErrorWithDescription($e->getMessage()); 
                        return;
                    }
                }
                
                if (isset($details->paymentInstrument)) {
                
                    # error_log('add PAyment Instruments for token '.$token->userToken);
                    
                    addPIsToUserToken($token->userToken,$details->paymentInstrument,$details->useCase);
                }

            } catch(PDOException $e) {
                returnErrorWithDescription($e->getMessage()); 
            }
         
        }
}

function returnErrorWithDescription($description) {

        error_log('returnErrorWithDescription: '. $description);
		
		$app = Slim::getInstance();
		$response = $app->response();
		$response->header('Connection', 'close');
        
        Slim::getInstance()->response()->status(400);
		
        echo json_encode(array('description'=>$description,'status'=>'KO','code'=>'400'));
}

function returnOKStatus($result) {

        Slim::getInstance()->response()->status(200);
		
		$app = Slim::getInstance();
		$response = $app->response();
		$response->header('Connection', 'close');
		
		$responseArray = array('status'=>'OK','code'=>'200');
		
		if($result) {
		
			if (is_array($result)) {
				$responseArray = array_merge($responseArray, $result);
			} else {
				array_push($responseArray,$result);
			}
		}
		
        echo json_encode($responseArray);
}

function listPaymentInstrumentsForUserToken() {

    $request = Slim::getInstance()->request();
    $details = json_decode($request->getBody());
	
	if (!checkHMACForUserTokenRequest($request)) {
		return;
	}
	
	$useCase = DEFAULTUSECASE;
	
	if (isset($details->useCase)) {
		$useCase = $details->useCase;
	}
	
	if(!checkUseCase($useCase)) {
		returnErrorWithDescription('Invalid UseCase');
		return;		
	}
			
	$userToken = $details->userToken;
	
	$piList = array();
	
	$piTokens = piTokenForUserAndUseCase($userToken,$useCase);
	
	if ($piTokens) {
		$piList['paymentInstruments'] = $piTokens;
		$piList['useCase'] = $useCase;
	}
	
	returnOKStatus($piList);
}

function piTokenForUserAndUseCase($userToken,$useCase) {
	
	$sql = "SELECT PITABLE.piDetails, PITABLE.piIndex, USECASETABLE.sortIndex FROM PITABLE INNER JOIN USECASETABLE ON PITABLE.piToken=USECASETABLE.piToken WHERE USECASETABLE.useCase=:useCaseValue AND USECASETABLE.userToken=:userTokenValue ORDER BY USECASETABLE.sortIndex";
		
     try {

         $db = getConnection();
         $stmt = $db->prepare($sql);  
         $stmt->bindParam("userTokenValue", $userToken);
		 $stmt->bindParam("useCaseValue", $useCase);

         $stmt->execute();
		 $piTokens = array();
		
         while($fetchPi = $stmt->fetchObject()) {
			 $pi = (array)json_decode($fetchPi->piDetails);
			 $pi['identifier'] = $fetchPi->piIndex;
			 $pi['sortIndex'] = $fetchPi->sortIndex;
             array_push($piTokens,$pi);   
         }
					
		return $piTokens;
				
     } catch(PDOException $e) {
    
		returnErrorWithDescription($e->getMessage());
   
     } 

	 return null;	
}



function disablePaymentInstrumentForUserToken() {
	
    $request = Slim::getInstance()->request();
    $details = json_decode($request->getBody());
	
	if (!isset($details->userToken)) {
		returnErrorWithDescription('Missing userToken value in Request');
		return;
	}
	
	if (!isset($details->paymentInstrument)) {
		returnErrorWithDescription('Missing paymentInstrument value in Request');
		return;
	}
	
	# error_log('disablePaymentInstrumentForUserToken details:'.json_encode($details));

    $userToken = $details->userToken;
    $piArray = $details->paymentInstrument;
	
    # error_log('disablePaymentInstrumentForUserToken userToken:'.json_encode($userToken));
    # error_log('disablePaymentInstrumentForUserToken piArray:'.json_encode((array)$piArray));
     
    $sql = "UPDATE PITABLE SET piEnabled=0 WHERE userToken=:userTokenValue AND piIndex=:identifierValue";
	
	# TODO update sortIndex 
	
    foreach ($piArray as $piIdentifier) {
   		
        try {
            $db = getConnection();
            $stmt = $db->prepare($sql);  
            $stmt->bindParam("userTokenValue", $userToken);
            $stmt->bindParam("identifierValue", $piIdentifier);
            $stmt->execute();
			
			# remove all useCases
			
			$removeUseCaseResult = removePaymentInstrumentForUserTokenAndUseCase($userToken,$piIdentifier,USECASEBUSINESS);
			
			$removeUseCaseResult = $removeUseCaseResult && removePaymentInstrumentForUserTokenAndUseCase($userToken,$piIdentifier,USECASEPRIVATE);
			
			if(!$removeUseCaseResult){
				returnErrorWithDescription('Error on removing pi');
			}
                
        } catch(PDOException $e) {
            returnErrorWithDescription($e->getMessage());
			return;
        }       
    }     
	
	returnOKStatus(NULL);
}

function removePaymentInstrumentForUseCase() {
	
    $request = Slim::getInstance()->request();
    $details = json_decode($request->getBody());
	
	if(!checkHMACForUserTokenRequest($request)) {
		error_log('failed hmac check on removePaymentInstrumentForUseCase');
	}
	
	if (!isset($details->paymentInstrument)) {
		returnErrorWithDescription('Missing paymentInstrument value in Request');
		return;
	}
	
	$userToken = $details->userToken;
	$pi = $details->paymentInstrument;
	$piIdentifier = $pi->identifier;
	
	$useCase = DEFAULTUSECASE;
	
	if (isset($details->useCase)) {
		$useCase = $details->useCase;
	}
	
	if(!checkUseCase($useCase)) {
		returnErrorWithDescription('Invalid UseCase');
		return;		
	}
	
	if(removePaymentInstrumentForUserTokenAndUseCase($userToken,$piIdentifier,$useCase)) {
		returnOKStatus(NULL);
		return;
	}
	
}

function removePaymentInstrumentForUserTokenAndUseCase($userToken,$piIdentifier,$useCase) {
	
	# error_log('removePaymentInstrumentForUserTokenAndUseCase details:'.json_encode($details));
	
	$sql = "SELECT u.sortIndex FROM USECASETABLE u INNER JOIN PITABLE p ON u.piToken = p.piToken WHERE (p.userToken=:userTokenValue AND p.piIndex=:piIndexValue AND u.useCase=:useCaseValue)";
	
    try {
        $db = getConnection();
        $stmt = $db->prepare($sql);  
        $stmt->bindParam("userTokenValue", $userToken);
        $stmt->bindParam("piIndexValue", $piIdentifier);
		$stmt->bindParam("useCaseValue", $useCase);
        $stmt->execute();
		
		$sortIndexResult = $stmt->fetchObject();            
    } catch(PDOException $e) {
        returnErrorWithDescription($e->getMessage());
		return false;
    } 
	
	if(!$sortIndexResult) {
		# dont found this sortIndex
		return true;
	}
	
	$sortIndex = $sortIndexResult->sortIndex;
	
	$sql = "DELETE u.* FROM USECASETABLE u INNER JOIN PITABLE p ON u.piToken = p.piToken WHERE (p.userToken=:userTokenValue AND p.piIndex=:piIndexValue AND u.useCase=:useCaseValue)";
	
    try {
        $db = getConnection();
        $stmt = $db->prepare($sql);  
        $stmt->bindParam("userTokenValue", $userToken);
        $stmt->bindParam("piIndexValue", $piIdentifier);
		$stmt->bindParam("useCaseValue", $useCase);
        $stmt->execute();
		
		return reorderUseCaseUpFromIndex($sortIndex,$useCase,$userToken);
		
    } catch(PDOException $e) {
        returnErrorWithDescription($e->getMessage());
		return false;
    }       
       
	return true;
}

function reorderUseCaseUpFromIndex($sortIndex,$useCase,$userToken) {
	
	$sql = "UPDATE USECASETABLE SET USECASETABLE.sortIndex=USECASETABLE.sortIndex-1 WHERE (USECASETABLE.userToken=:userTokenValue AND USECASETABLE.useCase=:useCaseValue AND USECASETABLE.sortIndex>=:sortIndexValue)" ;
	
    try {
        $db = getConnection();
        $stmt = $db->prepare($sql);  
        $stmt->bindParam("userTokenValue", $userToken);
        $stmt->bindParam("sortIndexValue", $sortIndex);
		$stmt->bindParam("useCaseValue", $useCase);
        $stmt->execute();
            
    } catch(PDOException $e) {
        returnErrorWithDescription($e->getMessage());
		return false;
    }

	return true;
}

function setPIOrderForUserToken() {

    $request = Slim::getInstance()->request();
	
	if(!checkHMACForUserTokenRequest($request)) {
		error_log('failed hmac check on setOrder');
	}
	
    $details = json_decode($request->getBody());
    
    $userToken = $details->userToken;
    $piArray = $details->paymentInstruments;
	
	$useCase = DEFAULTUSECASE;
	
	if (isset($details->useCase)) {
		$useCase = $details->useCase;
	}
	
	if(!checkUseCase($useCase)) {
		returnErrorWithDescription('Invalid UseCase');
		return;		
	}
	
	if(Count($piArray) == countPiUseCasesForUserToken($userToken,$useCase)) {
     
		$updated = 0;
	    foreach ($piArray as $pi) {
		
	        $piIdentifier = $pi->identifier;
			
			$sql = "SELECT PITABLE.piToken FROM PITABLE WHERE userToken=:userTokenValue AND piIndex=:piIndexValue";
    
	        try {

	            $db = getConnection();
	            $stmt = $db->prepare($sql);  
	            $stmt->bindParam("userTokenValue", $userToken);
	            $stmt->bindParam("piIndexValue", $piIdentifier);
	            $stmt->execute();
				
				$piTokenReq = $stmt->fetchObject();
				
				if($piTokenReq) {
					
					$sortIndex = $pi->sortIndex;
					$piToken = $piTokenReq->piToken;
					
					$sql = "UPDATE USECASETABLE SET USECASETABLE.sortIndex=:sortIndexValue WHERE USECASETABLE.userToken=:userTokenValue AND USECASETABLE.piToken=:piTokenValue";
					
					try {
						
			            $db = getConnection();
			            $stmt = $db->prepare($sql);  
			            $stmt->bindParam("userTokenValue", $userToken);
			            $stmt->bindParam("piTokenValue", $piToken);
						$stmt->bindParam("sortIndexValue", $sortIndex);
			            $stmt->execute();
						
						$updated = $updated+1;
						
					} catch (PDOException $e) {
                        returnErrorWithDescription($e->getMessage());
                        return;
                    }
				}
				
                
	        } catch(PDOException $e) {
	            returnErrorWithDescription($e->getMessage());
				return;
	        }       
	    }     
	
		returnOKStatus(array('reorderd'=> (string)$updated));
		
	}else {
		returnErrorWithDescription('Need to set sortIndex for all PI');
	}
}

function addPaymentInstrumentForUserToken() {

    $request = Slim::getInstance()->request();
    $details = json_decode($request->getBody());
	
	if (!checkHMACForUserTokenRequest($request)) {
		return;
	}
	
	if (!isset($details->paymentInstrument)) {
		returnErrorWithDescription('Missing paymentInstrument value in Request');
		return;
	}
	
	if (!isset($details->userToken)) {
		returnErrorWithDescription('Missing userToken value in Request');
		return;
	}
	
	$useCase = DEFAULTUSECASE;
	
	if (isset($details->useCase)) {
		$useCase = $details->useCase;
	}
	
	$piArray = array();
	
	if (is_array($details->paymentInstrument)) {
		$piArray = array_merge($piArray, $details->paymentInstrument);
	} else {
		array_push($piArray,$details->paymentInstrument);
	}

    if(addPIsToUserToken($details->userToken,$piArray,$useCase)) {
        returnOKStatus(NULL);
    } else {
		$errorMessage = 'can’t add PIS';
        returnErrorWithDescription($errorMessage);
    }
    
}

function addPIsToUserToken($userToken,$piArray,$useCase) {

    # error_log('addPIsToUserToken userToken:'.json_encode($userToken));
    # error_log('addPIsToUserToken piArray:'.json_encode($piArray));

	if(!checkUserToken($userToken)) {
		return;
	}
	
	foreach ($piArray as $pi) {
		
       	$piDetails =  json_encode($pi);
		addPI($userToken,$piDetails,$useCase);
    }
    
    return true;
}

function addPI($userToken,$piDetails,$useCase) {
	
    $piIdentifier = createIdentifier($userToken,$piDetails);

    if(checkPiIdentifier($piIdentifier)) {
		 
         $piHash = sha1(mt_rand());
         $piToken = substr($piHash, 0,30);

		return addPIWithDetails ($piToken,$piIdentifier,$userToken,$piDetails,$useCase);

     } else {
     	
		 #known pi ... make sure is enabled
		 
	     $sql = "UPDATE PITABLE SET piEnabled=1 WHERE (userToken=:userTokenValue AND identifier=:identifierValue)";
	 
	 	# error_log('UPDATE PITABLE SET piEnabled=1 WHERE (userToken='.$userToken.' AND identifier='.$piIdentifier.')');
		
         try {
             $db = getConnection();
             $stmt = $db->prepare($sql);  
             $stmt->bindParam("userTokenValue", $userToken);
             $stmt->bindParam("identifierValue", $piIdentifier);
             $stmt->execute();
			 
			 $result = $stmt->fetchObject();
            
         } catch(PDOException $e) {
             returnErrorWithDescription($e->getMessage());
 			return;
         }       
		 
		 #known pi ... so check if this useCase is known
		 
		 $piToken = getPiTokenForPiIdentifier($piIdenfifier);
		 
		 addPIToUseCaseTable($piToken,$userToken,$useCase);
		
     }
	 
	 # already known pi
	 return true;
}

function addPIWithDetails ($piTokenValue,$piIdentifier,$userTokenValue,$piDetailsValue,$useCaseValue) {
	
	$piIndexValue = countPiForUserToken($userTokenValue);
	
    $sql = "INSERT INTO PITABLE (piToken,identifier,userToken, piDetails, piIndex) VALUES (:piTokenValue,:piIdentifierValue, :userTokenValue, :piDetailsValue, :piIndexValue)";
    
    try {
            $db = getConnection();
            $stmt = $db->prepare($sql);  
			
			$stmt->bindParam("piTokenValue", $piTokenValue);
            $stmt->bindParam("piIdentifierValue", $piIdentifier);						
            $stmt->bindParam("userTokenValue", $userTokenValue);
            $stmt->bindParam("piDetailsValue",$piDetailsValue);
			$stmt->bindParam("piIndexValue",$piIndexValue);
            $stmt->execute();

        } catch(PDOException $e) {
        
            # insert failed
            Slim::getInstance()->response()->status(400);
            
            $errorCode = $e->getCode();
            
            if($errorCode == 23000) {
                echo '{"error":{"text":"already know pi"}}';
            } else {
                echo '{"error":{"text":'. $e->getMessage() .'}}';
            }
            return false;
        }
		
	# add to useCase Table
	
	if (is_null($useCaseValue)) {
		$useCaseValue = DEFAULTUSECASE;
	}
		
	$result = false;
		
	$result = addPIToUseCaseTable($piTokenValue,$userTokenValue,$useCaseValue);

	return $result;
}

function addPIToUseCaseTable($piTokenValue,$userTokenValue,$useCaseValue) {
	
	$sortIndex = countPiUseCasesForPiTokenAndUserToken($userTokenValue,$piTokenValue,$useCaseValue);
	
	if ($sortIndex < 0) {
		# known useCase
		return true;
	}
			
	$sql = "INSERT INTO USECASETABLE ( piToken, userToken, useCase, sortIndex) VALUES ( :piTokenValue, :userTokenValue, :useCaseValue, :sortIndexValue)";

    try {
            $db = getConnection();
            $stmt = $db->prepare($sql);  
		
			$stmt->bindParam("piTokenValue", $piTokenValue);						
            $stmt->bindParam("userTokenValue", $userTokenValue);
			$stmt->bindParam("useCaseValue", $useCaseValue);
	        $stmt->bindParam("sortIndexValue", $sortIndex);
            $stmt->execute();

        } catch(PDOException $e) {
    
            # insert failed
            Slim::getInstance()->response()->status(400);
        
            $errorCode = $e->getCode();
        
            if($errorCode == 23000) {
                echo '{"error":{"text":"already know pi"}}';
            } else {
                echo '{"error":{"text":'. $e->getMessage() .'}}';
            }
            return false;
        }
	
	return true;
}

function checkUserToken($userToken) {
	
    $sql = "SELECT * FROM USERS WHERE userToken=:userTokenValue";
    
    try {
        $db = getConnection();
        $stmt = $db->prepare($sql);  
        $stmt->bindParam("userTokenValue", $userToken);
        $stmt->execute();
        $token = $stmt->fetchObject();  
        $db = null;
        
        if($token) {
                # KNOWN EMAIL FOR THIS API KEY 
				return true;
        		}
				
		} catch(PDOException $e) { }		
        
		return false;
}

function getAPIKeyForUserToken($userToken) {

    # error_log('getAPIKeyForBundleAndVersion BundleID:'.$bundleID);
    # error_log(' getAPIKeyForBundleAndVersion apiVersion:'.$apiVersion);

	$sql = "SELECT apiKey FROM USERS WHERE userToken=:userTokenValue";
	
		try {
		
            $db = getConnection();
            $stmt = $db->prepare($sql);
            $stmt->bindParam("userTokenValue", $userToken);
            $stmt->execute();
            $apiKey = $stmt->fetchObject();  
            $db = null;
            if($apiKey) {
                return $apiKey->apiKey;
            } else {
              return false;
            }
		
		} catch(PDOException $e) {
            	
        }		
        
        # error_log(' getAPIKeyForBundleAndVersion apiKey:'.$apiKey->apiKey);
        
        return false;		
}

function getAPIKeyForBundleAndVersion($bundleID,$apiVersion) {

    # error_log('getAPIKeyForBundleAndVersion BundleID:'.$bundleID);
    # error_log(' getAPIKeyForBundleAndVersion apiVersion:'.$apiVersion);

	$sql = "SELECT apiKey FROM SERVICEURLS WHERE bundleID=:bundleIDValue AND apiVersion=:apiVersionValue";
	
		try {
		
            $db = getConnection();
            $stmt = $db->prepare($sql);  
            $stmt->bindParam("bundleIDValue", $bundleID);
            $stmt->bindParam("apiVersionValue", $apiVersion);
            $stmt->execute();
            $apiKey = $stmt->fetchObject();  
            $db = null;
            if($apiKey) {
                return $apiKey->apiKey;	
            } else {
              return false;
            }
		
		} catch(PDOException $e) {
            	
        }		
        
        # error_log(' getAPIKeyForBundleAndVersion apiKey:'.$apiKey->apiKey);
        
        return false;		
}

function getPiTokenForPiIdentifier($piIdentifier) {

    $sql = "SELECT piToken FROM PITABLE WHERE identifier =:piIdentifierValue";

    try {
        $db = getConnection();
        $stmt = $db->prepare($sql);
        $stmt->bindParam("piIdentifierValue", $piIdentifier);
        $stmt->execute();
            
        $piToken = $stmt->fetchObject();
    
        return $piToken->piToken;
     
    } catch(PDOException $e) {

        return false;
    }
	
	return false;
}

function createIdentifier($seed,$content) {
    return hash_hmac ( 'md5' , $content ,  $seed ,false );
}


function checkPiIdentifier($piIdentifier) {

    $sql = "SELECT identifier FROM PITABLE WHERE identifier =:piIdentifierValue";

    try {
        $db = getConnection();
        $stmt = $db->prepare($sql);
        $stmt->bindParam("piIdentifierValue", $piIdentifier);
        $stmt->execute();
            
        $hashCount = $stmt->fetchAll();
    
        if (Count($hashCount) > 0) {
            return false;
        }
        
        return true;
    } catch(PDOException $e) {

        return false;
    }
}

function checkUseCase($useCase) {
	
	if (strcmp(USECASEPRIVATE,$useCase) == 0) {
		return true;
	}
	
	if (strcmp(USECASEBUSINESS,$useCase) == 0) {
		return true;
	}

	return false;
}

function countPiUseCasesForUserToken($userToken,$useCase) {

    $sql = "SELECT piToken FROM USECASETABLE WHERE userToken=:userTokenValue AND useCase=:useCaseValue";

    try {
        $db = getConnection();
        $stmt = $db->prepare($sql);
        $stmt->bindParam("userTokenValue", $userToken);
		$stmt->bindParam("useCaseValue", $useCase);
        $stmt->execute();
        $piCount = $stmt->fetchAll();
        
		return Count($piCount);

    } catch(PDOException $e) {

        return false;
    }
}

function countPiUseCasesForPiTokenAndUserToken($userToken,$piToken,$useCase) {

    $sql = "SELECT piToken FROM USECASETABLE WHERE userToken=:userTokenValue AND piToken=:piTokenValue AND useCase=:useCaseValue";

    try {
        $db = getConnection();
        $stmt = $db->prepare($sql);
        $stmt->bindParam("userTokenValue", $userToken);
		$stmt->bindParam("useCaseValue", $useCase);
		$stmt->bindParam("piTokenValue", $piToken);
        $stmt->execute();
        $piCount = $stmt->fetchAll();
        if(Count($piCount) > 0) {
			#knonw useCase for this pi
        	return -1;
        };

    } catch(PDOException $e) {

        return false;
    }
	
    $sql = "SELECT piToken FROM USECASETABLE WHERE userToken=:userTokenValue AND useCase =:useCaseValue";

    try {
        $db = getConnection();
        $stmt = $db->prepare($sql);
        $stmt->bindParam("userTokenValue", $userToken);
		$stmt->bindParam("useCaseValue", $useCase);
        $stmt->execute();
        $piCount = $stmt->fetchAll();
        return Count($piCount);

    } catch(PDOException $e) {

        return false;
    }
}

function countPiForUserToken($userToken) {

    $sql = "SELECT piToken FROM PITABLE WHERE userToken=:userTokenValue";

    try {
        $db = getConnection();
        $stmt = $db->prepare($sql);
        $stmt->bindParam("userTokenValue", $userToken);
        $stmt->execute();
        $piCount = $stmt->fetchAll();
		
		return Count($piCount);

    } catch(PDOException $e) {

        return false;
    }
}

function checkHMACForUserTokenRequest($request) {
	
    $details = json_decode($request->getBody());
    
	if (!isset($details->userToken)) {
		returnErrorWithDescription('Authentication error missing userToken');
		return;
	}
	
    $userToken = $details->userToken;
	
	$apiKey = getAPIKeyForUserToken($userToken);
	
	if ($apiKey) {
		return checkHMACForRequestAndSeed($details,$apiKey);
	}
	
	returnErrorWithDescription('Authentication cant confirm userToken');
}

function checkHMACForRequestAndSeed($request,$seed) {

	$itemArray = (array)$request;
	
	# for testing via REST Browser Client we cann bypass HMAC check 
	if (array_key_exists('hmacFooIgnore',$itemArray)) { return true;}	
	
	if (!array_key_exists('hmac',$itemArray)) { 
		returnErrorWithDescription('Authentication error missing hmac');
		return false;
	}

	$hmacResult = $itemArray['hmac'];
	
	unset($itemArray['hmac']);
	
	ksort($itemArray);
		
	$glue = '&';
	
	$stringInt = http_build_query($itemArray, '', $glue);
	
	$stringInt = rawurldecode($stringInt);
		
	$calcResult = hash_hmac ( 'sha1' , $stringInt ,  $seed ,true );
	
	$calcResult = base64_encode($calcResult);
	
	$modCalcresult = str_replace('/', '_',$calcResult);

	/*
	error_log('hashString:'.$stringInt);
	error_log('seed:'.$seed);
	error_log('aspected:'.$hmacResult);
	error_log('calced  :'.$modCalcresult);
	*/
	
	if (md5($modCalcresult) === md5($hmacResult)){
		return true;
	}
	
	returnErrorWithDescription('Authentication error wrong hmac');
	
	return false;
}

function getConnection() {
	$dbhost="localhost";
	$dbuser="inAppPayer";
	$dbpass="Mi0weck1Ri7Us2duV1pe";
	$dbname="inAppPayment";
	$dbh = new PDO("mysql:host=$dbhost;dbname=$dbname", $dbuser, $dbpass);	
	$dbh->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
	return $dbh;
}

?>