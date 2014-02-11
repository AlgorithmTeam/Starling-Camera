package camera.controls 
{
	import camera.Camera;
	import flash.display.Stage;
	import flash.ui.Keyboard;
	import input.Input;
	import org.osflash.signals.Signal;
	
	/**
	 * Controls a Camera using key controls
	 * @author Damian Connolly
	 */
	public class CameraKeyControls extends CameraControls
	{
		
		/*******************************************************************************************/
		
		/**
		 * The signal dispatched when we start moving the camera with the keys. It should take no
		 * parameters. This is useful if you're using these controls with other ones, such as
		 * CameraFollowControls, where you can disable those while you're dragging
		 */
		public var signalOnStartedMoving:Signal = null;
		
		/*******************************************************************************************/
		
		private var m_hasFiredStartSignal:Boolean 	= false;// have we fired our signalOnStartedMoving signal?
		private var m_input:Input					= null; // the input object that keeps track of our keys
		
		/*******************************************************************************************/
		
		/**
		 * Creates a new controller for a camera
		 * @param camera The camera that we're going to control
		 * @param stage The main stage
		 * @param input The input object that keeps track of our keys
		 */
		public function CameraKeyControls( camera:Camera, stage:Stage, input:Input ) 
		{
			super( camera, stage );
			this.m_input				= input;
			this.signalOnStartedMoving 	= new Signal;
		}
		
		/**
		 * Destroys the CameraKeyControls and clears it for garbage collection
		 */
		override public function destroy():void 
		{
			super.destroy();
			this.signalOnStartedMoving.removeAll();
			this.signalOnStartedMoving 	= null;
			this.m_input				= null;
		}
		
		/**
		 * Called every frame the CameraKeyControls are active
		 * @param dt The delta time since the last update
		 */
		override public function update( dt:Number ):void
		{
			// get our xdir and ydir based on what keys are pressed
			if ( this.m_input.isPressed( Keyboard.LEFT  ) )
				this.m_moveDir.x = -1.0;
			else if ( this.m_input.isPressed( Keyboard.RIGHT ) )
				this.m_moveDir.x = 1.0;
			else
				this.m_moveDir.x = 0.0;
			if ( this.m_input.isPressed( Keyboard.UP ) )
				this.m_moveDir.y = -1.0;
			else if ( this.m_input.isPressed( Keyboard.DOWN ) )
				this.m_moveDir.y = 1.0;
			else
				this.m_moveDir.y = 0.0;
				
			// get the zoom
			var zoomDir:int = 0;
			if ( this.m_input.isPressed( Keyboard.PAGE_UP ) )
				zoomDir = 1;
			else if ( this.m_input.isPressed( Keyboard.PAGE_DOWN ) )
				zoomDir = -1;
				
			// move the camera is needed
			if ( this.m_moveDir.x != 0.0 || this.m_moveDir.y != 0.0 )
			{
				// normalise our dir if we're moving diagonally, otherwise we'll move quicker
				if ( this.m_moveDir.x != 0.0 && this.m_moveDir.y != 0.0 )
					this.m_moveDir.normalize( 1.0 );
					
				// check if we should compensate for zoom
				var zoomComp:Number	= ( this.shouldMoveCompenstateForZoom ) ? 1.0 / this.m_camera.zoom : 1.0;
				if( zoomComp != 1.0 )
				{
					this.m_moveDir.x *= zoomComp;
					this.m_moveDir.y *= zoomComp;
				}
					
				// either move directly, or with velocity
				if( this.shouldMoveWithVelocity )
					this.m_camera.setMoveVelocityBy( this.m_moveDir.x * this.moveSpeed * dt, this.m_moveDir.y * this.moveSpeed * dt );
				else
					this.m_camera.moveCameraBy( this.m_moveDir.x * this.moveSpeed * dt, this.m_moveDir.y * this.moveSpeed * dt );
				
				// dispatch our signal if we haven't already
				if ( !this.m_hasFiredStartSignal )
				{
					this.signalOnStartedMoving.dispatch();
					this.m_hasFiredStartSignal = true;
				}
			}
			else
				this.m_hasFiredStartSignal = false;
				
			// scale if needed
			if ( zoomDir != 0 )
			{
				if( this.shouldZoomWithVelocity )
					this.m_camera.setZoomVelocityBy( zoomDir * this.zoomSpeed * dt );
				else
					this.m_camera.zoomCameraLogarithmicallyBy( zoomDir * this.zoomSpeed * dt );
			}
		}
		
	}

}