package
{
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class FlashSocket extends Sprite
	{
		private var externalManager:ExternalManager;
		
		private var txtInfo:TextField = new TextField();
		
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
				var format:TextFormat = new TextFormat();
				format.size = '18';
				txtInfo.defaultTextFormat = format;
				txtInfo.width = 100;
				txtInfo.multiline = true;
				addChild(txtInfo);
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
				txtInfo.appendText(txt+'\r\n');
			}
		}
	}
}