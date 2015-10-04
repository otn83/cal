package jp.coremind.view.builder
{
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IBox;
    import jp.coremind.view.implement.starling.buildin.Sprite;
    import jp.coremind.view.layout.Layout;
    
    public class BitmapTextFieldBuilder extends DisplayObjectBuilder implements IDisplayObjectBuilder
    {
        public function BitmapTextFieldBuilder(layout:Layout = null)
        {
            super(layout);
        }
        
        public function build(name:String, actualParentWidth:int, actualParentHeight:int):IBox
        {
            var sprite:Sprite = new Sprite();
            
            sprite.name = name;
            Log.info("builded BitmapTextField");
            
            return sprite;
        }
    }
}