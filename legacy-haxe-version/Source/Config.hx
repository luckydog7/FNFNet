package;
import sys.io.File.getContent;

typedef ConfigData = {
    var addr:String;
    var port:Int;
    var maxcons:Int;
}

class Config {
    public static var s = getContent("config.json");
    public static var data:ConfigData = haxe.Json.parse(s);
}