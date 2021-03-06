package jp.coremind.core
{
    import jp.coremind.view.abstract.ICalSprite;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.abstract.IView;

    public class ElementPathParser
    {
        private static const TMP:ElementPathParser = new ElementPathParser();
        public static function createRouterKey(pathList:Array, statusGroup:String, statusValue:String):String
        {
            TMP._layerId   = pathList.shift();
            TMP._viewId    = pathList.shift();
            TMP._elementId = pathList.join(".");
            return TMP.createRouterKey(statusGroup, statusValue);
        }
        
        private var
            _layerId:String,
            _viewId:String,
            _elementId:String;
        
        public function get layerId():String   { return _layerId; }
        public function get viewId():String    { return _viewId; }
        public function get elementId():String { return _elementId; }
        
        public function isUndefinedPath():Boolean
        {
            return _layerId === null && _viewId === null && _elementId === null;
        }
        
        public function initialize(layerId:String, viewId:String, elementId:String):ElementPathParser
        {
            _layerId   = layerId;
            _viewId    = viewId;
            _elementId = elementId;
            return this;
        }
        
        public function parse(e:IElement):void
        {
            _elementId = e.name;
            _layerId   = "unknown";
            _viewId    = "unknown";
            
            var p:ICalSprite = e.parentDisplay as ICalSprite;
            while (p)
            {
                if (p is IView)
                {
                    _viewId  = p.name;
                    _layerId = p.parentDisplay ? p.parentDisplay.name: null;
                    break;
                }
                else
                {
                    _elementId = p.name + "." + _elementId;
                    p = p.parentDisplay as ICalSprite;
                }
            }
        }
        
        public function fetchElement(accessor:IStageAccessor):IElement
        {
            return accessor
                .getLayerProcessor(_layerId)
                .getView(_viewId)
                .getElement(_elementId, true);
        }
        
        public function fetchView(accessor:IStageAccessor):IView
        {
            return accessor
                .getLayerProcessor(_layerId)
                .getView(_viewId);
        }
        
        public function createRouterKey(statusGroup:String, statusValue:String):String
        {
            return [_layerId, _viewId, _elementId, statusGroup, statusValue].join("/");
        }
        
        public function equal(pathParser:ElementPathParser):Boolean
        {
            return pathParser
                &&   _layerId == pathParser._layerId
                &&    _viewId == pathParser._viewId
                && _elementId == pathParser._elementId;
        }
        
        public function equalString(layerId:String, viewId:String, elementId:String):Boolean
        {
            return   _layerId == layerId
                &&    _viewId == viewId
                && _elementId == elementId;
        }
        
        public function toString():String
        {
            return _layerId+"/"+_viewId+"/"+_elementId;
        }
    }
}