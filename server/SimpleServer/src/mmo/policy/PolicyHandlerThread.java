package mmo.policy;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.Socket;

public class PolicyHandlerThread extends Thread {
	private Socket sock;
	private OutputStream ous;
	private InputStream ins;
	private Boolean hasSendPolicy = false;
	private String crossDomainContent;
	private Boolean hasReadPolicyRequest = false;
	public PolicyHandlerThread(Socket sock){
		this.sock = sock;
		try {
			this.ous = sock.getOutputStream();
			this.ins = sock.getInputStream();
			buildCrossPolicy();
		
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
					System.out.println("Policy recv policy request");
					sendCrossPolicy();
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

}
