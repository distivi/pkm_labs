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
});
