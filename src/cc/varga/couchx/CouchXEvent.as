package cc.varga.couchx {
	import com.adobe.serialization.json.JSON;
	
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	public class CouchXEvent extends Event
	{
		public static const GET_COMPLETE:String = "getComplete";
		public static const GET_VIEW_COMPLETE:String = "getViewComplete";		
		public static const GET_UUIDS_COMPLETE:String = "getUUIDsComplete";
		public static const POST_COMPLETE:String = "postComplete";
		public static const PUT_COMPLETE:String = "putComplete";
		public static const PUT_ATTACHMENT_COMPLETE:String = "putAttachmentComplete";
		public static const POST_DOCUMENT_WITH_ATTACHMENT_COMPLETE:String = "postDocumentWithAttachmentComplete";
		public static const POST_TO_EXTERNAL_HANDLER_COMPLETE:String = "postToExternalHandlerComplete";
		public static const GET_ALL_DOCUMENTS : String = "GET_ALL_DOCUMENTS";
		
		public static const DELETE_COMPLETE:String = "deleteComplete";
		
		private var _data:ByteArray;
		
		public function CouchXEvent(data:ByteArray, type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_data = data;
		}
		
		public function get data():Object {
			return JSON.decode(_data.toString());
		}
	}
}