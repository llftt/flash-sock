package mmo;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.Socket;

public class HandlerThread extends Thread {
	private Socket sock;
	private OutputStream ous;
	private InputStream ins;
	private Boolean hasSendPolicy = false;
	private Boolean waitingForHead = true;
	private int bytesNeed;
	private String crossDomainContent;
	private Boolean hasReadPolicyRequest = false;
	public HandlerThread(Socket sock){
		this.sock = sock;
		try {
			this.ous = sock.getOutputStream();
			this.ins = sock.getInputStream();
//			buildCrossPolicy();
//			sendCrossPolicy();
		} catch (IOException e) {
			e.printStackTrace();
		}
		
	}
	
	public void run(){
		while(true){
			try {
				if(ins.available() == 23 && !hasReadPolicyRequest)
				{
					byte policyByte[] = new byte[23];
					ins.read(policyByte, 0, policyByte.length);
					hasReadPolicyRequest = true;
					System.out.println("HandlerThread recv policy request");
				}
				if(waitingForHead){
					if(ins.available() >= 4){
						byte bytes[] = new byte[ins.available()];
						ins.read(bytes, 0, bytes.length);
						bytesNeed = bytes2Int(bytes);
						waitingForHead = false;
						System.out.println("bytesNeed:"+bytesNeed);
					}
				}
				if(!waitingForHead){
					if(ins.available() >= bytesNeed){
						byte[] datas = new byte[bytesNeed];
						ins.read(datas, 0, datas.length);
						waitingForHead = true;
						String hello = "hello";
						ous.write(int2Bytes(hello.length()));
						ous.write(hello.getBytes());
						ous.flush();
					}
				}
		
			} catch (Exception e) {	
			}
			
		}
	}
	
	private void sendCrossPolicy(){
		if(!hasSendPolicy){
			try {
				ous.write(crossDomainContent.getBytes());
				ous.flush();
				hasSendPolicy = true;
				System.out.println("hasSendPolicy");
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			
		}
	}
	
	private void buildCrossPolicy(){
		StringBuilder sb = new StringBuilder("<cross-domain-policy>");
		sb.append("<allow-access-from domain=\"*\" to-ports=\"");
		sb.append("*").append("\" /></cross-domain-policy>\0");
		crossDomainContent = sb.toString();
	}
	/**
	 * 高位在前接收
	 * */
	private int bytes2Int(byte[] bytes){
		int val = (int) ((bytes[3] & 0xff) | ((bytes[2] & 0xff) << 8) 
				| ((bytes[1] & 0xff) << 16) | ((bytes[0] & 0xff) << 24)); 
		return val;
	}
	
	private byte[] int2Bytes(int value){
		byte[] src = new byte[4];  
	    src[0] = (byte) ((value>>24) & 0xFF);  
	    src[1] = (byte) ((value>>16)& 0xFF);  
	    src[2] = (byte) ((value>>8)&0xFF);    
	    src[3] = (byte) (value & 0xFF); 
	    return src;
	}
	
	
}
