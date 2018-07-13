package mmo.policy;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;

import mmo.HandlerThread;

public class PolicyServer extends Thread {
	private Socket sock;
	private ServerSocket serverSock;
	public PolicyServer(){
		try {
			serverSock = new ServerSocket(843);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public void run(){
		try {
			while((sock = serverSock.accept()) != null){
				System.out.println("PolicyServer:"+sock.getInetAddress().toString()+"connected");
				new PolicyHandlerThread(sock).start();
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
