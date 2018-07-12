package
{
	public class Global
	{
		public static var ns : String = ""; //js函数注册的命名空间
		public static var debug:Boolean = true; //是否输出信息
		public static var sockTest:Boolean = true; //调试sock接口参数，默认为false
		public static var needParsePolicy:Boolean = true; //是否解析sock返回策略文件
		/**
		 * 全局配置，通过获取嵌入的swf参数初始化
		 * */
		public function Global()
		{
		}
		
		public static function init(param:Object):void
		{
			ns = param["ns"] || ns;
			debug = (param['debug'] == 'true' || parseInt(param['debug']) == 1) || debug;
			needParsePolicy = param['sockPolicy'] || needParsePolicy;
			sockTest = param["sockTest"] ||  sockTest;
		}
	}
}