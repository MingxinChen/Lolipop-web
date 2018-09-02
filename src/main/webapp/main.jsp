<%@ page language="java" contentType="text/html;charset=UTF-8"%>
<!DOCTYPE html>
<html>
   <head>
      <title>Chat System MAINPAGE</title>
      <meta name = "viewport" content = "width = device-width, initial-scale = 1, maximum-scale = 1, user-scalable = no">
      <meta http-equiv = "Content-Type" content = "text/html; charset = utf-8" />
      
      <link href = "./bootstrap-3.3.7-dist/css/bootstrap.min.css" rel = "stylesheet">
      <link href = "./animate.css" rel = "stylesheet">
      <link href = "./styles.css" rel = "stylesheet">
      <script type = "text/javascript" src = "./function.js"></script>
      
      <script type = "text/javascript" src = "./bootstrap-3.3.7-dist/js/jquery-3.3.1.js"></script>
	  <script type = "text/javascript" src = "./bootstrap-3.3.7-dist/js/bootstrap.min.js"></script>
   </head>



   <body>
      <nav class = "navbar navbar-default navbar-fixed-top">
         <h2><img src="./images/logo.png">Lolipop</h2>
      </nav>


      <div class = "container">
         <div class = "grouplist col-sm-3">
            <h3>
               <img src = "<%=request.getParameter("pp")%>">  
               <span><%=request.getParameter("id")%></span>

               <div class="btn-group">
				  <button type="button" class="btn dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
				     <span class="glyphicon glyphicon-screenshot"></span>
				  </button>
				  <ul class="dropdown-menu">
				    <li><a href="#" onclick="toSetGroup()">Set up a new group</a></li>
				    <li><a href="#" onclick="toDissolveGroup()">Dissolve a group</a></li>
				    <li class = "disable"><a href="#">Setting</a></li>
				  </ul>
				</div>                   
            </h3>

            <div class = "card animated fadeInUp">
               <div class = "list-group">
               	 <div id = "grouplist"></div>
                 <!-- <a href = "#" class = "list-group-item active">Cras justo odio<span class = "badge">14</span></a>
                 <a href = "#" class = "list-group-item">Dapibus ac facilisis in</a>
                 <a href = "#" class = "list-group-item">Morbi leo risus</a>
                 <a href = "#" class = "list-group-item">Porta ac consectetur ac</a>
                 <a href = "#" class = "list-group-item">Vestibulum at eros</a> -->
               </div>
            </div>
         </div>


         <div class = "chatwindow col-sm-5 animated fadeInUp">
	            <div class = "card grouptitle" id = "grouptitle">Square</div>
         </div>


          <div class = "broadcast col-sm-4">
            <div id = "broadcastBoard"></div>

            <button type = "button" class = "btn btn-default btn-lg animated fadeInUp writebroadcast" onclick = "showCloseDiv('#bdmform', 1)">
               <span class = "glyphicon glyphicon-pencil" aria-hidden = "true"></span>
            </button>

            <form class = "form-horizontal animated fadeInUp bdmform" id = "bdmform" onsubmit = "return false;">
              <div class = "form-group">
                  <textarea id = "broadcastmessage" class = "col-sm-10 form-control" rows = "3"></textarea>
                  <button type = "submit" class = "col-sm-1 btn btn-default btn-xs" onclick = "sendBroadcast(this.form);">
                     <span class = "glyphicon glyphicon-ok" aria-hidden = "true"></span>
                  </button>
                  <button type = "submit" class = "col-sm-1 btn btn-default btn-xs" onclick = "showCloseDiv('#bdmform', 0)">
                     <span class = "glyphicon glyphicon-remove" aria-hidden = "true"></span>
                  </button>
              </div>
            </form>


          </div>
      </div>
      

   </body>
<script>
	var id= '<%=request.getParameter("id")%>';
	var pp= '<%=request.getParameter("pp")%>';
	
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
    	
    	var data = {
    	    	"type" : "initialize"
    	    }
    	    websocket.send(JSON.stringify(data));
    }  
    
    //接收到消息的回调方法  
    websocket.onmessage = function (event) {  
    	console.log(event.data);
    	var obj = eval('(' + event.data + ')');
    	
    	var type = obj.type;
		console.log(type);
		
    	if(type == "broadcast") {
    		addBroadcastMessage(obj.username, obj.profilephoto, obj.content, obj.time);
    	}
    	else if(type == "setGroup") {
    		addGroup(obj.groupname);
    	}
    	else if(type == "message") {
    		addMessage(obj.groupname, obj.username, obj.profilephoto, obj.content);
    	}
    	else if(type == "dissolveGroupResponse") {
    		if(obj.result == '1') {
    			//dissolveGroup(obj.groupname);
    			alert('Succeed');
    		}
    		else {
    			alert(obj.reason);
    		}
    	}
    	else {
    		console.log("无法解析的消息");
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
</script>
   
</html>