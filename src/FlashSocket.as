package
{
	import com.junkbyte.console.Cc;
	
	import flash.display.LoaderInfo;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	
	import flashx.textLayout.accessibility.TextAccImpl;
	
	public class FlashSocket extends Sprite
	{
		private var externalManager:ExternalManager;
		
		private var txtInfo:TextField = new TextField();
		private var scrollV:int = 1;
		public function FlashSocket()
		{
			if(stage){
				init();
			}else{
				addEventListener(Event.ADDED_TO_STAGE, init);
			}
		}
		
		private function init(e:Event = null):void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			Global.init(stage.loaderInfo.parameters);
			watch(stage.loaderInfo);
			if(Global.debug)
			{	
				Cc.config.tracing = true;
				Cc.startOnStage(this, "opentracer");
				Cc.debug("SOCK INIT.....");
				Cc.width = 400;
				Cc.height = 300;
				initTestSockUI();
			}
			removeEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(Event.ENTER_FRAME, handleEnterFrame);
		}
		
		/**监控报错*/
		private function watch(loaderInfo:LoaderInfo):void
		{
			if(loaderInfo.hasOwnProperty("uncaughtErrorEvents"))
			{
				loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, uncaughtErrorHandler);
			}
		}
		private function uncaughtErrorHandler(event:ErrorEvent):void
		{
			if(event["error"] is IOErrorEvent)
			{
				return;
			}
			var errorObj:Object = event["error"];
			if(errorObj)
			{
				var message:String;
				if(errorObj is Error)
				{
					message = (errorObj as Error).message;
				}else if(errorObj is ErrorEvent)
				{
					message = (errorObj as ErrorEvent).text;
				}else{
					message = String(errorObj);
				}
				logger('error:'+message);
			}
			
		}
		
		/**解决国产浏览器有缓存情况下，依赖舞台宽高原件 高度为0的bug*/
		private function handleEnterFrame(evt:Event):void
		{
			logger(stage.stageWidth+','+stage.stageHeight);
			if(stage.stageWidth > 0 && stage.stageHeight > 0)
			{
				removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
				onInited();
			}
		}
		
		private function onInited():void
		{
			addEventListener(Event.ENTER_FRAME, registerCallbacks);
		}
		/**
		 * 延迟处理ExternalInterface问题
		 * */
		private function registerCallbacks(evt:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, registerCallbacks);
			logger('registerCallbacks');
			externalManager = new ExternalManager(logger);
			externalManager.ready();
		}
		
		private function logger(txt:String):void
		{
			if(Global.debug)
			{
				Cc.debug(txt);
			}
		}
		
		private var btnConnect:SimpleButton;
		private var btnSend:SimpleButton;
		private function initTestSockUI():void
		{
			if(Global.sockTest){
				addBtns('链接本地sock', onConnectSock, 100, 100);
				addBtns('发送消息', onSendMsg, 100, 200);
			}
		}
		
		private function onConnectSock(evt:MouseEvent):void
		{
			var data:Object = {"serverIp":"localhost","port":"8989"};
			externalManager.connectServer(JSON.stringify(data));
		}
		
		private function onSendMsg(evt:MouseEvent):void
		{
			var buff:ByteArray = new ByteArray();
			buff.writeByte(97);
			buff.writeByte(98);
			buff.writeByte(99);
			externalManager.sendMessageByte(buff);
		}
		
		private function addBtns(desc:String, hander:Function, x:Number, y:Number)
		{
			var sp:Sprite = new Sprite();
			var txt:TextField = new TextField();
			txt.appendText(desc);
			sp.addChild(txt);
			var btn = new SimpleButton(sp,sp,sp,sp);
			btn.addEventListener(MouseEvent.CLICK, hander);
			
			btn.x = x;
			btn.y = y;
			addChild(btn);
		}
	}
}