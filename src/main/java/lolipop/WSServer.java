package lolipop;

import java.awt.List;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.concurrent.ConcurrentHashMap;

import javax.websocket.*;  
import javax.websocket.server.ServerEndpoint;

import net.sf.json.JSONObject; 

@ServerEndpoint("/ws")
public class WSServer 
{
    //静态变量，用来记录当前在线连接数。应该把它设计成线程安全的。  
    private static int onlineCount = 0;  

    private static ConcurrentHashMap<Session, WSServer> ssMap= new ConcurrentHashMap<Session, WSServer>();

    //与某个客户端的连接会话，需要通过它来给客户端发送数据  
    private Session session;  
    
    //数据库
    String driver ="com.mysql.cj.jdbc.Driver";  
    String url ="jdbc:mysql://mydbinstance3.cxy789glo29q.us-east-2.rds.amazonaws.com:3306/mydb?useUnicode=true&characterEncoding=utf8&serverTimezone=GMT%2B8&useSSL=false";  
    String user ="mydb";  
    String pass="mypassword";

    /** 
     * 连接建立成功调用的方法 
     * @param session  可选的参数。session为与某个客户端的连接会话，需要通过它来给客户端发送数据 
     */  
    @OnOpen  
    public void onOpen(Session session){  
        this.session = session;  
        ssMap.put(session, this);
        addOnlineCount();           //在线数加1  
        System.out.println("open. socket number: " + getOnlineCount());  
    }  

    /** 
     * 连接关闭调用的方法 
     */  
    @OnClose  
    public void onClose(){  
        ssMap.remove(this.session);
        subOnlineCount();           //在线数减1  
        System.out.println("close. socket number:" + getOnlineCount());  
    }  

    /** 
     * 收到客户端消息后调用的方法 
     * @param message 客户端发送过来的消息 
     * @param session 可选的参数 
     */  
    @OnMessage  
    public void onMessage(String data, Session session) {  
        JSONObject jsonObject = JSONObject.fromObject(data);
        String type1 = jsonObject.optString("type");
        System.out.println("receive message: " + type1);
            
        if(type1.compareTo("login") == 0) {
            try {
            	WSServer tmp = ssMap.get(session);
                tmp.sendMessage("{'type':'logResponse', 'result':'1'}");
                    
            } catch (IOException e1) {
                e1.printStackTrace();
            }
        }
        else if(type1.compareTo("initialize") == 0) {
        	// 初始化
        	initialize(session);
        }
        else if(type1.compareTo("broadcast") == 0) {
        	// 收到广播消息
        	broadcast(data); 
        }
        else if(type1.compareTo("setGroup") == 0) {
        	// 收到建组请求
        	setGroup(data);
        }
        else if(type1.compareTo("message") == 0) {
        	// 收到消息
        	getMessage(data);
        }
        else if(type1.compareTo("dissolveGroup") == 0) {
        	// 收到删除组
        	dissolveGroup(data, session);
        }
        else {
            System.out.println("cannot read the message");
        }
    }

    /** 
     * 发生错误时调用 
     * @param session 
     * @param error 
     */  
    @OnError  
    public void onError(Session session, Throwable error){  
        System.out.println("error");  
        error.printStackTrace();  
    }  
    
    public void sendMessage(String message) throws IOException{  
        this.session.getBasicRemote().sendText(message); 
        //this.session.getAsyncRemote().sendText(message);  
    }

    // 初始化
    private void initialize(Session session) {
    	PreparedStatement stmt1=null, stmt2=null;
    	ResultSet rs1=null, rs2=null;
        Connection con=null;
         try{
             Class.forName(driver);  
             con = (Connection) DriverManager.getConnection(url, user, pass);  
         	// group
             String sql1 = "select * from grouplist where able = 1;";
             stmt1=con.prepareStatement(sql1);
             rs1=stmt1.executeQuery();
             while(rs1.next()){
            	 try {
                 	WSServer tmp = ssMap.get(session);
                 	String message = "{'type':'setGroup', 'groupname':'" + rs1.getString(1) + "'}";
                    tmp.sendMessage(message);
                         
                 } catch (IOException e1) {
                     e1.printStackTrace();
                 }    	 
             }
             
         	// broadcast message
             String sql2 = "select * from broadcast limit 10;";	           
             stmt2=con.prepareStatement(sql2);
             rs2=stmt2.executeQuery();
             
             while(rs2.next()){
            	 try {
                 	WSServer tmp = ssMap.get(session);
                 	String message = "{'type':'broadcast', 'username':'" + rs2.getString(1) + 
                 			"', 'profilephoto':'" + rs2.getString(2) + 
                 			"', 'content':'" + rs2.getString(3) + 
                 			"', 'time':'" + rs2.getString(4) + "'}";
                    tmp.sendMessage(message);
                         
                 } catch (IOException e1) {
                     e1.printStackTrace();
                 }    	 
             }
         }catch (ClassNotFoundException e) {  
             e.printStackTrace();  
         } catch (SQLException e) {  
             e.printStackTrace();  
         }finally {  
             try {  
            	 if(stmt1!=null)stmt1.close();  
                 if(stmt2!=null)stmt2.close();  
                 if(con!=null)con.close();  
                 }   
             	catch (SQLException e){          
                }  
         }  
    }
    
