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

	event = currentEvents[clickedID - 1];
	
	console.log('okay, clicked : ' + clickedID + event);
	
	renderDetails(event);
	
});

// Replace broken images with generic wine bottle
$("img").error(function(){
  $(this).attr("src", "pics/generic.jpg");

});


function findAll() {
    $.ajax({
        type: 'GET',
        url: rootURL + '/logs',
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
	$('.eventList li').remove();
	
	loadIndex = 0;
	
	$.each(currentEvents, function(index, value) {
		
		console.log('Render Events ... Data:' + index +  '  :' + value.id + '  :' + value.event);
		
		if(index = 0) {
			loadIndex = value.id;
		}
		
		$('.eventList').append('<li><a href="#" class="eventItem" data-identity="' + value.id + '">' + value.id + ' ' + value.timeStamp + '</a></li>');
	});
	
	event = currentEvents[loadIndex];
	
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
		//console.log('Details ... :' + index +  '  :' + keyValue);
		$('.detailKeyList').append('<li><a href="#" class="detailItem" >' + index + ' : ' + keyValue + '</a></li>');
		$('.detailValueList').append('<li><a href="#" class="detailItem" >' + currentDetails[keyValue] + '</a></li>');
	});
	
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