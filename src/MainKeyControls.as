package 
{
	import camera.Camera;
	import camera.controls.CameraKeyControls;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import input.Input;
	import map.MapLayer;
	import update.Update;
	
	/**
	 * The main class, entry point to the game
	 * MainKeyControls is for the camera example, with no controls - just random movement
	 * @author Damian Connolly
	 */
	public class MainKeyControls extends Sprite
	{
		
		/*******************************************************************************************/
		
		private var m_update:Update 	= null;	// the controller to update our objects
		private var m_camera:Camera		= null; // the camera that we're going to be move
		private var m_currTime:Number	= 0.0;	// the current time (before our next move)
		
		/*******************************************************************************************/
		
		/**
		 * Called automatically on startup
		 */
		public function MainKeyControls():void 
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
			this.m_update			= new Update( this.stage );
			this.m_camera			= new Camera( this.stage.stageWidth, this.stage.stageHeight );
			this.m_camera.minZoom	= this.stage.stageWidth / 2000; // limit the min zoom so we only go to the borders
			this.m_camera.setBounds( -1000.0, -1000.0, 2000, 2000 );
			this.m_update.add( this.m_camera );
			
			// create our different layers
			var planetLayer:MapLayer 	= new MapLayer( true, true );
			var stars1Layer:MapLayer 	= new MapLayer( false, true );
			var star2Layer:MapLayer 	= new MapLayer( false, true );
			planetLayer.alpha 			= 0.5;	// alpha for fake distance effect
			//planetLayer.isZoomEnabled	= false;// don't scale
			stars1Layer.alpha 			= 0.75;	// alpha for fake distance effect
			this.addChild( planetLayer );
			this.addChild( stars1Layer );
			this.addChild( star2Layer );
			
			// add the layers so they're controlled by the camera
			this.m_camera.addLayerToControl( planetLayer, 0.25 );
			this.m_camera.addLayerToControl( stars1Layer, 0.5 );
			this.m_camera.addLayerToControl( star2Layer, 1.0 );
			
			// create our key controls
			var input:Input						= new Input( this.stage );
			var keyControls:CameraKeyControls 	= new CameraKeyControls( this.m_camera, this.stage, input );
			keyControls.shouldMoveWithVelocity	= true;
			keyControls.shouldZoomWithVelocity	= true;
			keyControls.zoomSpeed				= 1;
			this.m_update.add( keyControls );
			
			// add our reset click listener
			this.stage.addEventListener( MouseEvent.CLICK, this._onReset );
		}
		
		// resets the camera to the center
		private function _onReset( e:MouseEvent ):void
		{
			this.m_camera.zoom = 1.0;
			this.m_camera.moveCameraTo( 0.0, 0.0 );
			this.m_currTime = 0.0;
		}
		
	}
	
}