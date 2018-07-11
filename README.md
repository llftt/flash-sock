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
			<!DOCTYPE cross-domain-policy SYSTEM "http://www.adobe.com/xml/dtds/cross-domain-policy.dtd"> 
			  <cross-domain-policy> 
				<site-control permitted-cross-domain-policies="all" />
			    <allow-access-from domain="*" /> 
			    <allow-http-request-headers-from domain="*" headers="*"/>
			    </cross-domain-policy>
	
	3. flashvars中的ns如果不用命名空间，可以不传或者ns=即可，如果传ns='',则js函数命名空间为. 
	
	====================================
	7.11 定义并联调与js交互的接口，增加test.html测试文件以及app.js本地服务文件， ExternalInterface需要启动服务调用才生效
