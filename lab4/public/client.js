$(document).ready(function(){
	var btnGet = $("#btn-get");
	var btnPost = $("#btn-post");
	var btnPut = $("#btn-put");
	var btnDelete = $("#btn-delete");

	var updateTaskManagerTable = function(){
		$.get("/info",
			null,
			function(data) {
				console.log("GET success");
				console.log(data);
				$(".task-manager").empty();
				$(".task-manager").append(data);
				return false;
			}
		);
	};
	updateTaskManagerTable();

	$("#submit-task").on("click",function(){
		console.log("ololo");
		var clientId = $("#client-id-tf").val();
		var clientName = $("#client-name-tf").val();
		var clientStatus = $("#client-status-tf").val();
		var threadId = $("#thread-id-tf").val();
		var threadPriority = $("#thread-priority-tf").val();
		var threadTask = $("#thread-task-tf").val();

		var arr = [clientId,clientName,clientStatus,threadId,threadPriority,threadTask]
		arr.some(function(e){
			if (!e) {
				alert("Please fill all input text fields");
				throw StopIteration;
			};
		});


		console.log("clientId " + clientId);
		console.log("clientName " + clientName);
		console.log("clientStatus " + clientStatus);
		console.log("threadId " + threadId);
		console.log("threadPriority " + threadPriority);
		console.log("threadTask " + threadTask);

		showSpinner(true);

		var urlRequest = "http://localhost:3000/clients/" + clientId + "/threads/" + threadId +"/";
		var someData = {client_name: clientName, client_status: clientStatus, thread_priority: threadPriority, thread_task: threadTask};

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
					console.log("success: " + response.success);
					return false;
				}
			});


	});

	btnGet.on("click",function() {
		updateTaskManagerTable();
		
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
					console.log("success: " + response.success);
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
