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
var scorep1:number;
var scorep2:number;
/*
      this.onMessage("string", async (client, message) => {

    }
        if (message.join){
            const room = await matchMaker.createRoom("battle", { mode: "duo" });
            
        }
    });
    */
export class BattleRoom extends Room<Stuff> {

  public static stuff: string;
  static chatHistory: string;
    onCreate (options: any) {
      score = 0;
      this.setState(new Stuff());
  }
  onJoin (client: Client, options: any) {
    this.onMessage("message", (client, message) => {
      console.log(message.rating);
      switch(message.rating){
        case 'shit':
          scorep1 += 50;
        case 'bad':
          scorep1 += 100;
        case 'good':
          scorep1 += 200;
        case 'sick':
          scorep1 += 350;
      }
    });
  }

  onLeave (client: Client, consented: boolean) {
    console.log("the score is: " + score / 2);
  }

  onDispose() {
    console.log("room", this.roomId, "disposing...");
  }

}