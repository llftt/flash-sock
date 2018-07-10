package
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import flashsocket.SSEvent;
	import flashsocket.SocketServerClient;

	public class ExternalManager extends EventDispatcher
	{
		private var socketServerClient:SocketServerClient;
		private var buffer:ByteArray = new ByteArray();
		

		private var COMMANDS:Object = {
			'connect_server' : connectServer,
			'close_socket':closeSocket,
			'send_data':sendData
		}
		
		public function ExternalManager()
		{
			socketServerClient = new SocketServerClient();
			if(ExternalInterface.available)
			{
				ExternalInterface.addCallback('socketFlash.Command', onCommand)
			}
		}
		
		private function initListeners():void
		{
			socketServerClient.addEventListener(SSEvent.onReceiveRawData, onReceiveRawData);
		}
		
		private function onReceiveRawData(evt:SSEvent):void
		{
			var byteArray:ByteArray = evt.params as ByteArray;
			var data:Object = byteArray.readObject();
			var dataObj:Object = {"dataObj":data};
			this.receiveData(dataObj);
		}
		
		private function addNamespace(name : String) : String {
			var result : String = name;
			if(Global.ns != ""){
				result = Global.ns + "." + name;
			}
			return result;
		}

		public function ready():void {
			try{
				var ready : Boolean = ExternalInterface.call(addNamespace("FlashSocketReady"));
				logger('ready');
				if(!ready){
					startReadyTimer();
				}
			}
			catch(e : *){
				startReadyTimer();
			}
		}
		
		public function receiveData(dataObj:Object):void
		{
			var str:String = JSON.stringify(dataObj);
			ExternalInterface.call(addNamespace("onmessage"),str);
		}
		
		private var readyTimer : Timer;
		
		private function startReadyTimer() : void {
			if(readyTimer == null){
				readyTimer = new Timer(1000);
				readyTimer.addEventListener(TimerEvent.TIMER, onReadyTimer)
			}
			readyTimer.start();
		}
		
		private function onReadyTimer(e:TimerEvent):void {
			readyTimer.stop();
			ready();
		}
		
		private function onCommand():Object
		{
			return COMMANDS;
		}
		
		private function connectServer(str:String):void
		{
			var data:Object = JSON.parse(str);
			var ip:String = data['serverIp'];
			var port:String = data['port'];
			if(ip == null || port == null)
			{
				return;
			}
			socketServerClient.connect(ip, parseInt(port));
		}
		
		private function closeSocket():void
		{
			socketServerClient.onCloseSocket();
		}
		
		private function sendData(data:Object):void
		{
			if(data is String)
			{
				socketServerClient.writeToSocket(data as String);
			}else
			{
				buffer.writeObject(data);
				socketServerClient.sendMessageByte(buffer);
				buffer.position = 0;
			}
		}
		
		
		public function logger(msg:String):void
		{
			ExternalInterface.call('console.log',msg);
		}
		//--------------------------test-------------------------
		
	}
}