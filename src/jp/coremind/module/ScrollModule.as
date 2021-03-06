package jp.coremind.module
{
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import jp.coremind.core.Application;
    import jp.coremind.utility.Dispatcher;
    import jp.coremind.utility.data.NumberTracker;
    import jp.coremind.view.abstract.IContainer;
    import jp.coremind.view.interaction.Drag;
    import jp.coremind.view.interaction.Flick;
    
    public class ScrollModule extends Dispatcher implements IModule
    {
        //再利用インスタンス
        private static const _ZERO:Point = new Point();
        private static const _POINT:Point = new Point();
        private static const _OFFSET:Rectangle = new Rectangle();
        
        private var
            _scrollVolume:Point,
            _container:IContainer,
            _dragControl:Drag,
            _before:Before,
            _dragSize:Point,
            _dragArea:Rectangle;
        
        public function ScrollModule(container:IContainer)
        {
            _container    = container;
            _before       = new Before();
            _dragArea     = new Rectangle();
            _dragSize     = new Point();
            _dragControl  = new Flick();
            _scrollVolume = new Point(1, 1);
        }
        
        override public function destroy():void
        {
            _dragControl.destory();
            _dragControl = null;
            _container = null;
            _before = null;
            _dragSize = null;
            _dragArea = null;
            _scrollVolume = null;
            
            super.destroy();
        }
        
        /**
         * 一度の呼び出しで何pixelスクロールするかを示す値を設定する.
         * ※gridDensityと動議
         */
        public function setScrollVolume(x:Number, y:Number):void
        {
            _scrollVolume.setTo(x, y);
        }
        
        public function toHead(x:Boolean = true, y:Boolean = true):void
        {
            _moveTo(x ? int.MAX_VALUE: 0, y ? int.MAX_VALUE: 0);
        }
        
        public function toTail(x:Boolean = true, y:Boolean = true):void
        {
            _moveTo(x ? -int.MAX_VALUE: 0, y ? -int.MAX_VALUE: 0);
        }
        
        public function pixelTo(x:Number, y:Number):void
        {
            _moveTo(x, y);
        }
        
        public function gridTo(x:int, y:int):void
        {
            _moveTo(x * _scrollVolume.x, y * _scrollVolume.y);
        }
        
        private function _moveTo(x:Number, y:Number):void
        {
            _initialize();
            
            _dragControl.moveTo(x, y);
            _dragControl.drop();
        }
        
        public function update(...params):void {}
        
        public function ignorePointerDevice(boolean:Boolean):void
        {
            _dragControl.ignorePointerDevice(boolean);
        }
        
        public function refreshContentSize():void
        {
            var resultX:Number = _container.x;
            var resultY:Number = _container.y;
            var delta:Number = 0;
            
            var w:Number = _container.x + _container.elementWidth;
            if (w < _container.maxWidth)
            {
                delta = _container.maxWidth - w;
                _dragSize.x += delta;
                resultX     += delta;
                
                if (0 < resultX)     resultX = 0;
                if (0 < _dragSize.x) _dragSize.x  = 0;
            }
            
            var h:Number  = _container.y + _container.elementHeight;
            if (h <= _container.maxHeight)
            {
                delta = _container.maxHeight - h;
                _dragSize.y += delta;
                resultY     += delta;
                
                if (0 < resultY)     resultY = 0;
                if (0 < _dragSize.y) _dragSize.y  = 0;
            }
            
            if (_container.x != resultX || _container.y != resultY)
                _container.updatePosition(resultX, resultY);
        }
        
        public function createTracker(callback:Function):void
        {
            _initializePosition();
            _initializeDragArea();
            _dragControl.createTracker(_OFFSET, _dragArea, callback);
        }
        
        public function beginPointerDeviceListening():void
        {
            _initialize();
            _dragControl.beginPointerDeviceListening();
        }
        
        protected function _initialize():void
        {
            _initializePosition();
            _initializeDragArea();
            _setInitialPosition();
            
            _dragControl.initialize(_OFFSET, _dragArea, _onUpdate);
        }
        
        private function _initializePosition():void
        {
            _container.toLocalPoint(Application.pointer, _POINT);
            _OFFSET.setTo(_POINT.x, _POINT.y, _container.maxWidth, _container.maxHeight);
        }
        
        private function _initializeDragArea():void
        {
            _container.toGlobalPoint(_ZERO, _POINT);
            
            _dragArea.setTo(
                _POINT.x - (_container.elementWidth  - _container.maxWidth  + _dragSize.x),
                _POINT.y - (_container.elementHeight - _container.maxHeight + _dragSize.y),
                _container.elementWidth,
                _container.elementHeight);
            
            _dragArea.x |= 0;
            _dragArea.y |= 0;
        }
        
        private function _setInitialPosition():void
        {
            _before.containerPosition.setTo(_container.x, _container.y);
            _before.flickAreaPosition.setTo(_dragArea.x, _dragArea.y);
            _before.dragSize.setTo(_dragSize.x, _dragSize.y);
        }
        
        private function _onUpdate(x:NumberTracker, y:NumberTracker):void
        {
            var resultX:Number = _container.x;
            var trackerX:NumberTracker = null;
            if (_container.maxWidth < _container.elementWidth)
            {
                resultX      = _before.containerPosition.x + x.latestTotalDelta;
                _dragSize.x  = _before.dragSize.x          + x.latestTotalDelta;
                _dragArea.x  = _before.flickAreaPosition.x - x.latestTotalDelta;
                trackerX = x;
            }
            
            var resultY:Number = _container.y;
            var trackerY:NumberTracker = null;
            if (_container.maxHeight < _container.elementHeight)
            {
                resultY      = _before.containerPosition.y + y.latestTotalDelta;
                _dragSize.y  = _before.dragSize.y          + y.latestTotalDelta;
                _dragArea.y  = _before.flickAreaPosition.y - y.latestTotalDelta;
                trackerY = y;
            }
            
            _container.updatePosition(resultX, resultY);
            dispatch(trackerX, trackerY);
        }
    }
}
import flash.geom.Point;

class Before
{
    public var
    flickAreaPosition:Point,
    containerPosition:Point,
    dragSize:Point;
    
    public function Before()
    {
        flickAreaPosition = new Point();
        containerPosition = new Point();
        dragSize = new Point();
    }
}