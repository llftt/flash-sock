package
{
	public class Global
	{
		public static var ns : String = ""; //js函数注册的命名空间
		/**
		 * 全局配置，通过获取嵌入的swf参数初始化
		 * */
		public function Global()
		{
		}
		
		public static function init(param:Object):void
		{
			param = param || {};
			ns = param["ns"] || ns;
		}
	}
}