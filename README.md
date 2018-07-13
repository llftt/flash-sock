对于不支持WebSocket的浏览器，通常做法是在页面嵌入swf文件，通过js调用as3的方法，通过flash来进行通信，该项目对两种方式进行简单的封装

# Flashsocket
	使用在页面中嵌入，类似下面节点或者使用swfObject开源库嵌入
	
	<div class="wdg-flash-socket-box">
        <object type="application/x-shockwave-flash" id="flashRoute" data="./out/FlashSocket.swf" width="100%" height="100%">
            <param name="allowscriptaccess" value="always">
            <param name="wmode" value="transparent">
            <param name="seamlesstabbing" value="false">
            <param name="flashvars" value="ns=&debug=1">
        </object>
    </div>
	
	js调用As方法
	
	1. connect_server
	   传入参数
	   JSON.stringfy({"serverIp":'',"port":"8989"})
	   传入sock连接的ip以及对应端口号
	2. close_socket
	   主动关闭socket链接
	
	3. send_data
		传入Object对象或者字符串
		
#注意	
	1.数据是采用  消息长度+消息体信息发送与解析,可自己修改代码，用自己的方式编解码
	2.成功连接socket后，后端需要通过sock返回策略文件内容，类似下面策略，域可以改为自己的域
			<?xml version="1.0"?> 
			<cross-domain-policy>
				<allow-access-from domain="*" to-ports="*"(或者指定端口)
			</cross-domain-policy>
	
	3. flashvars中的ns如果不用命名空间，可以不传或者ns=即可，如果传ns='',则js函数命名空间为. 
	
	====================================
	7.11 定义并联调与js交互的接口，增加test.html测试文件以及app.js本地服务文件， ExternalInterface需要启动服务调用才生效
	
    7.12 
              a.增加简单的后台，测试二进制数据发送与接收
              b. 使用console.swc库来进行日志输出
              c.增加配置  sockPolicy 表示是否是sock返回策略文件，默认为true,为false的话，需采用一或二方式，保证可以请求到策略文件，不然会报#2048错误
              	一：需要服务器开启843端口，并且有策略文件 
              	二：传入策略文件的ip和端口号，代码中会调用Security.loadPolicyFile加载策略文件
          //-------------------------------------------------------------------------
                        发现：
                        a.嵌入swf文件的html，如果没有起服务，链接sock无效
           		  b.网页中请求socket,会先向后端发送  //<policy-file-request/>
			     [60, 112, 111, 108, 105, 99, 121, 45, 102, 105, 108, 101, 45, 114, 101, 113, 117, 101, 115, 116, 47, 62, 0];
              	
              	
=========================================================================
7.13
	a.   2048错误，因为策略文件返回有问题，没有加端口
 			<cross-domain-policy>
				<allow-access-from domain="*" to-ports="*"(或者指定端口)
			</cross-domain-policy>
	b.策略文件请求顺序
		一：先请求服务器端的843端口，获取crossdomain.xml,如果没有开启
		二：查看是否调用Security.loadPolicyFile("xmlsocket://42.186.14.148:843") ip+端口号
		三：查看发起请求的swf要连接的目标端口有没有策略文件
			如果服务器843端口未开启，则目标端口会收到 <policy-file-request/>