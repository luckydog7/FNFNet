import { Room, Client, matchMaker } from "colyseus";
import { Stuff } from "./schema/Stuff";
import * as readline from 'readline';

let rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});
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
export class BattleRoom extends Room<Stuff> {

  public static stuff: string;
  static chatHistory: string;
  onCreate (options: any) {
    this.setState(new Stuff());

    this.onMessage("string", async (client, message) => {
        if (message.join){
            const room = await matchMaker.createRoom("battle", { mode: "duo" });
            
        }
    });
  }
  onJoin (client: Client, options: any) {

  }

  onLeave (client: Client, consented: boolean) {

  }

  onDispose() {
    console.log("room", this.roomId, "disposing...");
  }

}