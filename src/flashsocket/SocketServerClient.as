package flashsocket
{
	import com.junkbyte.console.Cc;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	/**
	 * @author lixiangfei
	 * FlashSocket类，负责连接，处理数据，关闭等操作
	 * */
	public class SocketServerClient extends EventDispatcher
	{
		private var connected:Boolean;
		
		private var socketConnection:Socket;
		
		private var byteBuffer:ByteArray;
		public var ipAddress:String;
		public var port:int = 9339;
		private var handledPolicyFile:Boolean = false;
		private var waitingForHeader:Boolean = true;
		private var bytesNeeded:int;
		
		public function SocketServerClient()
		{
			this.socketConnection = new Socket();
			this.socketConnection.addEventListener(Event.CONNECT, handleSocketConnection);
			this.socketConnection.addEventListener(Event.CLOSE, handleSocketDisconnection);
			this.socketConnection.addEventListener(ProgressEvent.SOCKET_DATA, handleSocketData);
			this.socketConnection.addEventListener(IOErrorEvent.IO_ERROR, handleIOError);
			this.socketConnection.addEventListener(IOErrorEvent.NETWORK_ERROR, handleIOError);
			//通过加载策略文件或者sock连接后，后端通过sock返回sock内容
			/**
			 * crossdomain.xml放在站点根目录，文件内容如下，或者domian改成允许访问的域，或者sock返回策略文件中的策略内容
			 * <?xml version="1.0"?> 
<!DOCTYPE cross-domain-policy SYSTEM "http://www.adobe.com/xml/dtds/cross-domain-policy.dtd"> 
			 * <cross-domain-policy> 
				<site-control permitted-cross-domain-policies="all" />
			    <allow-access-from domain="*" /> 
			    <allow-http-request-headers-from domain="*" headers="*"/>
			    </cross-domain-policy>
			 * */
			this.socketConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleSecurityError);
			this.byteBuffer = new ByteArray();
		}
		
		private function handleSocketConnection(evt:Event):void
		{
			this.isConnected = true;
			Cc.debug("handleSocketConnection");
			dispatchXEvent(SSEvent.onConnection, {success:true});
		}
		
		
		private function handleSocketDisconnection(evt:Event):void
		{
			Cc.debug("handleSocketDisconnection");
			this.initialize();
			var event:SSEvent = new SSEvent(SSEvent.onConnectionLost, {});
			dispatchEvent(event);
		}
		
		private function handleIOError(evt:IOErrorEvent):void
		{
			handleConnectionError(evt);
		}
		
		private function handleSecurityError(evt:SecurityErrorEvent):void
		{
			handleConnectionError(evt);
		}
		
		
		private function handleConnectionError(evt:ErrorEvent):void
		{
			Cc.debug("handleConnectionError:["+evt.text+"]");
			if(!this.connected)
			{
				dispatchConnectionError();
			}else
			{
				dispatchEvent(evt);
				Cc.warn("[WARN] Connection error: " + evt.text);
			}
		}
		
		private function dispatchConnectionError():void
		{
			var params:Object = {};
			params.success = false;
			params.error = "I/O Error";
			dispatchXEvent(SSEvent.onConnection, params);
		}
		
		/**主动关闭连接*/
		public function onCloseSocket():void
		{
			disconnect();
		}
		
		public function get isConnected() : Boolean
		{
			return this.connected;
		}
		
		public function set isConnected(value:Boolean) : void
		{
			this.connected = value;
		}
		
		public function connect(ipAddress:String, port:int = 9339) : void
		{
			if(!connected)
			{
				initialize();
				this.ipAddress = ipAddress;
				this.port = port;
				this.socketConnection.connect(ipAddress, port);
			}else
			{
				trace("*** ALREADY CONNECTED ***");
			}
		}
		
		public function disconnect():void
		{
			if(this.socketConnection.connected)
			{
				this.connected = false;
				this.socketConnection.close();
					
			}	
		}
		
		//----------------------read------------------------------
		private function handleSocketData(evt:ProgressEvent):void
		{
			onBinarySocketData();
		}
		
		private function onBinarySocketData():void
		{
			if(!this.handledPolicyFile) //是否处理过策略文件标志 <xml>的域文件，socket链接上之后后端会首先发送这个过来
			{
				if(this.socketConnection.readUTFBytes(1) == "<")
				{
					while(socketConnection.readByte() != 0)
					{
						
					}
					this.handledPolicyFile = true;
				}
			}
			this.processBinarySocketData();
		}
		
		private function processBinarySocketData():void
		{
			if(!this.isConnected) return;
			if(waitingForHeader)
			{
				if(this.socketConnection.bytesAvailable >= 4)
				{
					this.bytesNeeded = socketConnection.readInt();
					this.waitingForHeader = false;
				}
			}
			if(!this.waitingForHeader)
			{
				if(socketConnection.bytesAvailable >= this.bytesNeeded)
				{
					var byteArray:ByteArray = new ByteArray();
					socketConnection.readBytes(byteArray, 0, bytesNeeded);
					handleBinaryMessage(byteArray);
					this.waitingForHeader = true; 
					processBinarySocketData();
				}
			}
		}
		
		private function handleBinaryMessage(byteArray:ByteArray):void
		{	
			//根据业务处理二进制数据
			if(Global.sockTest)
			{
				var teststr:String = byteArray.readMultiByte(bytesNeeded, 'utf-8');
				Cc.debug("handleBinaryMessage:"+teststr);
			}else
			{	
				dispatchXEvent(SSEvent.onReceiveRawData, {"dataObj":byteArray});
			}
			
		}
		
		/**写入msg*/
		public function writeToSocket(msg:String):void
		{
			if(!this.connected) return;
			var byteArray:ByteArray = new ByteArray();
			byteArray.writeMultiByte(msg, "utf-8");
			byteArray.writeByte(0); //分割---------------
			this.socketConnection.writeBytes(byteArray);
			this.socketConnection.flush();
		}
		
		/**整个消息长度(4字节) + 消息内容的格式*/
		public function sendMessageByte(byteArray:ByteArray):void
		{	
			Cc.debug("SEND["+(byteArray.length+4)+"]");
			this.socketConnection.writeInt(byteArray.length); 
			this.socketConnection.writeBytes(byteArray, 0, byteArray.length);
			this.socketConnection.flush();
		}
		
		private function initialize():void
		{
			this.connected = false;
			this.handledPolicyFile = Global.needParsePolicy ? false : true;
		}
		
		private function dispatchXEvent(evt:String, params:Object):void
		{
			var event:SSEvent = new SSEvent(evt, params);
			this.dispatchEvent(event);
		}
	}
}