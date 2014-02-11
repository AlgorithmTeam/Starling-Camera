package camera 
{
	import flash.geom.Point;
	
	/**
	 * Internal class used by the Camera to keep track of its layers
	 * @author Damian Connolly
	 */
	internal class CameraLayerRef 
	{
	
		/*******************************************************************************************/
		
		/**
		 * The layer that we're controlling
		 */
		public var layer:ICameraLayer = null;
		
		/**
		 * The offset for this object; used when positioning it
		 */
		public var offset:Point	= new Point;
		
		/**
		 * The speed factor for this object; used for parallax effects
		 */
		public var speedFactor:Number = 1.0;
		
		/**
		 * The original scale for the display object
		 */
		public var origScale:Point = new Point;
		
		/*******************************************************************************************/
		
		/**
		 * Creates a new CameraLayerRef
		 * @param layer The ICameraLayer that this is for
		 */
		public function CameraLayerRef( layer:ICameraLayer ):void
		{
			this.layer = layer;
		}
		
		/**
		 * Destroys the CameraLayerRef and clears it for garbage collection
		 */
		public function destroy():void
		{
			this.layer		= null;
			this.offset		= null;
			this.origScale	= null;
		}
		
	}

}