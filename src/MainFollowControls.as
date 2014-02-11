package 
{
	import camera.Camera;
	import camera.controls.CameraFollowControls;
	import camera.enums.CameraFollowEaseType;
	import camera.enums.CameraFollowOffsetType;
	import com.bit101.components.HUISlider;
	import com.bit101.components.PushButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import input.Input;
	import map.MapLayer;
	import map.Ship;
	import math.MathHelper;
	import update.IUpdateObj;
	import update.Update;
	
	/**
	 * The main class, entry point to the game
	 * MainFollowControls is for the camera example, with controlling the camera by following an object
	 * with the mouse
	 * @author Damian Connolly
	 */
	public class MainFollowControls extends Sprite implements IUpdateObj
	{
		
		/*******************************************************************************************/
		
		private var m_update:Update 						= null;	// the controller to update our objects
		private var m_camera:Camera							= null; // the camera that we're going to be move
		private var m_input:Input							= null; // helps us control keyboard input
		private var m_followControls:CameraFollowControls	= null; // the control to follow our object
		private var m_ship:Ship								= null;	// the ship that we're moving
		
		// variables used for the control gui
		private var m_mouseDir:Point						= new Point; // point so we can get a vector from the ship to the mouse
		private var m_easeTypes:Array 						= [CameraFollowEaseType.NONE, CameraFollowEaseType.LERP, CameraFollowEaseType.DAMP];
		private var m_offsetTypes:Array 					= [CameraFollowOffsetType.NONE, CameraFollowOffsetType.OBJ_ROTATION, CameraFollowOffsetType.OBJ_POS_DELTA];
		private var m_currEaseType:CameraFollowEaseType 	= null;
		private var m_currOffsetType:CameraFollowOffsetType	= null;
		private var m_btnEase:PushButton					= null; // the button to change the ease type
		private var m_btnOffset:PushButton					= null;	// the button to change the offset type
		private var m_scrFollowFactor:HUISlider				= null; // the slider to change the ease factor
		private var m_scrXOffset:HUISlider					= null; // the slider to change the x offset
		
		/*******************************************************************************************/
		
		/**
		 * True if we're active (always true, to control the ship)
		 */
		public function get active():Boolean { return true; }
		
		/*******************************************************************************************/
		
		/**
		 * Called automatically on startup
		 */
		public function MainFollowControls():void 
		{
			if ( this.stage ) this._init();
			else this.addEventListener( Event.ADDED_TO_STAGE, this._init );
		}
		
		/**
		 * Called every frame we're active
		 * @param dt The delta time since the last update
		 */
		public function update( dt:Number ):void 
		{				
			// get our mouse dir
			const origin:Point		= new Point;
			var shipGlobalPos:Point = this.m_ship.localToGlobal( origin );
			this.m_mouseDir.x		= this.m_input.mousePos.x - shipGlobalPos.x;
			this.m_mouseDir.y		= this.m_input.mousePos.y - shipGlobalPos.y;
			this.m_mouseDir.normalize( 1.0 );
			
			// set our ship rotation
			this.m_ship.rotation = MathHelper.radiansToDegrees( MathHelper.radianAngle( this.m_mouseDir.x, this.m_mouseDir.y ) );
			
			// only move if the mouse is pressed
			if ( !this.m_input.isMousePressed )
				return;
				
			// ignore it if it's around the gui area
			if ( this.m_input.mousePos.x <= 350.0 && this.m_input.mousePos.y <= 50.0 )
				return;
				
			// move our ship
			var speed:Number		= 3;
			this.m_ship.x 			+= this.m_mouseDir.x * speed;
			this.m_ship.y 			+= this.m_mouseDir.y * speed;
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
			
			// create the ship that we'll follow and control
			this.m_ship = new Ship;
			this.m_update.add( this.m_ship );
			
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
			
			// add the ship graphics to the ship layer
			shipLayer.addChild( this.m_ship );
			
			// add the layers so they're controlled by the camera
			this.m_camera.addLayerToControl( planetLayer, 0.25 );
			this.m_camera.addLayerToControl( stars1Layer, 0.5 );
			this.m_camera.addLayerToControl( shipLayer, 1.0 );
			this.m_camera.addLayerToControl( star2Layer, 2.0 );
			
			// create our controls
			this.m_followControls							= new CameraFollowControls( this.m_camera, this.stage );
			this.m_followControls.shouldMoveWithVelocity	= true;
			this.m_followControls.shouldZoomWithVelocity	= true;
			this.m_followControls.followObj					= this.m_ship;
			this.m_update.add( this.m_followControls );
			
			// create our gui elements so we can modify the follow control properties
			this._createGUIControls();
			
			// create our input so we can control the ship, and add ourselves to the update
			this.m_input = new Input( this.stage );
			this.m_update.add( this );
		}
		
		// creates the gui for our ship so we can switch between follow types
		private function _createGUIControls():void
		{
			// create all our elements
			var x:Number = 10;
			var y:Number = 10;
			
			// ease button
			this.m_btnEase 			= new PushButton( this, x, y, "", this._onClickEaseType );
			this.m_btnEase.width	= 150;
			x						+= this.m_btnEase.width + 10;
			
			// ease follow factor
			this.m_scrFollowFactor 			= new HUISlider( this, x, y, "Follow factor", this._onChangeFollowFactor );
			this.m_scrFollowFactor.minimum	= 0.0;
			this.m_scrFollowFactor.maximum	= 2.0;
			this.m_scrFollowFactor.tick		= 0.05;
			this.m_scrFollowFactor.value	= this.m_followControls.followFactor;
			x								= 10;
			y								+= this.m_scrFollowFactor.height + 5.0;
			
			// offset type
			this.m_btnOffset		= new PushButton( this, x, y, "", this._onClickOffsetType );
			this.m_btnOffset.width	= 150.0;
			x						+= this.m_btnOffset.width + 10;
			
			// x offset
			this.m_scrXOffset 			= new HUISlider( this, x, y, "X offset", this._onChangeXOffset );
			this.m_scrXOffset.minimum	= -100.0;
			this.m_scrXOffset.maximum	= 100.0;
			this.m_scrXOffset.tick		= 1.0;
			x							= 10;
			y							+= this.m_scrXOffset.height + 5.0;
			
			// start all our buttons etc off
			this._onClickEaseType( null );
			this._onClickOffsetType( null );
		}
		
		// called when we click on the ease type button - change it to the next one in line
		private function _onClickEaseType( e:MouseEvent ):void
		{
			// get our current ease type and up our index
			var index:int = this.m_easeTypes.indexOf( this.m_currEaseType ) + 1;
			if ( index >= this.m_easeTypes.length )
				index = 0;
				
			// set our current ease type
			this.m_currEaseType 					= this.m_easeTypes[index];
			this.m_followControls.followEaseType	= this.m_currEaseType;
			this.m_btnEase.label					= "Follow type: " + CameraFollowEaseType.toString( this.m_currEaseType );
		}
		
		// called when the slider for the follow factor has changed
		private function _onChangeFollowFactor( e:Event ):void
		{
			this.m_followControls.followFactor = this.m_scrFollowFactor.value;
		}
		
		// called when we click on the offset type button - change it to the next one in line
		private function _onClickOffsetType( e:MouseEvent ):void
		{
			// get our current offset type and up our index
			var index:int = this.m_offsetTypes.indexOf( this.m_currOffsetType ) + 1;
			if ( index >= this.m_offsetTypes.length )
				index = 0;
				
			// set our current ease type
			this.m_currOffsetType 					= this.m_offsetTypes[index];
			this.m_followControls.followOffsetType	= this.m_currOffsetType;
			this.m_btnOffset.label					= "Offset type: " + CameraFollowOffsetType.toString( this.m_currOffsetType );
		}
		
		// called when we change our x offset
		private function _onChangeXOffset( e:Event ):void
		{
			this.m_followControls.setOffsetPoint( this.m_scrXOffset.value, 0.0, this.m_currOffsetType );
		}
		
	}
	
}