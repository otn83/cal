package flexUnitTests
{
    import flexunit.framework.Assert;
    
    import jp.coremind.model.StatusModel;
    import jp.coremind.utility.data.Status;
    
    import org.flexunit.assertThat;
    import org.hamcrest.object.equalTo;
    
    public class TestMultistageStatus
    {		
        var stats:StatusModel;
        
        [Before]
        public function setUp():void
        {
            stats = new StatusModel();
        }
        
        [After]
        public function tearDown():void
        {
            stats.destroy();
        }
        
        [BeforeClass]
        public static function setUpBeforeClass():void
        {
        }
        
        [AfterClass]
        public static function tearDownAfterClass():void
        {
        }
        
        [Test]
        public function testEqual():void
        {/*
            //初期追加
            stats.createGroup("test10" ,  10, ["test10decrement"]);
            stats.createGroup("test100", 100, ["test100decrement"]);
            stats.createGroup("test50" ,  50, ["test50decrement"]);
            
            assertThat(stats.equal(Status.IDLING), equalTo(true));
            assertThat(stats.headGroup, equalTo("test10"));
            
            //既存のpriorityよりも高いpriorityグループのステータスを設定したらそのグループがアクティブになる
            stats.update("test100", "init100");
            
            assertThat(stats.equal("init100"), equalTo(true));
            assertThat(stats.headGroup, equalTo("test100"));
            
            //現在アクティブになっているステータスが保持するpriorityよりも低いpriorityグループのステータスを設定してもそのグループはアクティブにならない
            //ただし、ステータスの更新自体は行われている(この場合test10のステータスはinit10になっている)
            //(ignorepriorityがtrue時のみ)
            stats.update("test10", "init10");
            
            assertThat(stats.equal("init100"), equalTo(true));
            assertThat(stats.headGroup, equalTo("test100"));
            
            //createGroupの第三引数に与えたステータスにマッチした値がupdateで設定された場合、
            //一つしたのグループがアクティブになる
            var v:Vector.<String> = stats.update("test100", "test100decrement");
            
            assertThat(stats.headGroup, equalTo("test50"));
            assertThat(stats.equal(Status.IDLING), equalTo(true));
            assertThat(v.length, equalTo(2));
            assertThat(v[0], equalTo("test100"));
            assertThat(v[1], equalTo("test50"));
            
            stats.update("test50", "test50decrement");
            
            assertThat(stats.headGroup, equalTo("test10"));
            //assertThat(stats.equal("init10"), equalTo(true));//Status.IDLINGではなく、67行目で更新したinit10になっていることを確認
            assertThat(stats.equal("idling"), equalTo(true));//Status.IDLINGではなく、67行目で更新したinit10になっていることを確認
            
            //仮に一番下のグループのステータスにdecrementStatusが設定されていてもグループに変化は起きない
            stats.update("test10", "test10decrement");
            
            assertThat(stats.headGroup, equalTo("test10"));
            assertThat(stats.equal("test10decrement"), equalTo(true));//※ステータスはinit10からtest10decrementに変わっている
            
            stats.update("test50", "move50");
            assertThat(stats.headGroup, equalTo("test50"));
            assertThat(stats.equal("move50"), equalTo(true));
            
            stats.createGroup("test200", 200, []);*/
        }
    }
}