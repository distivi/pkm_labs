$(document).ready(function(){
	var btnGet = $("#btn-get");
	var btnPost = $("#btn-post");
	var btnPut = $("#btn-put");
	var btnDelete = $("#btn-delete");

	btnGet.on("click",function() {
		btnPost.show(300);
	});

	btnPost.on("click",function() {
		btnPut.show(300);
	});

	btnPut.on("click",function() {
		btnDelete.show(300);
	});

	btnDelete.on("click", function() {
		console.log("send post request");
		showSpinner(true);

		var urlRequest = "http://localhost:3000/clients/777/threads/103/";
		var someData = {client: "some id", thread: 1055};

		$.ajax({type: "POST",
				url: urlRequest,
				dataType: "json",
				data: someData,
				complete: function()
				{
				    console.log("complete ");
				    showSpinner(false);
				    return false;
				},
				error: function(XMLHttpRequest, textStatus, errorThrown) 
				{
					console.log("error block " + XMLHttpRequest.responseText + " " + textStatus + " " + errorThrown);
					return false;
				},
				success: function(response) 
				{
					console.log("success: " + response.test);
					return false;
				}
			});
	});

	function showSpinner(isShow) {
		if (isShow) {
			$("#waiting-spiner").show();
		} else {
			$("#waiting-spiner").hide();
		}
	}
});
