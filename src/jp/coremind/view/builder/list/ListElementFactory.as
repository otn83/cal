package jp.coremind.view.builder.list
{
    import flash.utils.Dictionary;
    
    import jp.coremind.configure.IElementBluePrint;
    import jp.coremind.core.Application;
    import jp.coremind.storage.IModelStorageListener;
    import jp.coremind.storage.ModelReader;
    import jp.coremind.storage.transaction.Diff;
    import jp.coremind.utility.IRecycle;
    import jp.coremind.utility.InstancePool;
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.builder.element.ElementBuilder;
    
    /**
     * ListConatinerクラスインスタンスの子インスタンスを生成を制御するクラス.
     * requestメソッドでインスタンスを生成する。
     * このクラスから生成されたインスタンスは内部でInstancePoolクラスで管理されているため,
     * 明示的に不要になった事を通知(recycleメソッドの呼び出し)する必要がある。
     * @see InstancePool
     */
    public class ListElementFactory implements IModelStorageListener
    {
        public static const TAG:String = "[ListElementFactory]";
        Log.addCustomTag(TAG);
        
        protected var
            _reader:ModelReader,
            _pool:InstancePool,
            _createdInstance:Dictionary,
            _builderCache:Object;//こまめにElementが追加削除を繰り返す場合Builder取得(呼び出し時に生成している)コストが高くなるので一度使ったbuilderはキャッシュしておく 

        public function ListElementFactory()
        {
            _pool            = new InstancePool();
            _createdInstance = new Dictionary(true);
            _builderCache    = {};
        }
        
        public function destroy():void
        {
            _reader.removeListener(this);
            _reader = null;
            
            _pool.destroy();
            
            for (var q:* in _createdInstance) delete _createdInstance[q];
            
            for (var p:* in _builderCache) delete _builderCache[p];
        }
        
        public function initialize(reader:ModelReader):void
        {
            _reader = reader;
            _reader.addListener(this, ModelReader.LISTENER_PRIORITY_LIST_ELEMENT_FACTORY);
        }
        
        /**
         * データに紐付くエレメントが存在するかを示す値を返す.
         */
        public function hasElement(bindData:*):Boolean
        {
            return bindData in _createdInstance;
        }
        
        public function preview(plainDiff:Diff):void {}
        public function commit(plainDiff:Diff):void  {}
        
        /**
         * データに紐付くエレメントを取得する.
         * 存在しない場合、暗黙的にプールを介してインスタンスを取得する。
         * プールにも再利用可能なインスタンスがない場合、新規生成する。
         */
        public function request(actualParentWidth:int, actualParentHeight:int, modelData:*, index:int = -1, length:int = -1):IElement
        {
            if (!(modelData in _createdInstance))
            {
                var l:Array = _reader.read();
                if (length == -1) length = l.length;
                
                if (index == -1)
                {
                    var n:int = l.indexOf(modelData);
                    index = n == -1 ? length: n;
                }
                
                var builder:ElementBuilder = _getBuilder(modelData, index, length).storageId(_reader.id + "." + index);
                var element:IElement = _pool.request(builder.getElementClass()) as IElement;
                
                element ?
                    builder.initializeElement(element, index.toString(), actualParentWidth, actualParentHeight):
                    element = builder.build(index.toString(), actualParentWidth, actualParentHeight) as IElement;
                
                _createdInstance[modelData] = element;
            }
            
//            if (index > -1)
//            {
//                _createdInstance[modelData].name = index.toString();
//            }
            
            return _createdInstance[modelData];
        }
        
        /**
         * IElementオブジェクトに紐付けているmodlDataが書き換えられていた場合更新する.
         */
        public function refreshKey():void
        {
            Log.custom(TAG, "requireCacheKeyRefresh");
            var _result:Dictionary = new Dictionary(true);
            
            for (var modelData:* in _createdInstance)
            {
                var e:IElement = _createdInstance[modelData];
                var realData:* = e.elementInfo.reader.read();
                _result[realData] = e;
                
                if (realData !== modelData)
                    Log.custom(TAG, "refresh => keyModel:", modelData, "realModel:", realData);
            }
            
            _createdInstance = _result;
        }
        
        /**
         * プールを介さずにインスタンスを新規生成する.
         */
        public function create(actualParentWidth:int, actualParentHeight:int, modelData:*, index:int = -1, length:int = -1):IElement
        {
            var l:Array = _reader.read();
            if (length == -1) length = l.length;
            
            if (index == -1)
            {
                var n:int = l.indexOf(modelData);
                index = n == -1 ? length: n;
            }
            
            return _getBuilder(modelData, index, length)
                .storageId(_reader.id + "." + index)
                .build(index.toString(), actualParentWidth, actualParentHeight) as IElement;
        }
        
        protected function _getBuilder(modelData:*, index:int, length:int):ElementBuilder
        {
            var builderName:String = getBuilderName(modelData, index, length);
            var bluePrint:IElementBluePrint = Application.configure.elementBluePrint;
            
            return builderName in _builderCache ?
                _builderCache[builderName]:
                _builderCache[builderName] = bluePrint.createBuilder(builderName);
        }
        
        public function getBuilderName(modelData:*, index:int, length:int):String
        {
            return "";
        }
        
        /**
         * データとエレメントの紐付けを破棄し参照を外す.
         */
        public function recycle(modelData:*):void
        {
            if (modelData in _createdInstance)
            {
                var e:IElement = _createdInstance[modelData];
                delete _createdInstance[modelData];
                
                _pool.recycle(e as IRecycle);
            }
        }
    }
}