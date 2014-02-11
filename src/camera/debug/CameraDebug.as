package camera.debug 
{
	import camera.Camera;
	import flash.display.Shape;
	import update.IUpdateObj;
	
	/**
	 * Debug visual so we can see the current camera
	 * @author Damian Connolly
	 */
	public class CameraDebug extends Shape implements IUpdateObj
	{
	
		/*******************************************************************************************/
		
		private var m_camera:Camera = null; // the camera that we're debugging
	
		/*******************************************************************************************/
		
		/**
		 * Returns if the CameraDebug is active and should show
		 */
		public function get active():Boolean { return ( this.parent != null && this.visible && this.alpha > 0.0 ); }
		
		/*******************************************************************************************/
		
		/**
		 * Creates a new CameraDebug
		 * @param camera The camera that we're debugging
		 */
		public function CameraDebug( camera:Camera ) 
		{
			this.m_camera 	= camera;
			this.alpha		= 0.5;
		}
		
		/**
		 * Destroys the CameraDebug and clears us for garbage collection
		 */
		public function destroy():void
		{			
			// graphics
			if ( this.parent != null )
				this.parent.removeChild( this );
		}
		
		/**
		 * Called every frame we're active - draw our camera
		 * @param dt The delta time since the last update
		 */
		public function update( dt:Number ):void
		{
			this._draw();
		}
		
		/*******************************************************************************************/
		
		// draws the debug for the camera
		private function _draw():void
		{
			this.graphics.clear();
			this.graphics.lineStyle( 1.0, 0x990099 );
			this.graphics.drawRect( this.m_camera.x, this.m_camera.y, this.m_camera.width, this.m_camera.height );
			this.graphics.moveTo( this.m_camera.x, this.m_camera.y );
			this.graphics.lineTo( this.m_camera.x + this.m_camera.width, this.m_camera.y + this.m_camera.height );
			this.graphics.moveTo( this.m_camera.x, this.m_camera.y + this.m_camera.height );
			this.graphics.lineTo( this.m_camera.x + this.m_camera.width, this.m_camera.y );
		}
		
	}

}