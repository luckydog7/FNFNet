const readline = require("readline");
import * as fs from 'fs';
import { ChatRoom } from '../rooms/ChatRoom';
//why did i mix 2 variants of importing libraries
var ass: string;
const rl = readline.createInterface({
    input: process.stdin,
    output: ass
});
export class commandHandler {
    static start(){
        rl.question(">", function(cmd:string) {
            switch(cmd){
                case 'stop':
                    console.log("\nShutting down the server!");
                    process.exit(0);
                case 'save':
                    console.log(ChatRoom.chatHistory);
                    fs.writeFileSync('chatHistory.txt', ChatRoom.chatHistory);
            }
            commandHandler.start();
        });
    }
}

