package flashsocket
{
	import flash.events.Event;

	public class SSEvent extends Event
	{
		public var params:Object;
		public static const onConnection:String = "onConnection";
		public static const onConnectionLost:String = "onConnectionLost";
		
		public static const onReceiveRawData:String = "onReceiveRawData";
		
		public function SSEvent(type:String, params:Object)
		{
			super(type);
			this.params = params;
		}
	}
}