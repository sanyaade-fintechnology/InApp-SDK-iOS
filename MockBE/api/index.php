<?php

define('DEFAULTUSECASE','PRIVATE');
define('USECASEDEFAULT','DEFAULT');


require 'Slim/Slim.php';

$app = new Slim();

$app->post('/logs', 'addLogs');

# new endPoints

$app->post('/users', 'getUserTokenForEmail');
$app->post('/users/:userToken/payment-instruments',	'addPIToUserToken');
$app->get('/users/:userToken/payment-instruments',	'listPiForUserToken');
$app->post('/users/:userToken/payment-instruments/:sort-index',	'sortPIForUserToken');

$app->delete('/users/:userToken/payment-instruments/:piID',	'deletePIForUserToken');
$app->delete('/users/:userToken/payment-instruments/:piID/use-case/:useCaseValue',	'removeUseCaseForPiAndUserToken');

$app->response()->header('Connection','close');

$app->run();

function addPIToUserToken ($userToken) {
	
	if(!is_null($userToken)) {
		# code...
		if(checkUserToken($userToken)) {
			addPaymentInstrumentForUserToken($userToken);
		}
	}
}

function listPiForUserToken ($userToken) {
	
	listPaymentInstrumentsForUserToken($userToken);

}

function sortPIForUserToken ($userToken) {
	
	setPIOrderForUserToken();
}


function deletePIForUserToken($userToken,$piID) {
	
	disablePaymentInstrumentForUserToken($userToken,$piID);
}

function removeUseCaseForPiAndUserToken($userToken,$piID,$useCase) {
	
	removePaymentInstrumentForUseCase($userToken,$piID,$useCase);
}


