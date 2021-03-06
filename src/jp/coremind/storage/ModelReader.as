package jp.coremind.storage
{
    import flash.utils.Dictionary;
    
    import jp.coremind.core.StorageAccessor;
    import jp.coremind.storage.transaction.Diff;
    
    /**
     * Storageクラスに格納されているデータの読み出しと変更監視の制御するクラス.
     */
    public class ModelReader extends StorageAccessor
    {
        public static const LISTENER_PRIORITY_ELEMENT             :int = 0;
        public static const LISTENER_PRIORITY_GRID_LAYOUT         :int = 100;
        public static const LISTENER_PRIORITY_LIST_ELEMENT_FACTORY:int = 200;
        
        protected var
            _id:String,
            _type:String,
            _priorityList:Dictionary,
            _listenerList:Vector.<IModelStorageListener>;
        
        public function ModelReader(id:String, type:String = StorageType.HASH)
        {
            _id               = id;
            _type             = type;
            _priorityList     = new Dictionary(true);
            _listenerList     = new <IModelStorageListener>[];
        }
        
        public function destroy():void
        {
            var p:*;
            
            for (p in _priorityList)  delete _priorityList[p];
            
            _listenerList.length = 0;
        }
        
        public function get id():String           { return _id; }
        public function get type():String         { return _type; }
        public function read():*                  { return storage.read(this); }
        public function readTransactionResult():* { return storage.readTransactionResult(this); }
        
        public function hasListener():Boolean
        {
            return _listenerList.length != 0;
        }
        
        public function createKeyList():Vector.<String>
        {
            var result:Vector.<String>;
            var storageData:* = read();
            
            if (storageData is Array)
                result = new Vector.<String>([storageData]);
            else
            if ($.isHash(storageData))
            {
                result = new <String>[];
                for (var p:String in storageData) result.push(p);
            }
            
            return result;
        }
        
        public function addListener(listener:IModelStorageListener, priority:int = 0):void
        {
            if (listener in _priorityList) return;
            
            _priorityList[listener] = priority;
            for (var i:int = 0, len:int = _listenerList.length; i < len; i++) 
            {
                if (_priorityList[_listenerList[i]] < priority)
                {
                    _listenerList.splice(i, 0, listener);
                    return;
                }
            }
            
            _listenerList.push(listener);
        }
        
        public function removeListener(listener:IModelStorageListener):void
        {
            if (listener in _priorityList)
            {
                delete _priorityList[listener];
                _listenerList.splice(_listenerList.indexOf(listener), 1);
            }
        }
        
        public function dispatchByPreview(diff:Diff):void
        {
            for (var i:int = 0; i < _listenerList.length; i++) 
                _listenerList[i].preview(diff);
        }
        
        public function dispatchByCommit(diff:Diff):void
        {
            for (var i:int = 0; i < _listenerList.length; i++) 
                _listenerList[i].commit(diff);
        }
    }
}