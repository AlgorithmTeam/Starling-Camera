package camera.controls 
{
	import camera.Camera;
	import flash.display.Stage;
	import flash.geom.Point;
	import update.IUpdateObj;
	
	/**
	 * A generic camera controller
	 * @author Damian Connolly
	 */
	public class CameraControls implements IUpdateObj
	{
		
		/*******************************************************************************************/
		
		/**
		 * The distance between MOUSE_DOWN and MOUSE_UP, where we consider it as a click
		 */
		public static const CLICK_DIST:Number = 4.0;
		
		/*******************************************************************************************/
		
		/**
		 * The speed that we're moving the camera at
		 */
		public var moveSpeed:Number = 200.0;
		
		/**
		 * The speed that we're zooming the camera at
		 */
		public var zoomSpeed:Number = 5.0;
		
		/**
		 * Should we move the camera using velocity?
		 */
		public var shouldMoveWithVelocity:Boolean = false;
		
		/**
		 * Should we zoom the camera using velocity?
		 */
		public var shouldZoomWithVelocity:Boolean = false;
		
		/**
		 * Should we take zoom into account when moving? For the most part, you should leave this
		 * as true, as it gives a better user experience when zoomed in or out. Setting to false
		 * means that we move the same amount regardless of the camera zoom (and as zoom relates
		 * to scale, it means we'll effectively move at twice the speed when we're half the scale)
		 */
		public var shouldMoveCompenstateForZoom:Boolean = true;
		
		/*******************************************************************************************/
		
		/**
		 * The main stage - so we can add event listeners
		 */
		protected var m_stage:Stage = null;
		
		/**
		 * The camera that we're controlling
		 */
		protected var m_camera:Camera = null;
		
		/**
		 * The direction that we're going to move in
		 */
		protected var m_moveDir:Point = null;
		
		/*******************************************************************************************/
		
		private var m_active:Boolean = true; // are the controls active?
		
		/*******************************************************************************************/
		
		/**
		 * Returns true if the CameraControls are active
		 */
		[Inline] public final function get active():Boolean { return this.m_active; }
		[Inline] public final function set active( b:Boolean ):void
		{
			this.m_active = b;
		}
		
		/*******************************************************************************************/
		
		/**
		 * Creates a new camera controller
		 * @param camera The camera that we're controlling
		 * @param stage The main stage
		 */
		public function CameraControls( camera:Camera, stage:Stage ) 
		{
			this.m_camera 	= camera;
			this.m_stage	= stage;
			this.m_moveDir	= new Point;
		}
		
		/**
		 * Destroys the CameraControls and clears it for garbage collection
		 */
		public function destroy():void
		{
			// remove from the update
			// NOTE: it'll need to be removed from the Update
			this.m_active = false;
			
			// clear our properties
			this.m_camera	= null;
			this.m_stage	= null;
			this.m_moveDir	= null;
		}
		
		/**
		 * Updates the CameraControls every frame while they're active
		 * @param dt The delta time since the last update
		 */
		public function update( dt:Number ):void
		{
			// to be overridden
		}
		
	}

}