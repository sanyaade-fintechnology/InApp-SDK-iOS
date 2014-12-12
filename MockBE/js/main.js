// The root URL for the RESTful services
var rootURL = "http://localhost/staging/api";

var currentEvents;

findAll();

// Nothing to delete in initial application state
$('#btnDelete').hide();

// Register listeners
$('#btnListEvents').click(function() {
	console.log('okay, findAll');
	findAll();
	return false;
});


$('#btnRepairUseCases').click(function() {
	console.log('Fix UseCases');
	repairUseCases();
	return false;
});


// Trigger search when pressing 'Return' on search key input field
$('#searchKey').keypress(function(e){
	if(e.which == 13) {
		search($('#searchKey').val());
		e.preventDefault();
		return false;
    }
});

$('#btnAdd').click(function() {
	newWine();
	return false;
});

$('#btnSave').click(function() {
	if ($('#wineId').val() == '')
		addWine();
	else
		updateWine();
	return false;
});

$('#btnDelete').click(function() {
	deleteWine();
	return false;
});

$('.eventList').on('click', 'a', function() {
	
	clickedID =  $(this).data('identity');

	event = currentEvents[clickedID];
	
	console.log('okay, clicked : ' + clickedID + event);
	
	renderDetails(event);
	
});

// Replace broken images with generic wine bottle
$("img").error(function(){
  $(this).attr("src", "pics/generic.jpg");

});

function repairUseCases() {
    $.ajax({
        type: 'GET',
        url: rootURL + '/useCases/repair',
        dataType: "json", // data type of response
        success: renderList
    });
	
}
function findAll() {
    $.ajax({
        type: 'GET',
        url: rootURL + '/logs',
        dataType: "json", // data type of response
        success: renderList
    });
}

function applyFilter(needle) {
    // console.log('Needle: ' + needle);
    $.ajax({
        type: 'GET',
        url: rootURL + '/logs/' + needle,
        dataType: "json", // data type of response
        success: renderList
    });
	
}

function search(searchKey) {
	if (searchKey == '') 
		findAll();
	else
		findByName(searchKey);
}

function newWine() {
	$('#btnDelete').hide();
	currentWine = {};
	renderDetails(currentWine); // Display empty form
}

function findByName(searchKey) {
	console.log('findByName: ' + searchKey);
	$.ajax({
		type: 'GET',
		url: rootURL + '/search/' + searchKey,
		dataType: "json",
		success: renderList 
	});
}

function findById(id) {
	renderDetails(currentEvents[id]);
}

function renderList(data) {
	
	eventsJSONString = data.events;
	currentEvents = $.parseJSON(eventsJSONString);
	
	if(currentEvents.length == 0) {
		alert('No events of this kind found :(');
		return;
	}
	
	$('.eventList li').remove();
	
	loadIndex = 0;
	
	$.each(currentEvents, function(index, value) {
		
		//console.log('Render Events ... Data:' + index +  '  :' + value.id + '  :' + value.event);

		$('.eventList').append('<li><a href="#" class="eventItem" data-identity="' + loadIndex + '">' + value.id + ' ' + value.timeStamp + '</a></li>');
		
		loadIndex++;
	});
	
	event = currentEvents[0];
	
	renderDetails(event);
	
}

function renderDetails(data) {
	
	$('#eventId').val(data.id);
	//$('#eventDetails').val(data.event);
	$('#timeStamp').val(data.timeStamp);
	
	currentDetails = $.parseJSON(data.event);
	
	$('.detailKeyList li').remove();
	$('.detailValueList li').remove();
	
	keys = Object.keys(currentDetails);
			
	$.each(keys, function(index, keyValue) {

		currentValue = currentDetails[keyValue];
		
		$('.detailKeyList').append('<li><a href="#" class="detailItem" >' + index + ' : ' + keyValue + '</a></li>');
		
		
		if (typeof(currentValue) === 'object') {
			$('.detailValueList').append('<li><a href="#" class="detailItem" >&nbsp;&nbsp;' + detectTypeForObject(currentValue) + '</a></li>');
			insertObjectContent(currentValue,2);
		} else {
			$('.detailValueList').append('<li><a href="#" class="detailItem" >&nbsp;&nbsp;' + currentValue + '</a></li>');
		}
	});
}

function insertObjectContent(detailedObject,indention) {
	
	//console.log('Details ... :' + indention);
	
	detailedKeys = Object.keys(detailedObject);
	
	indentionStr = '';
	
	for(count = 0; count <= indention; count++){
		indentionStr = indentionStr + '&nbsp;&nbsp;';
	}
	
	$.each(detailedKeys, function(subIndex, subKeyValue) {
		//console.log('Details ... :' + indention +  '  :' + subKeyValue);
		
		currentValue = detailedObject[subKeyValue];
		
		$('.detailKeyList').append('<li><a href="#" class="detailItem" >&nbsp;&nbsp;' + indentionStr + subIndex +' : ' + subKeyValue + '</a></li>');
		
		if (typeof(currentValue) === 'object') {
			$('.detailValueList').append('<li><a href="#" class="detailItem" >&nbsp;&nbsp;' + indentionStr + detectTypeForObject(currentValue) + '</a></li>');
			insertObjectContent(currentValue,indention+2);
		} else {
			$('.detailValueList').append('<li><a href="#" class="detailItem" >&nbsp;&nbsp;' + indentionStr + currentValue + '</a></li>');
		}
		
		indentionStr = '';
	
		for(count = 0; count <= indention; count++){
			indentionStr = indentionStr + '&nbsp;&nbsp;';
		}
	});
	
}

function detectTypeForObject(unkownObject) {
	
	detailedKeys = Object.keys(unkownObject);
	
	if (detailedKeys[0] == '0') {
		return 'Array';
	}
	
	return 'Key-Value';
}

// Helper function to serialize all the form fields into a JSON string
function formToJSON() {
	return JSON.stringify({
		"id": $('#wineId').val(), 
		"name": $('#name').val(), 
		"grapes": $('#grapes').val(),
		"country": $('#country').val(),
		"region": $('#region').val(),
		"year": $('#year').val(),
		"picture": currentWine.picture,
		"description": $('#description').val()
		});
}