function getUserTokenForEmail() {

    $request = Slim::getInstance()->request();

    # error_log('RequestBody Staging:'.$request->getBody());

	$details = json_decode($request->getBody());
	
	$headers = $request->headers();
		
	if (!isset($headers['x-bundle-id']) && !isset($headers['x-package-name'])) {
	#	returnErrorWithDescription('Missing bundle idenfifier in header');
	#	return;
	}
	
	$bundleID = 'bundleID';
	$sdkVersion = '1.0';
	
	if (isset($headers['x-bundle-id'])) {
		$bundleID = $headers['x-bundle-id'];
	} else if (isset($headers['x-package-name'])) {
		$bundleID = $headers['x-package-name'];
	}
	
	if (isset($headers['x-sdk-version'])) {
		$sdkVersion = $headers['x-sdk-version'];
	} else {
		returnErrorWithDescription('Missing sdk version in header');
		return;
	}
	
	if (!isset($details->email)) {
		returnErrorWithDescription('Missing email value in Request');
		return;
	}
	
	$apiKey = getAPIKeyForBundleAndVersion($bundleID,$sdkVersion);
	
	if(is_null($apiKey)) {	
		returnErrorWithDescription('Invalid credentials');
		return;
	}
	
	if(checkHMACForRequestAndSeed($details,$apiKey)) {
			
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
					
                    addPIsToUserToken($token->userToken,$piArray,$useCase);
                }

            } catch(PDOException $e) {
                returnErrorWithDescription($e->getMessage()); 
				
				return;
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

function listPaymentInstrumentsForUserToken($userToken) {

    $request = Slim::getInstance()->request();
    $details = json_decode($request->getBody());
	
	if (!checkHMACForUserTokenRequest($request)) {
		return;
	}
	
	$get = $request->get();
	
	$useCase = DEFAULTUSECASE;
	
	if (isset($get['use-case'])) {
		$useCase = $get['use-case'];
	}
	
	$useCase = checkUseCase($useCase);
	
	if(!$useCase) {
		returnErrorWithDescription('Invalid UseCase');
		return;		
	}
				
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

function disablePaymentInstrumentForUserToken($userToken,$piID) {
	
	# error_log('disablePaymentInstrumentForUserToken details:'.json_encode($details));
	
    # error_log('disablePaymentInstrumentForUserToken userToken:'.json_encode($userToken));

     
    $sql = "UPDATE PITABLE SET piEnabled=0 WHERE userToken=:userTokenValue AND piIndex=:identifierValue";
	
	# TODO update sortIndex 

    try {
        $db = getConnection();
        $stmt = $db->prepare($sql);  
        $stmt->bindParam("userTokenValue", $userToken);
        $stmt->bindParam("identifierValue", $piID);
        $stmt->execute();
		
		# remove all useCases
		
		$removeUseCaseResult = removePaymentInstrumentForUserTokenAndUseCase($userToken,$piID,null);
				
		if(!$removeUseCaseResult){
			returnErrorWithDescription('Error on removing pi');
		}
            
    } catch(PDOException $e) {
        returnErrorWithDescription($e->getMessage());
		return;
    }       
    
	returnOKStatus(NULL);
}

function removePaymentInstrumentForUseCase($userToken,$piID,$useCase) {
		
	$useCase = checkUseCase($useCase);

	if(!$useCase) {
		returnErrorWithDescription('Invalid UseCase');
		return;		
	}
	
	if(removePaymentInstrumentForUserTokenAndUseCase($userToken,$piID,$useCase)) {
		returnOKStatus(NULL);
		return;
	}
}

function removePaymentInstrumentForUserTokenAndUseCase($userToken,$piIdentifier,$useCase) {
	
	# error_log('removePaymentInstrumentForUserTokenAndUseCase details:'.json_encode($details));
	
	if(isset($useCase)) {
		$sql = "SELECT u.sortIndex FROM USECASETABLE u INNER JOIN PITABLE p ON u.piToken = p.piToken WHERE (p.userToken=:userTokenValue AND p.piIndex=:piIndexValue AND u.useCase=:useCaseValue)";
	
	    try {
	        $db = getConnection();
	        $stmt = $db->prepare($sql);  
	        $stmt->bindParam("userTokenValue", $userToken);
	        $stmt->bindParam("piIndexValue", $piIdentifier);
			$stmt->bindParam("useCaseValue", $useCase);
	        $stmt->execute();
		
			$sortIndexResult = $stmt->fetchObject();
			if(isset($sortIndexResult)) {
				$sortIndex = $sortIndexResult->sortIndex;
			}else {
				$sortIndex = false;
			}
			            
	    } catch(PDOException $e) {
	        returnErrorWithDescription($e->getMessage());
			return false;
	    } 
		
		$sql = "DELETE u.* FROM USECASETABLE u INNER JOIN PITABLE p ON u.piToken = p.piToken WHERE (p.userToken=:userTokenValue AND p.piIndex=:piIndexValue AND u.useCase=:useCaseValue)";

	} else {
		$sql = "DELETE u.* FROM USECASETABLE u INNER JOIN PITABLE p ON u.piToken = p.piToken WHERE (p.userToken=:userTokenValue AND p.piIndex=:piIndexValue)";
	}
	
    try {
        $db = getConnection();
        $stmt = $db->prepare($sql);  
        $stmt->bindParam("userTokenValue", $userToken);
        $stmt->bindParam("piIndexValue", $piIdentifier);
		if(isset($useCase)) {
			$stmt->bindParam("useCaseValue", $useCase);
		}
        $stmt->execute();
		
		if(isset($useCase)) {
			
			if ($sortIndex) {
				return reorderUseCaseUpFromIndex($sortIndex,$useCase,$userToken);
			}
			
			return true;
			
		} else {
			return true;
		}
		
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

function addPaymentInstrumentForUserToken($userToken) {

    $request = Slim::getInstance()->request();
    $details = json_decode($request->getBody());
	
	if (!isset($details->paymentInstrument)) {
		returnErrorWithDescription('Missing paymentInstrument value in Request');
		return;
	}
		
	$useCase = DEFAULTUSECASE;
	
	if (isset($details->useCase)) {
		$useCase = $details->useCase;
	}
	
	$useCase = checkUseCase($useCase);
	
	if(!$useCase) {
		returnErrorWithDescription('Invalid UseCase');
		return;
	}
	
	$piArray = array();
	
	if (is_array($details->paymentInstrument)) {
		$piArray = array_merge($piArray, $details->paymentInstrument);
	} else {
		array_push($piArray,$details->paymentInstrument);
	}

    if(addPIsToUserToken($userToken,$piArray,$useCase)) {
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
			 
         } catch(PDOException $e) {
             returnErrorWithDescription($e->getMessage());
 			return;
         }       
		 
		 #known pi ... so check if this useCase is known
		 
		 $piToken = getPiTokenForPiIdentifier($piIdentifier);
		 
		 addPIToUseCaseTable($piToken,$userToken,$useCase);
		
     }
	 
	 # already known pi
	 return true;
}

function addPIWithDetails ($piTokenValue,$piIdentifier,$userTokenValue,$piDetailsValue,$useCaseValue) {
	
	$piIndexValue = countPiForUserToken($userTokenValue);
	
    $sql = "INSERT INTO PITABLE (piToken,identifier,userToken, piDetails, piDetailsUnMasked, piIndex) VALUES (:piTokenValue,:piIdentifierValue, :userTokenValue, :piDetailsValue, :piDetailsUnMaskedValue, :piIndexValue)";
    
	$maskedPiDetails = createMaskedPI($piDetailsValue);
	
    try {
            $db = getConnection();
            $stmt = $db->prepare($sql);  
			
			$stmt->bindParam("piTokenValue", $piTokenValue);
            $stmt->bindParam("piIdentifierValue", $piIdentifier);						
            $stmt->bindParam("userTokenValue", $userTokenValue);
            $stmt->bindParam("piDetailsValue",$maskedPiDetails);
			$stmt->bindParam("piDetailsUnMaskedValue",$piDetailsValue);
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

function createMaskedPI($piDetails) {
	
	$piDetailArray = (array)json_decode($piDetails);
	
	if (is_array($piDetailArray)) {
		
		if (array_key_exists('type',$piDetailArray)) {
			
			$piType = $piDetailArray['type'];
			
			$maskedPi = array();
			
			$maskedPi = array_merge($maskedPi,$piDetailArray);
			
			if (strcasecmp(strtoupper($piType),'CC') == 0) {

				if (array_key_exists('pan',$maskedPi)) {
					
					$pan = $maskedPi['pan'];
					
					$maskedPan = maskStringToLength($pan,4);
					
					$maskedPi['pan'] = $maskedPan;
				}
				
				if (array_key_exists('cvv',$maskedPi)) {
					unset($maskedPi['cvv']);
				}
			}
			
			if (strcasecmp(strtoupper($piType),'DD') == 0) {
								
				if (array_key_exists('accountNumber',$maskedPi)) {
					
					$accountNumber = $maskedPi['accountNumber'];
					
					$maskedAccountNumber = maskStringToLength($accountNumber,4);
					
					$maskedPi['pan'] = $maskedAccountNumber;
				}
			}
			
			return json_encode($maskedPi);
		}
	}
	
	return $piDetails;
}

function maskStringToLength($strToMask,$lengthToMask) {
	
	if (strlen($strToMask > $lengthToMask)) {

		$replaceLenght = strlen($strToMask) - $lengthToMask;
		
		$replaceStr = '';
		
		for($i=0; $i < $replaceLenght; $i++) {
		 $replaceStr = $replaceStr . '*';
		}
		
		$maskedPan = substr_replace($strToMask,$replaceStr,0,$replaceLenght);
		
		return $maskedPan;
	}
	
	return $strToMask;
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
	
	if (strcmp(USECASEDEFAULT,strtoupper($useCase)) == 0) {
		return DEFAULTUSECASE;
	}
	
	if (strlen($useCase) > 0) {
		return $useCase;
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
	
	return true;
    
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

	return true;

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

function addLogs() {
	
    $request = Slim::getInstance()->request();
    $details = json_decode($request->getBody());
	
	if(!isset($details->events)) {
		
		return;
	}

	$sendedEvents = $details->events;
	$eventsToLog = array();
	
	if (is_array($sendedEvents)) {
		$eventsToLog = array_merge($eventsToLog, $sendedEvents);
	} else {
		array_push($eventsToLog,$sendedEvents);
	}

    $sql = "INSERT INTO LOGS Set event=:eventValue";
	
    $db = getConnection();
    $stmt = $db->prepare($sql); 
	
	foreach ($eventsToLog as $event) {
	
	    try {
	            $db = getConnection();
	            $stmt = $db->prepare($sql);  
				
				$jsonEvent = json_encode($event);
	            $stmt->bindParam("eventValue", $jsonEvent);
	            $stmt->execute();             
            
	        } catch(PDOException $e) { }
		}
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