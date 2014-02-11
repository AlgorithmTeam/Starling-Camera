package camera.controls
{
	import camera.Camera;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import math.MathHelper;
	
	/**
	 * Lets us select objects through the camera by clicking on them
	 * @author Damian Connolly
	 */
	public class CameraClickControls extends CameraControls 
	{
		
		/*******************************************************************************************/
		
		private var m_mouseDownPos:Point = null; // the point where we've moused down (for clicking)
		
		/*******************************************************************************************/
		
		/**
		 * Creates a new click controller for the camera
		 * @param camera The camera that this is for
		 * @param stage The main stage
		 */
		public function CameraClickControls( camera:Camera, stage:Stage ) 
		{
			super( camera, stage );
			this.m_mouseDownPos = new Point;
			
			// add our listeners for our click
			this.m_stage.addEventListener( MouseEvent.MOUSE_DOWN, this._onMouseDown );
			this.m_stage.addEventListener( MouseEvent.CLICK, this._onClick );
		}
		
		/**
		 * Destroys the CameraClickControls and clears it for garbage collection
		 */
		override public function destroy():void 
		{
			super.destroy();
			
			// remove our listeners for our click
			this.m_stage.removeEventListener( MouseEvent.MOUSE_DOWN, this._onMouseDown );
			this.m_stage.removeEventListener( MouseEvent.CLICK, this._onClick );
			
			// null our properties
			this.m_mouseDownPos = null;
		}
		
		/*******************************************************************************************/
		
		// called when we mouse down on the stage
		protected function _onMouseDown( e:MouseEvent ):void
		{
			// we can only click if we're active
			if ( this.active )
				this.m_mouseDownPos.setTo( e.stageX, e.stageY );
		}
		
		// called when we click on the stage - if we haven't moved much, then it's a click
		protected function _onClick( e:MouseEvent ):void
		{
			// if we're not active, then we can't click
			if ( !this.active )
				return;
				
			// check our dist and tell our camera, if it's good
			if ( MathHelper.dist( e.stageX, e.stageY, this.m_mouseDownPos.x, this.m_mouseDownPos.y ) < CameraControls.CLICK_DIST )
			{
				this.m_camera.onClick( e.stageX, e.stageY );
				return;
			}
		}
		
	}

}