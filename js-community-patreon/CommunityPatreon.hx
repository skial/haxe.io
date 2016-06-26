package ;

import tink.Json.*;

typedef PatreonPayload = {
	var data:Array<PatreonData>;
}

typedef PatreonData = {
	var uri:String;
	@:optional var name:String;
	@:optional var patrons:Int;
	@:optional var income:Float;
	@:optional var profile:String;
	@:optional var summary:String;
	@:optional var description:String;
	@:optional var update:Null<String>;
	@:optional var links:Array<String>;
	@:optional var keywords:Array<String>;
	@:optional var duration:PatreonDuration;
}

@:enum abstract PatreonDuration(String) from String to String {
	public var Month = 'per month';
	public var Creation = 'per creation';
}

class CommunityPatreon {
	
	public static function main() {
		new CommunityPatreon();
	}
	
	public function new() {
		
	}
	
}
