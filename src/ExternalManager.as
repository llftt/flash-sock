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
		private var loggerFunc:Function;

		private var COMMANDS:Object = {
			'connect_server' : connectServer,
			'close_socket':closeSocket,
			'send_data':sendData,
			'test':test
		}
		
		public function ExternalManager(logger:Function)
		{
			this.loggerFunc = logger;
			socketServerClient = new SocketServerClient();
			if(ExternalInterface.available)
			{
				ExternalInterface.addCallback('socketFlash.Command', onCommand);
				ExternalInterface.addCallback('test', test);
//				ExternalInterface.call('console.log', 'externalManager'); //for test execute
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
			logger(Global.ns);
			return result;
		}

		public function ready():void {
			try{
				var isReady = ExternalInterface.call(addNamespace("FlashSocketReady")); //
				if(!isReady){
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
			ExternalInterface.call(addNamespace("receive_data"),str);
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
		
		private function onCommand(command:String, params:Object = null):void
		{
			var that = this;
			consoleLogger('onCommand invoke as func'+command);
			var cmdFunc:Function =  COMMANDS[command];
			cmdFunc.apply(that, [params]);
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
			buffer.writeObject(data);
			buffer.position = 0;
			socketServerClient.sendMessageByte(buffer);	
		}
		
		
		public function logger(msg:String):void
		{
			this.loggerFunc.apply(null, [msg]);
		}
		//--------------------------test-------------------------
		
		private function test(msg:String):void
		{
			consoleLogger('test'+msg);
//			logger('js invoke as func'+msg);
		}
		
		
		
		public function consoleLogger(msg:String):void
		{
			if(Global.debug)
			{
				ExternalInterface.call("console.log", msg);
			}	
		}
	}
}