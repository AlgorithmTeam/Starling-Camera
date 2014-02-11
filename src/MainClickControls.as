package  
{
	import camera.Camera;
	import camera.controls.CameraClickControls;
	import flash.display.Sprite;
	import flash.events.Event;
	import map.MapLayer;
	import map.Ship;
	import map.ShipMarker;
	import update.Update;
	
	/**
	 * The main class, entry point to the game
	 * MainClickControls is about clicking in layers, so there's no camera movement
	 * @author Damian Connolly
	 */
	public class MainClickControls extends Sprite
	{
		
		/*******************************************************************************************/
		
		private var m_update:Update 					= null;	// the controller to update our objects
		private var m_camera:Camera						= null; // the camera that we're going to be move
		private var m_clickControls:CameraClickControls	= null;	// the click controls
		private var m_currShip:Ship						= null; // the current ship that we're controlling
		private var m_currShipMarker:ShipMarker			= null; // the marker for the current ship
		
		/*******************************************************************************************/
		
		/**
		 * Called automatically on startup
		 */
		public function MainClickControls():void 
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
			
			// create our current ship marker (it will add itself to the proper layer when
			// it gets assigned a ship)
			this.m_currShipMarker = new ShipMarker;
			this.m_update.add( this.m_currShipMarker );
			
			// create our different layers
			var planetLayer:MapLayer 	= new MapLayer( true, true );
			var stars1Layer:MapLayer 	= new MapLayer( false, true );
			var shipLayer:MapLayer		= new MapLayer( false, true );
			var star2Layer:MapLayer 	= new MapLayer( false, true );
			planetLayer.alpha 			= 0.5;	// alpha for fake distance effect
			//planetLayer.isZoomEnabled	= false;// don't scale
			stars1Layer.alpha 			= 0.75;	// alpha for fake distance effect
			this.addChild( planetLayer );
			this.addChild( stars1Layer );
			this.addChild( shipLayer );
			this.addChild( star2Layer );
			
			// add some ships to the ship layer
			var sw:Number = this.stage.stageWidth - 100;
			var sh:Number = this.stage.stageHeight - 100;
			for ( var i:int = 0; i < 2; i++ )
			{
				var ship:Ship 	= new Ship;
				ship.x			= -sw * 0.5 + Math.random() * sw;
				ship.y			= -sh * 0.5 + Math.random() * sh;
				this.m_update.add( ship );
				shipLayer.addChild( ship );
			}
			
			// add our ship layer signals
			shipLayer.signalOnSelectPos.add( this._onSelectDestination );
			shipLayer.signalOnSelectShip.add( this._onClickShip );
			
			// add the layers so they're controlled by the camera
			this.m_camera.addLayerToControl( planetLayer, 0.25 );
			this.m_camera.addLayerToControl( stars1Layer, 0.5 );
			this.m_camera.addLayerToControl( shipLayer, 1.0 );
			this.m_camera.addLayerToControl( star2Layer, 2.0 );
			
			// create our click controls
			this.m_clickControls = new CameraClickControls( this.m_camera, this.stage );
			this.m_update.add( this.m_clickControls );
		}
		
		// called when we click on a ship
		private function _onClickShip( ship:Ship ):void
		{
			// if it's the same as our current ship, deselect it
			if ( this.m_currShip == ship )
			{
				this.m_currShipMarker.ship 	= null;
				this.m_currShip				= null;
			}
			else
			{
				this.m_currShipMarker.ship	= ship;
				this.m_currShip				= ship;
			}
		}
		
		// called when we click on a point in the map
		private function _onSelectDestination( x:Number, y:Number ):void
		{
			if ( this.m_currShip != null )
				this.m_currShip.moveTo( x, y );
		}
		
	}

}