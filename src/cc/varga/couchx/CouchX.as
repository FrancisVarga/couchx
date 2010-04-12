package cc.varga.couchx {
	import com.adobe.net.URI;
	import com.adobe.serialization.json.JSON;
	import com.adobe.serialization.json.JSONDecoder;
	
	import flash.desktop.DockIcon;
	import flash.events.ErrorEvent;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	
	import org.httpclient.HttpClient;
	import org.httpclient.events.HttpDataListener;
	import org.httpclient.events.HttpErrorEvent;
	import org.httpclient.events.HttpResponseEvent;

	public class CouchX extends EventDispatcher {
		
		private static const APP_JSON : String = "application/json";
		
		private static var host : String;
		private static var databaseName : String;
		private static var _Instance : CouchX;
		private static var _uuidList : Array;

		public function CouchX(databaseName : String, host : String = "http://127.0.0.1:5984") {
			
			_Instance = this;
			
			CouchX.host = host;
			CouchX.databaseName = databaseName;
			
		}

		public function getDocument(id : String) : void {
			
			var listener : HttpDataListener = new HttpDataListener();
			listener.onDataComplete = getHandler;
			var client : HttpClient = httpClient(listener);
			client.get(new URI(dbURL + "/" + id));
			
		}
		
		public function getAllDocuments():void{
			
			var listener : HttpDataListener = new HttpDataListener();
			listener.onDataComplete = onGetAllDocuments;
			var client: HttpClient = new HttpClient();
			client.listener = listener;
			client.get(new URI(dbURL + "/_all_docs"));
			
		}

		public function deleteDocument(id : String, revision : String) : void {
			
			var listener : HttpDataListener = new HttpDataListener();
			listener.onDataComplete = deleteHandler;
			var client : HttpClient = httpClient(listener);
			var bytes : ByteArray = new ByteArray();
			
			client.del(new URI(dbURL + "/" + id + "?rev=" + revision));
			
		}
		
		public function createDocument(object : Object) : void {
			
			var listener : HttpDataListener = new HttpDataListener();
			listener.onDataComplete = postHandler;
			
			var client : HttpClient = httpClient(listener);
			var bytes : ByteArray = new ByteArray();
			bytes.writeUTFBytes(JSON.encode(object));
			bytes.position = 0;
			client.post(new URI(dbURL), bytes, "application/json");
			
		}
		
		public function putDocument(id : String, object : Object) : void {		
			
			var listener : HttpDataListener = new HttpDataListener();
			listener.onDataComplete = putHandler;
			var client : HttpClient = httpClient(listener);
			var bytes : ByteArray = new ByteArray();
			bytes.writeUTFBytes(JSON.encode(object));
			bytes.position = 0;
			client.put(new URI(dbURL + "/" + id), bytes, "application/json");
			
		}
		
		public function updateDocument(data : Object):void{
			
			var listener : HttpDataListener = new HttpDataListener();
			listener.onDataComplete = onPostDataComplete;
			var client : HttpClient = httpClient(listener);
			
			var bytes : ByteArray = new ByteArray();
			var newData : * = JSON.encode(data);
			bytes.writeUTFBytes(newData);
			bytes.position = 0;
			var uri : URI = new URI(dbURL + "/" + URI.escapeChars(data._id));
			client.put(uri, bytes, APP_JSON);
			
		}

		public function view(design : String, view : String, queryString : String) : void {
			
			var listener : HttpDataListener = new HttpDataListener();
			listener.onDataComplete = viewHandler;
			var client : HttpClient = httpClient(listener);
			client.get(new URI(dbURL + "/_design/" + design + "/_view/" + view + "?" + queryString));
			
		}

		public function putAttachment(document : Object, fileStream : *, contentType : String, name : String) : void {
			
			var listener : HttpDataListener = new HttpDataListener();
			listener.onDataComplete = putAttachmentHandler;
			
			listener.onError = errorHandler;
			var client : HttpClient = httpClient(listener);
		
			client.upload(new URI(dbURL + "/" + URI.escapeChars(document["_id"]) + "/" + name + "?rev=" + document["_rev"]), fileStream, "PUT");
		
		}

		public function urlForAttachment(document : Object, attachmentName : String) : String {
		
			return dbURL + "/" + document["_id"] + "/" + attachmentName + "?rev=" + document["_rev"];
		
		}

		public function getUUID(count : int = 10000) : void {
			
			var listener : HttpDataListener = new HttpDataListener();
			listener.onDataComplete = uuidHandler;
			
			listener.onError = errorHandler;
			var client : HttpClient = httpClient(listener);
			
			client.get(new URI(host + "/_uuids?count=" + count));
			
		}

		public function get UUID() : String {
			
			var uuid : String;
			
			if(CouchX._uuidList.length > 100) {
				uuid = CouchX._uuidList.shift();	
			} else {
				getUUID(100000);	
				uuid = CouchX._uuidList.shift();		
			}
			
			return uuid;
			
		}
		
		private function onPostDataComplete(event : HttpResponseEvent, data : ByteArray):void{
			
			trace("Post Data Complete");
			
		}
		
		private function onGetAllDocuments(event : HttpResponseEvent, data : ByteArray):void{
			dispatchEvent(new CouchXEvent(data, CouchXEvent.GET_ALL_DOCUMENTS));
		}

		private function uuidHandler(event : HttpResponseEvent, data : ByteArray) : void {
			
			var jsonString : String = data.toString();
			
			var tmp : * = JSON.decode(jsonString);
			CouchX._uuidList = tmp["uuids"];
			
			dispatchEvent(new CouchXEvent(data, CouchXEvent.GET_UUIDS_COMPLETE));
			
		}

		protected function httpClient(listener : HttpDataListener) : HttpClient {
			var client : HttpClient = new HttpClient();
			client.listener = listener;
			return client;
		}

		private function viewHandler(event : HttpResponseEvent, data : ByteArray) : void {
			dispatchEvent(new CouchXEvent(data, CouchXEvent.GET_VIEW_COMPLETE));
		}					 

		private function errorHandler(event : HttpErrorEvent) : void {
			trace("Error Occured: " + event); 
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR));
		}

		private function postToExternalHandler(event : HttpResponseEvent, data : ByteArray) : void {
			dispatchEvent(new CouchXEvent(data, CouchXEvent.POST_TO_EXTERNAL_HANDLER_COMPLETE));
		}

		private function deleteHandler(event : HttpResponseEvent, data : ByteArray) : void {
			dispatchEvent(new CouchXEvent(data, CouchXEvent.DELETE_COMPLETE));
		}

		private function getHandler(event : HttpResponseEvent, data : ByteArray) : void {
			dispatchEvent(new CouchXEvent(data, CouchXEvent.GET_COMPLETE));			
		} 

		private function putHandler(event : HttpResponseEvent, data : ByteArray) : void {
			dispatchEvent(new CouchXEvent(data, CouchXEvent.PUT_COMPLETE));			
		}

		private function postHandler(event : HttpResponseEvent, data : ByteArray) : void {
			dispatchEvent(new CouchXEvent(data, CouchXEvent.POST_COMPLETE));			
		}

		private function putAttachmentHandler(event : HttpResponseEvent, data : ByteArray) : void {
			if(event.response.code == "500") {
				trace("Error" + event);	
			} else {
				trace("Put Attachment Complete");
				dispatchEvent(new CouchXEvent(data, CouchXEvent.PUT_ATTACHMENT_COMPLETE));
			}
		}
		
		private static function get Instance():CouchX{
			return _Instance;
		}

		private function postDocumentWithAttachmentHandler(event : HttpResponseEvent, data : ByteArray) : void {
			dispatchEvent(new CouchXEvent(data, CouchXEvent.POST_DOCUMENT_WITH_ATTACHMENT_COMPLETE));
		}

		protected function get dbURL() : String {
			return host + "/" + databaseName;
		}
	}
}