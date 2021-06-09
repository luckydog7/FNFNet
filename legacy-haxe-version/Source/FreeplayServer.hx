package;

import networking.Network;
import networking.utils.NetworkEvent;
import networking.utils.NetworkMode;
import Config.data;
/////////////////////////////////////////
//
//      FNFNet: Freeplay Server
//        Created by bit of trolling
//      
//      This is a WIP
//      nothing here works yet!
//      
//
/////////////////////////////////////////

class FreeplayServer {
    public function create(){

        var server = Network.registerSession(NetworkMode.SERVER, { 
            ip: data.addr,
            port: 9001,
            max_connections: data.maxcons
        });

        cpp.Lib.print("Server has started up!\n>");

        server.addEventListener(NetworkEvent.CONNECTED, function(event: NetworkEvent) {});
          
        server.addEventListener(NetworkEvent.DISCONNECTED, function(event: NetworkEvent) {});

        server.addEventListener(NetworkEvent.MESSAGE_RECEIVED, function(event: NetworkEvent) {});

        server.start();
    }
}