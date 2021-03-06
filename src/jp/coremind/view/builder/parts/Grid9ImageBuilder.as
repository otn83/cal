package jp.coremind.view.builder.parts
{
    import jp.coremind.asset.Grid9ImageAsset;
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IBox;
    import jp.coremind.view.abstract.component.Grid9;
    import jp.coremind.view.layout.Layout;
    
    import starling.textures.Texture;
    import jp.coremind.view.builder.DisplayObjectBuilder;
    
    public class Grid9ImageBuilder extends DisplayObjectBuilder
    {
        private var
            _tl:Texture, _t :Texture, _tr:Texture,
            _l :Texture, _c :Texture, _r :Texture,
            _bl:Texture, _b :Texture, _br:Texture;
        
        public function Grid9ImageBuilder(
            topLeft:Texture,    top:Texture,    topRight:Texture,
            left:Texture,       body:Texture,   right:Texture,
            bottomLeft:Texture, bottom:Texture, bottomRight:Texture,
            layout:Layout = null)
        {
            super(layout);
            
            _tl = topLeft;
            _t  = top;
            _tr = topRight;
            _l  = left;
            _c  = body;
            _r  = right;
            _bl = bottomLeft;
            _b  = bottom;
            _br = bottomRight;
        }
        
        override public function build(name:String, actualParentWidth:int, actualParentHeight:int):IBox
        {
            var asset:Grid9ImageAsset = new Grid9ImageAsset().initializeForTexture(
                _tl, _t, _tr,
                 _l, _c, _r,
                _bl, _b, _br);
            
            asset.name = name;
            
            var grid9:Grid9 = new Grid9().setAsset(asset);
            grid9.width  = _layout.width.calc(actualParentWidth);
            grid9.height = _layout.height.calc(actualParentHeight);
            
            Log.info("builded Grid9Image", asset.width, asset.height);
            
            return grid9;
        }
    }
}