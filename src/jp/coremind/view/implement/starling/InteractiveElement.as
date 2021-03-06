package jp.coremind.view.implement.starling
{
    import jp.coremind.core.Application;
    import jp.coremind.core.StatusModelType;
    import jp.coremind.module.StatusGroup;
    import jp.coremind.module.StatusModule;
    import jp.coremind.utility.data.Status;
    import jp.coremind.view.builder.parts.IBackgroundBuilder;
    import jp.coremind.view.layout.Layout;
    
    import starling.events.Touch;
    import starling.events.TouchEvent;
    
    public class InteractiveElement extends StatefulElement
    {
        protected var
            _button:Boolean,
            _touchHandling:Boolean,
            _touch:Touch;
        
        public function InteractiveElement(layoutCalculator:Layout, backgroundBuilder:IBackgroundBuilder = null)
        {
            super(layoutCalculator, backgroundBuilder);
            
            button = false;
            touchHandling = false;
        }
        
        override public function destroy(withReference:Boolean = false):void
        {
            disablePointerDeviceControl();
            
            super.destroy(withReference);
        }
        
        override protected function get statusModelType():String
        {
            return StatusModelType.INTERACTIVE_ELEMENT;
        }
        
        public function get button():Boolean { return _button; }
        public function set button(v:Boolean):void
        {
            _button = v;
            if (v && touchable) useHandCursor = true;
        }
        
        public function get touchHandling():Boolean { return _touchHandling; }
        public function set touchHandling(v:Boolean):void
        {
            _touchHandling = v;
            if (v && touchable) addEventListener(TouchEvent.TOUCH, _onTouch);
        }
        
        override public function enablePointerDeviceControl():void
        {
            touchable = true;
            if (_button) useHandCursor = true;
            if (_touchHandling) addEventListener(TouchEvent.TOUCH, _onTouch);
        }
        
        override public function disablePointerDeviceControl():void
        {
            useHandCursor = touchable = false;
            removeEventListener(TouchEvent.TOUCH, _onTouch);
        }
        
        override protected function _initializeStatus():void
        {
            super._initializeStatus();
            
            _info.modules.getModule(StatusModule).update(StatusGroup.LOCK, null);
        }
        
        override public function ready():void
        {
            super.ready();
            enablePointerDeviceControl();
        }
        
        /**
         * starlingから発生するタッチイベントのハンドリングを行う.
         */
        protected function _onTouch(e:TouchEvent):void
        {
            //押したまま移動させている最中にこのオブジェクトが破棄(破棄時にlistenerをremove)しても
            //押すのをやめるまでタッチイベントは送出され続けるようなのでstageが取れるかチェックをしてからタッチ処理を実行させる.
            if (stage)
            {
                _touch = e.getTouch(this);
                
                if (_touch)
                {
                    this[_touch.phase]();
                    _touch = null;
                }
            }
        }
        
        /** TouchPhase.HOVERハンドリング */
        protected function hover():void {}
        
        /** TouchPhase.BEGANハンドリング */
        protected function began():void　{}
        
        /** TouchPhase.MOVEDハンドリング */
        protected function moved():void　{}
        
        /** TouchPhase.STATIONARYハンドリング */
        protected function stationary():void {}
        
        /** TouchPhase.ENDEDハンドリング */
        protected function ended():void　{}
        
        override protected function _applyStatus(group:String, status:String):Boolean
        {
            switch (group)
            {
                case StatusGroup.LOCK:
                    switch(status)
                    {
                        case Status.UNLOCK:
                            _onEnable();
                            Application.router.notify(_info, group, status);
                            return true;
                            
                        case Status.LOCK:
                            _onDisable();
                            Application.router.notify(_info, group, status);
                            return true;
                    }
                    break;
            }
            
            return super._applyStatus(group, status);
        }
        
        /**
         * statusオブジェクトが以下の状態に変わったときに呼び出されるメソッド.
         * group : GROUP_LOCK
         * value : Status.UNLOCK
         */
        protected function _onEnable():void
        {
            //Log.info("_onEnable");
        }
        
        /**
         * statusオブジェクトが以下の状態に変わったときに呼び出されるメソッド.
         * group : GROUP_LOCK
         * value : Status.LOCK
         */
        protected function _onDisable():void
        {
            //Log.info("_onDisable");
        }
    }
}