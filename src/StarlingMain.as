/**
 * User: Ray Yee
 * Date: 14-2-11
 * All rights reserved.
 */
package
{
    import flash.display.Sprite;
    import flash.system.Capabilities;

    import starling.core.Starling;

    [SWF(backgroundColor="#000000", frameRate=60, width=760, height=650)]
    public class StarlingMain extends Sprite
    {
        public function StarlingMain()
        {
            var starling:Starling = new Starling( StarlingCamera, stage, null, null, "auto", "baseline" );
            starling.showStats = true;
            starling.showStatsAt( "left", "bottom" );
            starling.simulateMultitouch = false;
            starling.enableErrorChecking = Capabilities.isDebugger;
            starling.start();
        }
    }
}
