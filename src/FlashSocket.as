package
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class FlashSocket extends Sprite
	{
		private var externalManager:ExternalManager;
		
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
			trace('init');
			removeEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(Event.ENTER_FRAME, handleEnterFrame);
		}
		
		/**解决国产浏览器有缓存情况下，依赖舞台宽高原件 高度为0的bug*/
		private function handleEnterFrame(evt:Event):void
		{
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
		 * 延迟处理ExternalInterface问题,
		 * */
		private function registerCallbacks(evt:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, registerCallbacks);
			externalManager = new ExternalManager();
			externalManager.ready();
			trace('registerCallbacks');
		}
	}
}