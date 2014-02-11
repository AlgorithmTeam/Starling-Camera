package map 
{
	import flash.display.Shape;
	import update.IUpdateObj;
	
	/**
	 * A marker to show a ship that's been selected
	 * @author Damian Connolly
	 */
	public class ShipMarker extends Shape implements IUpdateObj
	{
		
		/*******************************************************************************************/
		
		private var m_ship:Ship = null; // the ship that we're marking
		
		/*******************************************************************************************/
		
		/**
		 * Returns if the marker is active or not
		 */
		public function get active():Boolean { return ( this.m_ship != null ); }
		
		/**
		 * The ship that we're marking
		 */
		public function get ship():Ship { return this.m_ship; }
		public function set ship( s:Ship ):void
		{
			this.m_ship = s;
			
			// if we have a ship, add ourselves to its parent, just under it
			if ( this.m_ship != null )
			{
				// add us and add the ship, so the ship is always on top
				this.m_ship.parent.addChild( this );
				this.m_ship.parent.addChild( this.m_ship );
			}
			else if ( this.parent != null )
				this.parent.removeChild( this );
		}
		
		/*******************************************************************************************/
		
		/**
		 * Creates a new ShipMarker
		 */
		public function ShipMarker() 
		{
			this._draw();
		}
		
		/**
		 * Called every frame that we're active (i.e. that we have a ship)
		 * @param dt The delta time since the last call to update
		 */
		public function update( dt:Number ):void 
		{
			// just follow our ship
			this.x = this.m_ship.x;
			this.y = this.m_ship.y;
		}
		
		/*******************************************************************************************/
		
		// draws our ship
		private function _draw():void
		{
			this.graphics.clear();
			this.graphics.lineStyle( 2.0, 0x000099 );
			this.graphics.beginFill( 0x0000ff, 0.3 );
			this.graphics.drawCircle( 0.0, 0.0, 20.0 );
			this.graphics.endFill();
		}
		
	}

}