package mmo;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;

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
	}
}
