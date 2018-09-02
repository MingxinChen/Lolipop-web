/*main---------------------------------------------------*/
function showCloseDiv(div, op) {
	if(op == 0) {
		$(div).css("visibility", "hidden");
		console.log(div);
	}
	else {
		$(div).css("visibility", "visible");
		console.log(div);
	}
}

//获取当前时间
function getNowFormatDate() {
    var date = new Date();
    var seperator1 = "-";
    var seperator2 = ":";
    var month = date.getMonth() + 1;
    var strDate = date.getDate();
    if (month >= 1 && month <= 9) {
        month = "0" + month;
    }
    if (strDate >= 0 && strDate <= 9) {
        strDate = "0" + strDate;
    }
    var currentdate = date.getFullYear() + seperator1 + month + seperator1 + strDate
            + " " + date.getHours() + seperator2 + date.getMinutes()
            + seperator2 + date.getSeconds();
    return currentdate;
}

//发送广播消息
function sendBroadcast(form) {
	console.log($("#broadcastmessage").val());
	var time = getNowFormatDate();
	var content = $("#broadcastmessage").val();
	content = content.replace(/\r\n/g, '<br/>'); //IE9、FF、chrome
	content = content.replace(/\n/g, '<br/>'); //IE7-8
	content = content.replace(/\s/g, ' '); //空格处理
	var data = {
			"type" : "broadcast", 
			"username" : id, 
			"profilephoto" : pp, 
			"content" : content, 
			"time" : time
		}
	websocket.send(JSON.stringify(data));
	showCloseDiv('#bdmform', 0);
}

//显示一条广播消息
function addBroadcastMessage(username, pp, content, time) {
	var data = '<div class = "animated fadeInUp">' + 
		'<figure class = "card broadcastcard">' +
		'<p><img src = "' + pp + '">' + username + '</p>' + 
		'<p>' + content + '</p>' +
		'<p>' + time + '</p>' +
		'</figure></div>';
	$("#broadcastBoard").after(data);
}

//新建组
function toSetGroup() {
	var groupname=prompt("Please enter the group name.","Group-One");
	groupname = groupname.replace(/\s/g, '-');
	var time = getNowFormatDate();
	if (groupname != null && groupname != "") {
		var data = {
				"type" : "setGroup", 
				"groupname" : groupname, 
				"owner" : id, 
				"time" : time
			}
		websocket.send(JSON.stringify(data));
	}
	else {
		alert("Error: unaviliable group name");
	}
}

// 显示一个组
function addGroup(groupname) {
	groupname2 = "'" + groupname + "'";
	var data = '<a href = "#" onclick = "toGroup(' + groupname2 + ')" class = "list-group-item" id = "' + groupname + 'a">' + groupname +
		'<span class = "badge" id = "' + groupname + 'span" ></span>' + '</a>';
	$("#grouplist").after(data);
	
	var data2 = '<div class = "card messagewindow" id = "' + groupname + 'window">' +
			'<div class = "messagehistory" id = "' + groupname + 'history"></div>' +
			'<div class = "writechatmessage">' +
			'<form onsubmit="return false;">' +
			'<textarea id = "' + groupname + 'textarea">'+ groupname +'</textarea>' +
			'<figure>' +
			'<button type = "submit" class = "btn btn-default" onclick = "sendMessage(' + groupname2 + ', true)">' + 
			'<span class = "glyphicon glyphicon-ok" aria-hidden = "true"></span></button>' +
			'<button type = "submit" class = "btn btn-default" onclick = "sendMessage(' + groupname2 + ', false)">' + 
			'<span class = "glyphicon glyphicon-remove" aria-hidden = "true"></span></button>' +
			'</figure>' +
			'</form></div></div>';
	$("#grouptitle").after(data2);
	
	$("#Squarewindow").css("visibility", "visible");
}

//进入聊天组
function toGroup(groupname) {
	var winpast = '#' + $("#grouptitle").html() + 'window';
	console.log(winpast);
	$(winpast).css("visibility", "hidden");
	
	console.log('to' + groupname);
	var win = '#' + groupname + 'window';
	console.log(win);
	$(win).css("visibility", "visible");
	var span = '#' + groupname + 'span';
	$(span).html('');
	
	$("#grouptitle").html(groupname);
}

//发送消息
function sendMessage(groupname, op) {
	var textarea = '#' + groupname + 'textarea';
	var content = $(textarea).val();
	$(textarea).val('');
	var time = getNowFormatDate();
	
	if(op) {
		content = content.replace(/\r\n/g, '<br/>'); //IE9、FF、chrome
		content = content.replace(/\n/g, '<br/>'); //IE7-8
		content = content.replace(/\s/g, ' '); //空格处理
		var data = {
				"type" : "message", 
				"username" : id, 
				"profilephoto" : pp, 
				"content" : content, 
				"time" : time, 
				"groupname" : groupname
			}
		websocket.send(JSON.stringify(data));
	}	
}

//显示一条聊天记录
function addMessage (groupname, username, pp, content) {
	var span = '#' + groupname + 'span';
	var num = $(span).html();
	if(num == '') num = 0;
	num++;
	$(span).html(num);
	
	var data;
	if(username != id) {
		data = '<div class = "leftmessage">'+ 
			'<p>' + username + '</p>' +
			'<img src = "' + pp + '">' + 
			'<div class = "triangle"></div>' +
			'<div class = "messagecontent">' + content + '</div>' +
			'</div>';
	}
	else {
		data = '<div class = "rightmessage">'+ 
			'<p>' + username + '</p>' +
			'<div class = "messagecontent">' + content + '</div>' +
			'<div class = "triangle"></div>' +
			'<img src = "' + pp + '">' + 
			'</div>';
	}
	
	var messagehistory = '#' + groupname + 'history';
	$(messagehistory).append(data);
	$(messagehistory).scrollTop($(messagehistory)[0].scrollHeight);
}

//删除组
function toDissolveGroup() {
	var groupname=prompt("Please enter the group name.","Group-One");
	groupname = groupname.replace(/\s/g, '-');
	if (groupname != null && groupname != "") {
		var data = {
				"type" : "dissolveGroup", 
				"groupname" : groupname, 
				"username" : id
			}
		websocket.send(JSON.stringify(data));
	}
	else {
		alert("Error: unaviliable group name");
	}
}

//删除组回应
function dissolveGroup(groupname) {
	console.log('dissolve approve');
	var win = '#' + groupname + 'window';
	$(win).css("display", "none");
	$(win).remove();
	
	var a = '#' + groupname + 'a';
	$(a).css("display", "none");
	$(a).remove();
}