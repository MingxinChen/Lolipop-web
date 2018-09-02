<%@ page language="java" contentType="text/html;charset=UTF-8"%>
<!DOCTYPE html>
<html>
   <head>
      <title>Chat System 1.0</title>
      <meta name = "viewport" content = "width = device-width, initial-scale = 1, maximum-scale = 1, user-scalable = no">
      <meta http-equiv = "Content-Type" content = "text/html; charset = utf-8" />
      
      <link href = "./bootstrap-3.3.7-dist/css/bootstrap.min.css" rel = "stylesheet">
      <link href = "./animate.css" rel = "stylesheet">
      <link href = "./styles.css" rel = "stylesheet">

      <script type="text/javascript" src = "./bootstrap-3.3.7-dist/js/jquery-3.3.1.js"></script>
	  <script type="text/javascript" src = "./bootstrap-3.3.7-dist/js/bootstrap.min.js"></script>
   </head>



   <body>
      <div class = "container">
            
         <div class = "animated fadeInUp">
            <h1><img src = "./images/logo.png">Lolipop</h1>

            <form class = "form-horizontal" id="logform" onsubmit="return false;">
               <div class = "form-group">
                  <label for = "username" class = "col-sm-5 control-label">Username</label>
                  <div class = "col-sm-7">
                     <input type = "text" class = "form-control" id = "username">
                  </div>
               </div>

               <div class = "form-group">
                  <label for = "profilephoto" class = "col-sm-5 control-label">Profile Photo</label>
                  <div class = "col-sm-7">
                     <img src = "./images/pp1.png" id = "profilephotoimg" class = "img-rounded">
                     <input type = "text" class = "form-control" id = "profilephoto" style = "display: none" value = "./images/pp1.png">
                     <div>
                        <a onclick="selectPP('./images/pp1.png');">
                           <img src = "./images/pp1.png" alt = "profilephoto" class = "img-rounded">
                        </a>
                        <a onclick="selectPP('./images/pp2.png');">
                           <img src = "./images/pp2.png" alt = "profilephoto" class = "img-rounded">
                        </a>
                        <a onclick="selectPP('./images/pp3.png');">
                           <img src = "./images/pp3.png" alt = "profilephoto" class = "img-rounded">
                        </a>
                        <a onclick="selectPP('./images/pp4.png');">
                           <img src = "./images/pp4.png" alt = "profilephoto" class = "img-rounded">
                        </a>
                        <a onclick="selectPP('./images/pp5.png');">
                           <img src = "./images/pp5.png" alt = "profilephoto" class = "img-rounded">
                        </a>
                     </div>
                  </div>
               </div>

               <div class = "form-group">
                  <div class = "col-sm-offset-5 col-sm-4">
                     <button class = "btn btn-primary btn-default" onclick = "tolog(this.form)">GET START</button>
                  </div>
               </div>
            </form>
         </div>
      </div>
   </body>
   
<script type="text/javascript">  
    var websocket = null;  
    //判断当前浏览器是否支持WebSocket  
    if ('WebSocket' in window) {  
        websocket = new WebSocket("ws://localhost:8080/lolipop/ws");
    }  
    else {  
        alert('当前浏览器不支持WebSocket，无法与服务器建立连接。')  
    }  

    //连接发生错误的回调方法  
    websocket.onerror = function () {  
    	console.log("WebSocket连接错误");  
    };  

    //连接成功建立的回调方法  
    websocket.onopen = function () {  
    	console.log("WebSocket连接成功");  
    }  

    //接收到消息的回调方法  
    websocket.onmessage = function (event) {  
    	var obj = eval('(' + event.data + ')');
    	console.log(obj);
    	var result = obj.result;
		console.log(result);
		
    	if(result == '1') {
    		closeWebSocket();  
    		console.log("登陆成功");
    		var href = './main.jsp?id=' + $("#username").val() + '&pp=' + $("#profilephoto").val();
    		window.location.href = href;
    	}
    	else {
    		alert("登陆失败");
    	}
    }  

    //连接关闭的回调方法  
    websocket.onclose = function () {  
    	console.log("WebSocket连接关闭");  
    }  

    //监听窗口关闭事件，当窗口关闭时，主动去关闭websocket连接，防止连接还没断开就关闭窗口，server端会抛异常。  
    window.onbeforeunload = function () {  
        closeWebSocket();  
    }  
    
    //关闭WebSocket连接  
    function closeWebSocket() {  
        websocket.close();  
    }  

    //登陆
    function tolog(form) {  
    	var data = {
    			"type" : "login", 
    			"username" : form.username, 
    			"profilephoto" : form.profilephoto
    		}
    	websocket.send(JSON.stringify(data));
    }  
    
    //改变头像img和input
    function selectPP(path) {
		$('#profilephotoimg').attr("src", path);
		$("#profilephoto").attr("value",path);
		console.log($("#profilephoto").val());
	}
</script>  
   
</html>  