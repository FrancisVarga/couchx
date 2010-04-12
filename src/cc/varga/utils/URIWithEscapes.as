package cc.varga.utils {
	import com.adobe.net.URI;
	
	public class URIWithEscapes extends URI
	{
		public function URIWithEscapes()
		{
			super();
		}
		
		public function setQueryParam(name:String, value:*) : void {
			
			if (value is String) {
				value = "\""+value+"\"";
			}
			super.setQueryValue(name,value);
		}
		
	}
}