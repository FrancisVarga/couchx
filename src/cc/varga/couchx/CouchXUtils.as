package cc.varga.couchx
{
	import cc.varga.couchx.CouchX;

	public class CouchXUtils
	{
		
		public static var DATABASE_NAME : String;
		
		public function CouchXUtils()
		{
		}
		
		public static function creatCouchX():CouchX{
			
			var couchx : CouchX = new CouchX(DATABASE_NAME);
			return couchx;
			
		}
	}
}