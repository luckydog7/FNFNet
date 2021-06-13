import { Room, Client } from "colyseus";
import { Stuff } from "./schema/Stuff";
import * as readline from 'readline';
import * as fs from 'fs';
import fetch from 'cross-fetch';
import { discord } from "../modules/discord";
/////////////////////////////////////////
//
//      FNFNet
//        Created by bit of trolling
//      Legend:
//      test - amount of users
//      theY - y position of chatText
//      
//
/////////////////////////////////////////
var amUsers: number;
var theY: number = 0;
var users:Array<String> = new Array();
var uuids:Array<String> = new Array();
var hasAdmin:Array<Boolean> = new Array();
var chatHistory:String;
var thefullassmessage:String;
var test: number;
var config = JSON.parse(fs.readFileSync("config.json", "utf-8"));
const dsc = new discord();
export class ChatRoom extends Room<Stuff> {

  public static stuff: string;
  public static chatHistory: string;
  onCreate (options: any) {
    this.setState(new Stuff());
    this.autoDispose = false;
    this.onMessage("message", (client, message) => {
      console.log(message.message);
      var partofthefullassmessage:string = message.message;
      if(partofthefullassmessage.startsWith(">")){
        partofthefullassmessage = '[G]' + partofthefullassmessage + '[G]';
      }
      thefullassmessage = "<" + users[uuids.indexOf(client.sessionId)] + "> " + partofthefullassmessage; 
      chatHistory += thefullassmessage + "\n";
      theY -= 20;
      this.broadcast('message',{ message: thefullassmessage});
      if(config.discord.enabled) dsc.send(config.discord.url, thefullassmessage);
    });
    
    this.onMessage("userdata", (client, message) => {      
      users[uuids.indexOf(client.sessionId)] = message.usname;
      this.broadcast('reul', {uslist: users});
    });
  }
  onJoin (client: Client, options: any) {
    console.log(client.sessionId, "joined!");
    test++;
    uuids.push(client.sessionId);
    hasAdmin.push(false);
    console.log(theY);
    var motd = fs.readFileSync("motd.txt", "utf-8");
    var rules = fs.readFileSync("rules.txt", "utf-8");
    console.log(motd);
    chatHistory += "Server: User has joined the chat!" + "\n";
    theY -= 20;
    client.send("recvprev", { chatHist: chatHistory, axY: theY as unknown as string, motd: motd, rules: rules}); // - 1  chathist: chatHistory, axY: theY, motd: motd, rules: rules, uslist: users
    this.broadcast("message", {message: "Server: User has joined the chat!"}, {except: client})
  }

  onLeave (client: Client, consented: boolean) {
    console.log(client.sessionId, "left!");
    users.splice(uuids.indexOf(client.sessionId), 1);
    hasAdmin.splice(uuids.indexOf(client.sessionId), 1);
    uuids.splice(uuids.indexOf(client.sessionId), 1);
    //uuids.remove(client.sessionId);
    test--;
    chatHistory += "Server: User has disconnected from the chat." + "\n";
    theY -= 20;
    this.broadcast('reul', {uslist: users, message: "Server: User has disconnected from the chat.\n"});
    client.leave();
  }

