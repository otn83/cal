package jp.coremind.storage
{
    public class SqLiteStorage implements IModelStorage
    {
        public function SqLiteStorage()
        {
        }
        
        public function isDefined(id:String):Boolean
        {
            return false;
        }
        
        public function create(id:String, value:*):void
        {
        }
        
        public function read(id:String):*
        {
            return null;
        }
        
        public function update(id:String, value:*):void
        {
        }
        
        public function de1ete(id:String):void
        {
        }
        
        public function reset():void
        {
        }
    }
}