    // 收到广播消息
    private void broadcast(String data) {
    	// 转发
    	for(Session key : ssMap.keySet()) {
        	try{
        		WSServer tmp = ssMap.get(key);
                tmp.sendMessage(data);
        	} catch (IOException e1) {
                e1.printStackTrace();
            }
        }
    	
    	// 联系数据库
    	PreparedStatement stmt=null;
        Connection con=null;
         try{
        	 JSONObject jsonObject = JSONObject.fromObject(data);
             String username = jsonObject.optString("username");
             String profilephoto = jsonObject.optString("profilephoto");
             String content = jsonObject.optString("content");
             String time = jsonObject.optString("time");
        	 
             Class.forName(driver);  
             con = (Connection) DriverManager.getConnection(url, user, pass);  
             String sql = "insert into broadcast(username, profilephoto, content, time) values(?, ?, ?, ?)";	           
             stmt=con.prepareStatement(sql);
             stmt.setString(1, username);
             stmt.setString(2, profilephoto);
             stmt.setString(3, content); 
             stmt.setString(4, time); 
             int rs=stmt.executeUpdate();
             
             if(rs < 0) {
            	 System.out.println("broadcast to mydb. failed");
             }
         }catch (ClassNotFoundException e) {  
             e.printStackTrace();  
         } catch (SQLException e) {  
             e.printStackTrace();  
         }finally {  
             try {  
                 if(stmt!=null)stmt.close();  
                 if(con!=null)con.close();  
                 }   
             	catch (SQLException e){          
                }  
         }  
    }
    
    // 收到建组请求
    private void setGroup(String data) {
    	// 转发
    	for(Session key : ssMap.keySet()) {
        	try{
        		WSServer tmp = ssMap.get(key);
                tmp.sendMessage(data);
        	} catch (IOException e1) {
                e1.printStackTrace();
            }
        }
    	
    	// 联系数据库
    	PreparedStatement stmt=null;
        Connection con=null;
         try{
        	 JSONObject jsonObject = JSONObject.fromObject(data);
             String groupname = jsonObject.optString("groupname");
             String owner = jsonObject.optString("owner");
             String time = jsonObject.optString("time");
        	 
             Class.forName(driver);  
             con = (Connection) DriverManager.getConnection(url, user, pass);  
             String sql = "insert into grouplist(groupname, owner, time) values(?, ?, ?)";	           
             stmt=con.prepareStatement(sql);
             stmt.setString(1, groupname);
             stmt.setString(2, owner);
             stmt.setString(3, time); 
             int rs=stmt.executeUpdate();
             
             if(rs < 0) {
            	 System.out.println("add group. failed");
             }
         }catch (ClassNotFoundException e) {  
             e.printStackTrace();  
         } catch (SQLException e) {  
             e.printStackTrace();  
         }finally {  
             try {  
                 if(stmt!=null)stmt.close();  
                 if(con!=null)con.close();  
                 }   
             	catch (SQLException e){          
                }  
         }  
    }
    
    // 删除组
    private void dissolveGroup(String data, Session session) {
    	// 联系数据库
    	PreparedStatement stmt=null;
        Connection con=null;
         try{
        	 JSONObject jsonObject = JSONObject.fromObject(data);
             String groupname = jsonObject.optString("groupname");
             String username = jsonObject.optString("username");
        	 
             Class.forName(driver);  
             con = (Connection) DriverManager.getConnection(url, user, pass);  
             String sql = "update grouplist set able = 0 where groupname = ? and owner = ?";	           
             stmt=con.prepareStatement(sql);
             stmt.setString(1, groupname);
             stmt.setString(2, username);
             int rs=stmt.executeUpdate();
                          
             if(rs <= 0) {
            	 try {
                	 WSServer tmp = ssMap.get(session);
                  	 String message = "{'type':'dissolveGroupResponse', 'result':'0', 'reason':'Fail'}";
                     tmp.sendMessage(message);
                 } catch (IOException e1) {
                     e1.printStackTrace();
                 }
             }
             else {
            	 try {
                	 WSServer tmp = ssMap.get(session);
                  	 String message = "{'type':'dissolveGroupResponse', 'result':'1'}";
                     tmp.sendMessage(message);
                 } catch (IOException e1) {
                     e1.printStackTrace();
                 }
             }
         }catch (ClassNotFoundException e) {  
             e.printStackTrace();  
         } catch (SQLException e) {  
             e.printStackTrace();  
         }finally {  
             try {  
                 if(stmt!=null)stmt.close();  
                 if(con!=null)con.close();  
                 }   
             	catch (SQLException e){          
                }  
         }  
    }
    
    // 收到消息
    public void getMessage(String data) {  
    	// 转发
    	for(Session key : ssMap.keySet()) {
        	try{
        		WSServer tmp = ssMap.get(key);
                tmp.sendMessage(data);
        	} catch (IOException e1) {
                e1.printStackTrace();
            }
        }
    }
      

    public static synchronized int getOnlineCount() {  
        return onlineCount;  
    }  

    public static synchronized void addOnlineCount() {  
        WSServer.onlineCount++;  
    }  

    public static synchronized void subOnlineCount() {  
        WSServer.onlineCount--;  
    }
}

