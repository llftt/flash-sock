package mmo;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;

import mmo.policy.PolicyServer;

public class Server extends Thread{
	
	private Socket sock;
	private ServerSocket serverSock;
	
	public Server(int port){
		try {
			serverSock = new ServerSocket(port);
		} catch (IOException e) {
			
			e.printStackTrace();
		}
	}
	
	public void run(){
		try {
			while((sock = serverSock.accept()) != null){
				System.out.println(sock.getInetAddress().toString()+"connected");
				new HandlerThread(sock).start();
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	public static void main(String[] args) {
		new Server(8989).start();
		//如果不再843端口监听，则<policy-file-request/>会在8989中收到，分离处理
		new PolicyServer().start();
	}
}
