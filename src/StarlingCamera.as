/**
 * User: Ray Yee
 * Date: 14-2-11
 * All rights reserved.
 */
package
{
    import camera.Camera;
    import camera.controls.CameraMouseControls;

    import input.Input;

    import map.MapLayer;
    import map.Ship;

    import starling.animation.Juggler;

    import starling.core.Starling;

    import starling.display.Sprite;
    import starling.events.Event;

    import update.Update;

    public class StarlingCamera extends Sprite
    {
        private var m_update:Update = null;
        private var m_input:Input = null;
        private var m_camera:Camera = null;

        private var m_cameraMouseControls:CameraMouseControls = null;

        public function StarlingCamera()
        {
            super();
            addEventListener( Event.ADDED_TO_STAGE, init );
        }

        private function init( e:Event ):void
        {
            removeEventListener( Event.ADDED_TO_STAGE, init );

            m_update = new Update( this.stage );
            m_input = new Input( this.stage );
            m_camera = new Camera( this.stage.stageWidth, this.stage.stageHeight );
            m_camera.minZoom = this.stage.stageWidth / 2000; // limit the min zoom so we only go to the borders
            m_camera.setBounds( -1000.0, -1000.0, 2000, 2000 );
            m_update.add( this.m_camera );


            // mouse controls
            this.m_cameraMouseControls = new CameraMouseControls( this.m_camera, Starling.current.nativeStage, this.m_input );
            this.m_cameraMouseControls.shouldMoveWithVelocity = true;
            this.m_cameraMouseControls.shouldZoomWithVelocity = true;
            this.m_cameraMouseControls.signalOnStartedMoving.add( _onControllerStart );
            this.m_update.add( this.m_cameraMouseControls );

            // create our different layers
            var planetLayer:MapLayer = new MapLayer( true, true );
            var stars1Layer:MapLayer = new MapLayer( false, true );
            var shipLayer:MapLayer = new MapLayer( false, true, 10, 10 );
            var star2Layer:MapLayer = new MapLayer( false, true );
            planetLayer.alpha = 0.5;	// alpha for fake distance effect
            //planetLayer.isZoomEnabled	= false;// don't scale
            stars1Layer.alpha = 0.75;	// alpha for fake distance effect
            this.addChild( planetLayer );
            this.addChild( stars1Layer );
            this.addChild( star2Layer );

            // add the layers so they're controlled by the camera
            this.m_camera.addLayerToControl( planetLayer, 0.25 );
            this.m_camera.addLayerToControl( stars1Layer, 0.5 );
            this.m_camera.addLayerToControl( shipLayer, 1.0 );
            this.m_camera.addLayerToControl( star2Layer, 2.0 );
        }

        private function _onControllerStart():void
        {
//            this.m_cameraFollowControls.followObj = null;
        }
    }
}