  onDispose() {
    console.log("room", this.roomId, "disposing...");
  }

}
/*
package;

import networking.Network;
import networking.utils.NetworkEvent;
import networking.utils.NetworkMode;
import Config.data;

using StringTools;
/////////////////////////////////////////
//
//      FNFNet
//        Created by bit of trolling
//      Legend:
//      test - amount of users
//      theY - y position of chatText
//      
//
/////////////////////////////////////////

class Main extends FreeplayServer {
    public static var amUsers:Int;

    public static var theY:Float;

    public static var users:Array<String>;
    public static var uuids:Array<String>;
    public static var hasAdmin:Array<Bool>;

    public static var chatHistory:String;
    public static var thefullassmessage:String;

    public static function main(){
      #if linux
      var output = new sys.io.Process("whoami", []).stdout.readAll().toString();
      if (output=="root" && Sys.args()[0] != "--root") {
        cpp.Lib.print("Warning: You are running the server as root, which is strongly discouraged!\nOnly run this server as root if you know what you are doing!\nIf you want to run this as root anyway, pass the --root parameter.\n");
      }
      #end

      users = [];
      uuids = [];
      hasAdmin = [];

      var motd = sys.io.File.getContent("motd.txt");
      var rules = sys.io.File.getContent("rules.txt");
      
        var server = Network.registerSession(NetworkMode.SERVER, { 
            ip: data.addr,
            port: data.port,
            max_connections: data.maxcons
        });
        theY += 0.1;
        cpp.Lib.print("Server has started up!\n>");
        var test:Int = -1;

        server.addEventListener(NetworkEvent.CONNECTED, function(event: NetworkEvent) {
            test++;
            uuids.push(server.clients[test].uuid);
            hasAdmin.push(false);
            server.clients[test].send({ chathist: chatHistory, axY: theY, motd: motd, rules: rules, uslist: users}); // - 1
            server.send({message: "Server: User has joined the chat!", uslist: users});
            chatHistory += "Server: User has joined the chat!" + "\n";
            cpp.Lib.print("User has connected!\n");
            theY -= 20;
          });
          
          server.addEventListener(NetworkEvent.DISCONNECTED, function(event: NetworkEvent) {
            users.splice(uuids.indexOf(event.client.uuid), 1);
            hasAdmin.splice(uuids.indexOf(event.client.uuid), 1);
            uuids.remove(event.client.uuid);
            test--;
            cpp.Lib.print("User has disconnected!\n");
            server.send({message: "Server: User has disconnected from the chat."});
            chatHistory += "Server: User has disconnected from the chat." + "\n";
            theY -= 20;
            server.send({uslist: users});
          });

          server.addEventListener(NetworkEvent.MESSAGE_RECEIVED, function(event: NetworkEvent) {
            if(event.data.message != null) theY -= 20;
            if(event.data.nen != null) users.push(event.data.nen);
            if(event.data.message != null){
              thefullassmessage = "<" + event.data.name + "> " + event.data.message;
              cpp.Lib.print(thefullassmessage + "\n");
              chatHistory += thefullassmessage + "\n";
              server.send({message: thefullassmessage});
            }
          });
          server.start();

            sys.thread.Thread.create(() -> {
              while(true)
                switch(Sys.stdin().readLine()){
                  case "stop":
                    for(client in server.clients) {
                      server.disconnectClient(client);
                    }
                    cpp.Lib.print("Server is shutting down!\n");
                    server.stop();
                    Sys.exit(0);
                  case "kick":
                    cpp.Lib.print("Who do you want to kick?\n");
                    var victim = Sys.stdin().readLine();
                    if(users.indexOf(victim) == -1) cpp.Lib.print("Could not find user in the list!\n");
                    if(users.indexOf(victim) >= 0){
                      server.disconnectClient(server.clients[users.indexOf(victim)]);
                    }
                  case "list":
                    cpp.Lib.print("There are " + (test + 1) + " connected right now.\n");
                    for(i in 0...users.length){
                      cpp.Lib.println(users[i]);
                    }
                  case "test":
                    cpp.Lib.print("The server is working properly.\n");
                    cpp.Lib.print(uuids + "\n");
                    cpp.Lib.print(users + "\n");
                  case "save":
                    sys.io.File.saveContent("ChatHistory.txt", chatHistory);
                    cpp.Lib.print("Saved the chat history to ChatHistory.txt!\n");
                  case "fetch":
                    chatHistory = sys.io.File.getContent("ChatHistory.txt");
                    cpp.Lib.print("Fetched the previous chat history!\n");
                  case "say":
                    var r = ~/^say /gm;
                    var stuff = Sys.stdin().readLine();
                    r.replace(stuff, "");
                    server.send({message: "Server: " + stuff});
                  case "op":
                    cpp.Lib.print("Who do you want to give admin?\n");
                    var victim = Sys.stdin().readLine();
                    if(users.indexOf(victim) == -1) cpp.Lib.print("Could not find user in the list!\n");
                    if(users.indexOf(victim) >= 0){
                      hasAdmin[users.indexOf(victim)] = true;
                      server.clients[users.indexOf(victim)].send({message: "You are now an admin.\n"});
                    }
                  case "clear":
                    chatHistory = "";
                    theY = 0;
                    cpp.Lib.print("Cleared the chat history!\n");   
                  case "help":
                    cpp.Lib.print("list - list all online users\ntest - check if the server works properly\nsave - save the current chat history to a text file\nfetch - fetch the previous chat history\nclear - clears the chat history\n");  
                  default:
                    cpp.Lib.print("Unknown command. Type help for list of available commands.\n>");	
              }
            });     
    }
}
*/