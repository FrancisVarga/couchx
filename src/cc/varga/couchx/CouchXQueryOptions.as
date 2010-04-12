package cc.varga.couchx {
	import cc.varga.utils.URIWithEscapes;

	import flash.utils.Proxy;
	import flash.utils.flash_proxy;

	// For documentation of all Parameters see: http://wiki.apache.org/couchdb/HTTP_view_API	
	public dynamic class CouchXQueryOptions extends Proxy {

		var queryOptions : Object = new Object();

		public function CouchXQueryOptions() {				
			this.include_docs = false;
			this.group = false;
			this.group_level = 1;
			this.startkey = null;
			this.startkey_docid = null;
			this.endkey = null;
			this.endkey_docid = null;
			this.key = null;
			this.limit = null;
			this.skip = null;
			this.stale = null;
			this.descending = false;
			this.reduce = false;
		}

		
		override flash_proxy function getProperty(name : *) : * {
			return queryOptions[name];
		}

		override flash_proxy function setProperty(name : *, value : *) : void {
			queryOptions[name] = value;
			if (value == null) {
				queryOptions.setPropertyIsEnumerable(name, false);
			} else {
				queryOptions.setPropertyIsEnumerable(name, true);
			}
		}

		
		public function set reduce(reduceValue : Boolean) : void {
			if (reduceValue != queryOptions.reduce) {
				if (reduceValue) {

					queryOptions.setPropertyIsEnumerable("group", true);
					queryOptions.setPropertyIsEnumerable("group_level", true);
				} else {
					queryOptions.setPropertyIsEnumerable("group", false);
					queryOptions.setPropertyIsEnumerable("group_level", false);
				}
			}
		}

		public function get reduce() : Boolean {
			return queryOptions.reduce;
		}

		
		
		public function toString() : String {
			var uri : URIWithEscapes = new URIWithEscapes();
      
			for (var key in queryOptions) {
		  
				uri.setQueryParam(key, queryOptions[key]);
			}
			return uri.query;
		}
	}
}
