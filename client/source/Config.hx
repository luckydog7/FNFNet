package;
import haxe.Json;
#if desktop
import sys.io.File.getContent;
#end
typedef ConfigData = {
    var width:Int;
    var height:Int;
    var fullscreen:Bool;
    var addr:String;
    var resourceaddr:String;
    var port:Int;
}
/**
 *Use the .data method to grab config data.
 
 width = window width

 height = window height

 fullscreen = if fullscreen is enabled

 addr = address for FNFNet
 
 port = port for FNFNet
 */
class Config {
    #if desktop
    public static var s = getContent("config.json"); //#else "{width: 1280, height: 720, fullscreen: false, addr: 'net.fnf.general-infinity.tech', port: '9000'}"; #end
    public static var data:ConfigData = haxe.Json.parse(s);
    #else
    public static var s:String = '{
        "width": 1280,
        "height": 720,
        "addr": "127.0.0.1",
        "resourceaddr": "127.0.0.1",
        "port": 2567
    }';
    
    public static var data:ConfigData = haxe.Json.parse(s);
    #end

}