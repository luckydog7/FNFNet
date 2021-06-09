package;
import cpp.Lib;
import udprotean.server.UDProteanServer;
import udprotean.server.UDProteanClientBehavior;
import sys.net.Host;

class Server {
	public static var amUsers:Int;

	public static function main() {
		var server = new UDProteanServer("0.0.0.0", 9000, EchoClientBehavior);
		
		server.start();
		Lib.print("Server has started up!\n>");
		sys.thread.Thread.create(() -> {
			while(true)
				switch(Sys.stdin().readLine()){
					case "stop":
						Lib.print("Server is shutting down!\n");
						server.stop();
						Sys.exit(0);
					case "list":
						Lib.print("There are " + amUsers + " connected right now.\n>");
					case "test":
						
					default:
						Lib.print("Unknown command. Type help for list of available commands.\n>");	
			}
		});
		while (true)
		{
			
    	server.update();
		}

	}
}

