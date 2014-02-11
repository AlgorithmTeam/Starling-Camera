package
{
    import camera.Camera;
    import camera.controls.CameraClickControls;
    import camera.controls.CameraFollowControls;
    import camera.controls.CameraKeyControls;
    import camera.controls.CameraMouseControls;
    import camera.controls.CameraMouseEdgeControls;
    import camera.enums.CameraFollowEaseType;
    import camera.enums.CameraFollowOffsetType;

    import flash.display.Sprite;
    import flash.events.Event;

    import input.Input;

    import map.MapLayer;
    import map.Ship;
    import map.ShipMarker;

    import update.Update;

    /**
     * The main class, entry point to the game
     * This Main class demonstrates all the different controllers at once. Set the other Main
     * classes as the document class to see them all individually
     * @author Damian Connolly
     */
    [SWF(backgroundColor="#000000", frameRate=60, width=760, height=650)]
    public class Main extends Sprite
    {

        /*******************************************************************************************/

        private var m_update:Update = null;	// the controller to update our objects
        private var m_input:Input = null;	// tracks keys state
        private var m_camera:Camera = null; // the camera that we're going to be move
        private var m_cameraMouseControls:CameraMouseControls = null;	// allows us to control the camera by dragging the mouse
        private var m_cameraKeyControls:CameraKeyControls = null;	// allows us to control the camera by using the keys
        private var m_cameraMouseEdgeControls:CameraMouseEdgeControls = null;	// allows us to control the camera by using the screen edges
        private var m_cameraFollowControls:CameraFollowControls = null;	// allows us to control the camera by selecting an object to follow
        private var m_cameraClickControls:CameraClickControls = null; // allows us to select objects etc
        private var m_currShip:Ship = null;	// the current ship that we're controlling
        private var m_currShipMarker:ShipMarker = null; // the marker for the curretn ship that we're controlling

        /*******************************************************************************************/

        /**
         * Called automatically on startup
         */
        public function Main():void
        {
            if ( this.stage ) this._init();
            else this.addEventListener( Event.ADDED_TO_STAGE, this._init );
        }

        /*******************************************************************************************/

            // init the game - called when we have a stage
        private function _init( e:Event = null ):void
        {
            this.removeEventListener( Event.ADDED_TO_STAGE, this._init );

            // create our basic objects
            this.m_update = new Update( this.stage );
            this.m_input = new Input( this.stage );
            this.m_camera = new Camera( this.stage.stageWidth, this.stage.stageHeight );
            this.m_camera.minZoom = this.stage.stageWidth / 2000; // limit the min zoom so we only go to the borders
            this.m_camera.setBounds( -1000.0, -1000.0, 2000, 2000 );
            this.m_update.add( this.m_camera );

            // create our ship marker (it'll add itself to the stage when we get a ship)
            this.m_currShipMarker = new ShipMarker;
            this.m_update.add( this.m_currShipMarker );

            // create our controllers

            // key controls
            this.m_cameraKeyControls = new CameraKeyControls( this.m_camera, this.stage, this.m_input );
            this.m_cameraKeyControls.shouldMoveWithVelocity = true;
            this.m_cameraKeyControls.shouldZoomWithVelocity = false;
            this.m_cameraKeyControls.signalOnStartedMoving.add( this._onControllerStart );
            this.m_update.add( this.m_cameraKeyControls );

            // mouse controls
            this.m_cameraMouseControls = new CameraMouseControls( this.m_camera, this.stage, this.m_input );
            this.m_cameraMouseControls.shouldMoveWithVelocity = true;
            this.m_cameraMouseControls.shouldZoomWithVelocity = true;
            this.m_cameraMouseControls.signalOnStartedMoving.add( this._onControllerStart );
            this.m_update.add( this.m_cameraMouseControls );

            // mouse edge controls
            this.m_cameraMouseEdgeControls = new CameraMouseEdgeControls( this.m_camera, this.stage, this.m_input );
            this.m_cameraMouseEdgeControls.shouldMoveWithVelocity = false;
            this.m_cameraMouseEdgeControls.border = 5;
            this.m_cameraMouseEdgeControls.signalOnStartedMoving.add( this._onControllerStart );
            this.m_update.add( this.m_cameraMouseEdgeControls );

            // follow controls
            this.m_cameraFollowControls = new CameraFollowControls( this.m_camera, this.stage );
            this.m_cameraFollowControls.followEaseType = CameraFollowEaseType.DAMP;
            this.m_cameraFollowControls.followFactor = 1.0;
            this.m_cameraFollowControls.setOffsetPoint( 50, 0.0, CameraFollowOffsetType.OBJ_POS_DELTA );
            this.m_update.add( this.m_cameraFollowControls );

            // click controls
            this.m_cameraClickControls = new CameraClickControls( this.m_camera, this.stage );
            this.m_update.add( this.m_cameraClickControls );

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
            this.addChild( shipLayer );
            this.addChild( star2Layer );

            // add some ships to select
            var sw:Number = 1900;
            var sh:Number = 1900;
            for ( var i:int = 0; i < 10; i++ )
            {
                var ship:Ship = new Ship;
                ship.x = -sw * 0.5 + Math.random() * sw;
                ship.y = -sh * 0.5 + Math.random() * sh;
                ship.rotation = Math.random() * 360.0;
                this.m_update.add( ship );
                shipLayer.addChild( ship );
            }

            // add our ship layer has the ships, add our signals to know if we click on an
            // object, or on the map
            shipLayer.signalOnSelectPos.add( this._onSelectDestination );
            shipLayer.signalOnSelectShip.add( this._onClickShip );

            // add the layers so they're controlled by the camera
            this.m_camera.addLayerToControl( planetLayer, 0.25 );
            this.m_camera.addLayerToControl( stars1Layer, 0.5 );
            this.m_camera.addLayerToControl( shipLayer, 1.0 );
            this.m_camera.addLayerToControl( star2Layer, 2.0 );
        }

        // called when one of the mouse, mouse edge, or key controllers starts moving - we
        // need to disable the follow controller otherwise there'll be a conflict for the camera.
        // you can optionally disable the other controllers if necessary, but I don't find there
        // do be much of a problem between them
        private function _onControllerStart():void
        {
            this.m_cameraFollowControls.followObj = null;
        }

        // called when we click on a point in the map
        private function _onSelectDestination( x:Number, y:Number ):void
        {
            if ( this.m_currShip != null )
                this.m_currShip.moveTo( x, y );
        }

        // called when we click on a ship
        private function _onClickShip( ship:Ship ):void
        {
            // if it's the same as our current ship, deselect it
            if ( this.m_currShip == ship )
            {
                this.m_currShipMarker.ship = null;
                this.m_currShip = null;
                this.m_cameraFollowControls.followObj = null;
            }
            else
            {
                this.m_currShipMarker.ship = ship;
                this.m_currShip = ship;
                this.m_cameraFollowControls.followObj = ship;
            }
        }

    }

}