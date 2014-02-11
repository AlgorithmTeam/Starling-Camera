package camera.controls 
{
	import camera.Camera;
	import flash.display.Stage;
	import flash.geom.Point;
	import input.Input;
	import org.osflash.signals.Signal;
	
	/**
	 * Controls a camera by moving it when the mouse is near the edges
	 * @author Damian Connolly
	 */
	public class CameraMouseEdgeControls extends CameraControls
	{
		
		/*******************************************************************************************/
		
		/**
		 * The signal dispatched when we start moving the camera with the mouse. It should take no
		 * parameters. This is useful if you're using these controls with other ones, such as
		 * CameraFollowControls, where you can disable those while you're dragging
		 */
		public var signalOnStartedMoving:Signal = null;
		
		/**
		 * How big the move border is
		 */
		public var border:Number = 20.0;
		
		/*******************************************************************************************/
		
		private var m_hasFiredStartSignal:Boolean 	= false;// have we fired our signalOnStartedMoving signal?
		private var m_input:Input					= null; // the input object that tracks our keys/mouse
		
		/*******************************************************************************************/
		
		/**
		 * Creates a new controller for a camera
		 * @param camera The camera that we're going to control
		 * @param stage The main stage
		 * @param input The input object that tracks our keys/mouse
		 */
		public function CameraMouseEdgeControls( camera:Camera, stage:Stage, input:Input ) 
		{
			super( camera, stage );
			this.m_input				= input;
			this.signalOnStartedMoving 	= new Signal;
		}
		
		/**
		 * Destroys the CameraMouseEdgeControls and clears it for garbage collection
		 */
		override public function destroy():void 
		{
			super.destroy();
			this.signalOnStartedMoving.removeAll();
			this.signalOnStartedMoving 	= null;
			this.m_input				= null;
		}
		
		/**
		 * Called every frame the CameraMouseEdgeControls are active
		 * @param dt The delta time since the last update
		 */
		override public function update( dt:Number ):void
		{
			// get our delta depending on the mouse position
			var mousePos:Point = this.m_input.mousePos;
			
			// horizontal
			if ( mousePos.x <= this.m_camera.x + this.border ) // use equal in case border is 0
				this.m_moveDir.x = ( this.border <= 0.0 || mousePos.x <= this.m_camera.x ) ? -1.0 : -( this.border - ( mousePos.x - this.m_camera.x  ) ) / this.border;
			else if ( mousePos.x >= this.m_camera.x + this.m_camera.width - this.border )
				this.m_moveDir.x = ( this.border <= 0.0 || mousePos.x >= this.m_camera.x + this.m_camera.width ) ? 1.0 : ( this.border - ( this.m_camera.x + this.m_camera.width - mousePos.x ) ) / this.border;
			else
				this.m_moveDir.x = 0.0;
				
			// vertical
			if ( mousePos.y <= this.m_camera.x + this.border )
				this.m_moveDir.y = ( this.border <= 0.0 || mousePos.y <= this.m_camera.y ) ? -1.0 : -( this.border - ( mousePos.y - this.m_camera.y ) ) / this.border;
			else if ( mousePos.y >= this.m_camera.x + this.m_camera.height - this.border )
				this.m_moveDir.y = ( this.border <= 0.0 || mousePos.y >= this.m_camera.y + this.m_camera.height ) ? 1.0 : ( this.border - ( this.m_camera.y + this.m_camera.height - mousePos.y ) ) / this.border;
			else
				this.m_moveDir.y = 0.0;
				
			// if there's no change, do nothing
			if ( this.m_moveDir.x != 0.0 || this.m_moveDir.y != 0.0 )
			{
				// normalise our dir if we're moving diagonally, otherwise we'll move quicker
				if ( this.m_moveDir.x != 0.0 && this.m_moveDir.y != 0.0 )
					this.m_moveDir.normalize( 1.0 );
					
				// check if we should compensate for zoom
				var zoomComp:Number	= ( this.shouldMoveCompenstateForZoom ) ? 1.0 / this.m_camera.zoom : 1.0;
				if ( zoomComp != 1.0 )
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
		}
		
	}

}