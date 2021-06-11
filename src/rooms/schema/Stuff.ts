import { Schema, Context, type } from "@colyseus/schema";
import { ChatRoom } from "../ChatRoom";

export class Stuff extends Schema {

  @type("string") message: string;
  //public static stuff: string = string.mySynchronizedProperty;
  @type("string") chatHist: string;

  @type("string") recvprev: string;

  @type("string") start: string;

  @type('int32') retnumber: number;

  @type("int32") axY: Number = 0;

}
