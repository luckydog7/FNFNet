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
/*
      this.onMessage("string", async (client, message) => {

    }
        if (message.join){
            const room = await matchMaker.createRoom("battle", { mode: "duo" });
            
        }
    });
*/
interface PlayerData {
  name:string,
  ready:boolean,
  score:number
}
export class BattleRoom extends Room<Stuff> {
  scorep1:number;
  scorep2:number;

  player1:PlayerData;
  player2:PlayerData;
  
  p1ready:Boolean;
  p2ready:Boolean;

  song: string;
  diff: number;
  week: number;
  maxClients = 2;
  public static stuff: string;
  onCreate (options: any) {
    this.setState(new Stuff());
    this.autoDispose = true;
    this.song = "";
    this.diff = 0;
    this.week = 0
    this.scorep1 = 0;
    this.scorep2 = 0;
    console.log(this.roomId);
    
    this.onMessage('misc', (client, message) => {
      try{
        if(client.sessionId == this.clients[0].sessionId) this.p1ready = message.ready;
        else this.p2ready = message.ready;
        if(this.p1ready && this.p2ready)this.safeSend('start');
        this.safeSend('misc', {p1: this.p1ready, p2: this.p2ready});
      }catch(e){
        console.log(e);
      }
    });
    this.onMessage('songname', (client, message) => {
      this.setMetadata({song: message.song});
      this.song = message.song;
      this.diff = message.diff;
      this.week = message.week
      try{
        client.send("creatematch", {song: message.song, diff: message.diff, week: message.week});
      }catch(err){
        console.log(err);
      }
    });
    this.onMessage("message", (client, message) => {
      console.log(message.rating);
      if(client.sessionId == this.clients[0].sessionId){
        switch(message.rating){
          case 'shit':
            this.scorep1 += 50;
          case 'bad':
            this.scorep1 += 100;
          case 'good':
            this.scorep1 += 200;
          case 'sick':
            this.scorep1 += 350;
        }
      }else{
        switch(message.rating){
          case 'shit':
            this.scorep2 += 50;
          case 'bad':
            this.scorep2 += 100;
          case 'good':
            this.scorep2 += 200;
          case 'sick':
            this.scorep2 += 350;
        }
      }
      try{
        this.clients[0].send("retscore", {p1score: this.scorep1, p2score: this.scorep2});
        this.clients[1].send("retscore", {p1score: this.scorep1, p2score: this.scorep2});
      }catch(error){
        console.log(error);
      }
    });
  }
  onJoin (client: Client, options: any) {
    console.log('client joined');
    if(this.clients.length != 2) try{ client.send("message", {iden: this.roomId}); }catch(error){ console.log(error); }
    if(this.clients.length >= 2) {
      try{
        setTimeout(() => {
          this.clients[1].send('message', {song: this.song, diff: this.diff, week: this.week});
        }, 2000);
      }catch(error){ console.log(error); }
    }
  }

  onLeave (client: Client, consented: boolean) {
    console.log("the score is: " + this.scorep1);
  }

  onDispose() {
    console.log("room", this.roomId, "disposing...");
  }
  safeSend(type:string, data:any = {}){
    if(this.clients.length<2) this.clients[0].send(type, data);
    else{
      this.clients[0].send(type, data);
      this.clients[1].send(type, data);
    }
  }
}