// 
// THIS FILE HAS BEEN GENERATED AUTOMATICALLY
// DO NOT CHANGE IT MANUALLY UNLESS YOU KNOW WHAT YOU'RE DOING
// 
// GENERATED USING @colyseus/schema 1.0.23
// 


import io.colyseus.serializer.schema.Schema;
import io.colyseus.serializer.schema.types.*;

class Stuff extends Schema {
	@:type("string")
	public var message: String = "";

	@:type("string")
	public var chatHist: String = "";

	@:type("string")
	public var recvprev: String = "";

	@:type("int32")
	public var axY: Int = 0;

}
