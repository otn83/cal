package jp.coremind.core
{
    import jp.coremind.event.ElementInfo;
    import jp.coremind.model.module.StatusGroup;
    import jp.coremind.utility.Log;
    import jp.coremind.utility.data.Status;

    public class Router
    {
        public static const TAG:String = "Router";
        Log.addCustomTag(TAG);
        
        public static var _LISTENER_LIST:Object;
        
        public function Router()
        {
            _LISTENER_LIST = {};
        }
        
        public function listen(controllerClass:Class, method:String, path:Array, statusGroup:String, statusValue:String, staticParams:Array = null):void
        {
            Controller.bindView(path[1], controllerClass);
            
            var key:String = ElementPathParser.createRouterKey(path, statusGroup, statusValue);
            if (key in _LISTENER_LIST)
                Log.warning("already defined Executor.", arguments);
            else
            {
                _LISTENER_LIST[key] = new Executor(controllerClass, method, staticParams);
                Log.custom(TAG, "success defined Executor.", key, "=>", controllerClass, "::", method);
            }
        }
        
        public function listenDrug(controllerClass:Class, drugTargetList:Array, dropAreaList:Array, absorb:Boolean):void
        {
            if ($.isImplements(controllerClass, IDragDropControl))
            {
                var confId:int = DragDropController.addConfigure(controllerClass, absorb, dropAreaList);
                var params:Array = [confId];
                
                for (var i:int = 0; i < drugTargetList.length; i++) 
                {
                    Controller.bindView(drugTargetList[i][1], controllerClass);
                    listen(DragDropController, "beginDrug", drugTargetList[i], StatusGroup.PRESS, Status.DOWN, params);
                }
            }
            else Log.warning("failed listenDrug. ", controllerClass, " require implements IDrugDropControl interface.");
        }
        
        public function notify(info:ElementInfo, statusGroup:String, statusValue:String):void
        {
            var executor:Executor;
            
            executor = getExecutor(info.path.createRouterKey(statusGroup, statusValue));
            if (executor) executor.exec(info);
            else
            {
                executor = searchBuzzElementIdExecutor(info, statusGroup, statusValue);
                if (executor) executor.exec(info);
                //else Log.info("undefined Executor.", elementInfo);
            }
        }
        
        public function searchBuzzElementIdExecutor(info:ElementInfo, statusGroup:String, statusValue:String):Executor
        {
            var elementPath:Array  = info.path.elementId.split(".");
            var elementName:String = elementPath[elementPath.length-1];
            
            if (elementName.match(/^[0-9]+$/))
            {
                elementPath.splice(-1, 1, "{n}");
                
                return getExecutor(info.path.createRouterKey(statusGroup, statusValue)
                          .replace(info.path.elementId, elementPath.join(".")));
            }
            else
                return null;
        }
        
        public function getExecutor(uniqueId:String):Executor
        {
            return uniqueId in _LISTENER_LIST ? _LISTENER_LIST[uniqueId]: null;
        }
    }
}
import jp.coremind.core.Controller;

class Executor
{
    private var
        _controllerClass:Class,
        _method:String,
        _staticParams:Array;
        
    public function Executor(controllerClass:Class, method:String, staticParams:Array = null)
    {
        _controllerClass = controllerClass;
        _method          = method;
        _staticParams    = staticParams;
    }
    
    public function exec(...extendParams):void
    {
        var p:Array = _staticParams ?
            extendParams.length > 0 ? extendParams.concat(_staticParams): _staticParams:
            extendParams;
        
        Controller.exec(_controllerClass, _method, p);
    }
}