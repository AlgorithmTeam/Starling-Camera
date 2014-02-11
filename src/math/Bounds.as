package math 
{
	
	/**
	 * A class for holding the min and max bounds of something
	 * @author Damian Connolly
	 */
	public class Bounds 
	{
		
		/*******************************************************************************************/
		
		private var m_min:Number = 0.0;	// the min bounds
		private var m_max:Number = 0.0;	// the max bounds
		
		/*******************************************************************************************/
		
		/**
		 * The minimum bounds. When setting it, this is clamped to the max, if high enough
		 */
		[Inline] public final function get min():Number { return this.m_min; }
		[Inline] public final function set min( n:Number ):void
		{
			this.m_min = ( n > this.m_max ) ? this.m_max : n;
		}
		
		/**
		 * The maximum bounds. When setting it, this is clamped to the min, if low enough
		 */
		[Inline] public final function get max():Number { return this.m_max; }
		[Inline] public final function set max( n:Number ):void
		{
			this.m_max = ( n < this.m_min ) ? this.m_min : n;
		}
		
		/*******************************************************************************************/
		
		/**
		 * Creates a new Bounds
		 * @param min The minimum bounds
		 * @param max The maximum bounds
		 */
		public function Bounds( min:Number, max:Number ) 
		{
			// swap them about if the min is bigger than the max
			if ( min > max )
			{
				trace( "[Bounds] Swapping the min and max bounds, as the min (" + min + ") is larger than the max (" + max + ")" );
				var m:Number 	= min;
				min				= max;
				max				= min;
			}
			
			// set them
			this.m_min = min;
			this.m_max = max;
		}
		
		/**
		 * The String version of the Bounds object
		 */
		public function toString():String
		{
			return "[Bounds min: " + this.m_min + ", max: " + this.m_max + "]";
		}
		
	}

}