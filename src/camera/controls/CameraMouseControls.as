package camera.controls 
{
	import camera.Camera;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import input.Input;
	import math.MathHelper;
	import org.osflash.signals.Signal;

	/**
	 * Camera controls using the mouse - drag the camera around etc
	 * @author Damian Connolly
	 */
	public class CameraMouseControls extends CameraControls
	{
		
		/*******************************************************************************************/
		
		/**
		 * The signal dispatched when we start moving the camera with the mouse. It should take no
		 * parameters. This is useful if you're using these controls with other ones, such as
		 * CameraFollowControls, where you can disable those while you're dragging
		 */
		public var signalOnStartedMoving:Signal = null;
		
		/**
		 * The average drag length - this will be used when dragging by velocity - the faster we
		 * move, then more our moveSpeed is multiplied by
		 */
		public var averageDragLength:Number = 10.0;
		
		/*******************************************************************************************/
		
		private var m_input:Input					= null;	// the input object that tracks our keys/mouse
		private var m_startMousePos:Point			= null;	// the starting mouse position, when dragging
		private var m_prevMousePos:Point			= null; // the previous mouse position
		private var m_prevMouseWasPressed:Boolean	= false;// was the mouse pressed in the previous frame?
		private var m_hasFiredStartSignal:Boolean	= false;// have we fired our signalOnStartedMoving signal?
		private var m_zoomDir:int					= 0;	// our zoom direction (mouse wheel)
		
		/*******************************************************************************************/
		
		/**
		 * Creates new CameraMouseControls
		 * @param camera The camera that we're controlling
		 * @param stage The main stage
		 * @param input The input object that tracks our keys/mouse
		 */
		public function CameraMouseControls( camera:Camera, stage:Stage, input:Input ) 
		{
			super( camera, stage );
			this.m_input				= input;
			this.signalOnStartedMoving	= new Signal;
			this.m_startMousePos		= new Point;
			this.m_prevMousePos 		= new Point;
			
			// add our zoom listener
			this.m_stage.addEventListener( MouseEvent.MOUSE_WHEEL, this._onMouseWheel );
		}
		
		/**
		 * Destroys the CameraMouseControls and clears them for garbage collection
		 */
		override public function destroy():void 
		{
			super.destroy();
			this.signalOnStartedMoving.removeAll();
			this.signalOnStartedMoving	= null;
			this.m_input				= null;
			this.m_startMousePos		= null;
			this.m_prevMousePos 		= null;
			
			// remove our zoom listener
			this.m_stage.removeEventListener( MouseEvent.MOUSE_WHEEL, this._onMouseWheel );
		}
		
		/**
		 * Updates the CameraMouseControls every frame it's active
		 * @param dt The delta time
		 */
		override public function update( dt:Number ):void 
		{
			// we only update the move if the mouse is pressed
			var isPressed:Boolean	= this.m_input.isMousePressed;
			var currMousePos:Point	= this.m_input.mousePos;
			if ( !isPressed && !this.m_prevMouseWasPressed )
			{
				// keep track of the mouse
				this.m_prevMousePos.copyFrom( currMousePos );
				this.m_hasFiredStartSignal = false;
			}
			else
			{
				// if we weren't pressed in the previous frame, then store our starting position
				if ( isPressed && !this.m_prevMouseWasPressed )
					this.m_startMousePos.copyFrom( currMousePos );
					
				// get our delta movement, and our zoom multiplier if we're compensating for zoom
				var zoomComp:Number	= ( this.shouldMoveCompenstateForZoom ) ? 1.0 / this.m_camera.zoom : 1.0;
				this.m_moveDir.x 	= ( this.m_prevMousePos.x - currMousePos.x );
				this.m_moveDir.y 	= ( this.m_prevMousePos.y - currMousePos.y );
					
				// if we're pressed (or not moving with velocity), then we're currently dragging the camera around,
				// so just move by our moveDir (non-normalised, so it's the delta movement).
				// if we're not pressed, then we've just let go of the mouse, so if the distance is good (i.e. it's
				// not a click), and we're moving with velocity, set the camera off
				var wasClick:Boolean = MathHelper.dist( currMousePos.x, currMousePos.y, this.m_startMousePos.x, this.m_startMousePos.y ) <= CameraControls.CLICK_DIST;
				if ( !wasClick && ( isPressed || !this.shouldMoveWithVelocity ) )
				{
					// NOTE: we always compensate for zoom when dragging, otherwise the camera doesn't move right under our mouse
					if( !this.shouldMoveCompenstateForZoom && isPressed )
						zoomComp = 1.0 / this.m_camera.zoom;
					this.m_camera.moveCameraBy( this.m_moveDir.x * zoomComp, this.m_moveDir.y * zoomComp );
				}
				else if( !wasClick && !isPressed && this.shouldMoveWithVelocity ) // only move with velocity if we've moved far enough (i.e. this is not a click)
				{
					// if we should compensate for zoom, update our move dir
					if ( this.shouldMoveCompenstateForZoom )
					{
						this.m_moveDir.x *= zoomComp;
						this.m_moveDir.y *= zoomComp;
					}
					
					// get the multiplier for our move dir (based on our average drag length) - the faster we move, 
					// the more we multiply our move speed by
					var mult:int = int( ( this.m_moveDir.length / this.averageDragLength ) * zoomComp + 0.5 ); // fast round
					if ( mult == 0 )
						mult = 1;
						
					// normalise our move dir to our multiplier and set our velocity
					this.m_moveDir.normalize( mult );
					this.m_camera.setMoveVelocityBy( this.m_moveDir.x * this.moveSpeed * dt, this.m_moveDir.y * this.moveSpeed * dt );
				}
				
				// update the previous mouse position
				this.m_prevMousePos.copyFrom( currMousePos );
				this.m_prevMouseWasPressed = isPressed;
				
				// dispatch our signal if we haven't already (and it wasn't a click)
				if ( !this.m_hasFiredStartSignal && !wasClick )
				{
					this.signalOnStartedMoving.dispatch();
					this.m_hasFiredStartSignal = true;
				}
			}
			
			// if we're not zooming, just return
			if ( this.m_zoomDir == 0 )
				return;
				
			// set if we're zooming with velocity or just normally (logarithmically so we get a smooth scale)
			if( this.shouldZoomWithVelocity )
				this.m_camera.setZoomVelocityBy( this.m_zoomDir * this.zoomSpeed * dt );
			else
				this.m_camera.zoomCameraLogarithmicallyBy( this.m_zoomDir * this.zoomSpeed * dt );
			
			// clear our zoom dir
			this.m_zoomDir = 0;
		}
		
		/*******************************************************************************************/
		
		// called when we're moving the mouse wheel
		private function _onMouseWheel( e:MouseEvent ):void
		{
			this.m_zoomDir = ( e.delta > 0 ) ? 1 : -1;
		}
		
	}

}