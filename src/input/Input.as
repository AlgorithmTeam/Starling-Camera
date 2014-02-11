package input 
{
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;

    import starling.display.Stage;

    /**
	 * Tracks if certain keys are pressed
	 * @author Damian Connolly
	 */
	public class Input 
	{
		
		/*******************************************************************************************/
		
		/**
		 * The current mouse position
		 */
		public var mousePos:Point = new Point;
		
		/**
		 * Is the left mouse button currently pressed?
		 */
		public var isMousePressed:Boolean = false;
		
		/*******************************************************************************************/
		
		private var m_keys:Vector.<Boolean> = null; // the keys that we're tracking
		
		/*******************************************************************************************/
		
		/**
		 * Creates a new Input object
		 * @param stage The main stage
		 */
		public function Input( stage:Stage ) 
		{
			// create our vector
			// NOTE: for this demo, we're tracking pg_up, pg_down, and the a-z keys
			// so our vector only needs space for 91 booleans (keycode for z is 90)
			this.m_keys = new Vector.<Boolean>( Keyboard.Z, true );
			
			// add our listeners
			stage.addEventListener( KeyboardEvent.KEY_DOWN, this._onKeyDown );
			stage.addEventListener( KeyboardEvent.KEY_UP, this._onKeyUp );
			stage.addEventListener( MouseEvent.MOUSE_DOWN, this._onMouseDown );
			stage.addEventListener( MouseEvent.MOUSE_UP, this._onMouseUp );
			stage.addEventListener( MouseEvent.MOUSE_MOVE, this._onMouseMove );
		}
		
		/**
		 * Returns if a key is pressed
		 * @param key The key that we're looking for; use the Keyboard constants
		 * @return True if the key is pressed, false otherwise
		 */
		public function isPressed( key:uint ):Boolean
		{
			return ( key < this.m_keys.length ) ? this.m_keys[key] : false;
		}
		
		/*******************************************************************************************/
		
		// called when a key is pressed
		private function _onKeyDown( e:KeyboardEvent ):void
		{
			if ( e.keyCode < this.m_keys.length )
				this.m_keys[e.keyCode] = true;
		}
		
		// called when a key is down
		private function _onKeyUp( e:KeyboardEvent ):void
		{
			if ( e.keyCode < this.m_keys.length )
				this.m_keys[e.keyCode] = false;
		}
		
		// called when the left mouse button is pressed down
		private function _onMouseDown( e:MouseEvent ):void
		{
			this.isMousePressed = true;
		}
		
		// called when the left mouse button is released
		private function _onMouseUp( e:MouseEvent ):void
		{
			this.isMousePressed = false;
		}
		
		// called when we move the mouse
		private function _onMouseMove( e:MouseEvent ):void
		{
			this.mousePos.setTo( e.stageX, e.stageY );
		}
		
	}

}