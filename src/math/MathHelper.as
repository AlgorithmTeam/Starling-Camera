package math 
{
	import flash.geom.Point;
	/**
	 * Math helper functions
	 * @author Damian Connolly
	 */
	public class MathHelper 
	{
		
		/*******************************************************************************************/
		
		// Allows easy conversion from degrees to radians, avoiding the division call
		private static const D_TO_R:Number = Math.PI / 180.0;
		
		// Allows easy conversion from radians to degrees, avoiding the division call
		private static const R_TO_D:Number = 180.0 / Math.PI;
		
		/*******************************************************************************************/
		
		/**
		 * Converts a given degree value to its radian equivalent
		 * @param deg The degree value that we want to change
		 * @return The radian value of deg
		 */
		public static function degreesToRadians( deg:Number ):Number
		{
			return deg * MathHelper.D_TO_R;
		}
		
		/**
		 * Converts a given radian value to its degree equivalent
		 * @param rad The radian value that we want to change
		 * @return The degree value of rad
		 */
		public static function radiansToDegrees( rad:Number ):Number
		{
			return rad * MathHelper.R_TO_D;
		}
		
		/**
		 * Returns the radian angle from some coords
		 * @param x The x coord
		 * @param y The y coord
		 * @return The angle made by this position in radians
		 */
		public static function radianAngle( x:Number, y:Number ):Number
		{
			return Math.atan2( y, x );
		}
		
		/**
		 * Returns the distance between two points
		 * @param ax The x value of the first point
		 * @param ay The y value of the first point
		 * @param bx The x value of the second point
		 * @param by The y value of the secon point
		 * @return The distance between these two points
		 */
		public static function dist( ax:Number, ay:Number, bx:Number, by:Number ):Number
		{
			var dx:Number = ax - bx;
			var dy:Number = ay - by;
			return Math.sqrt( ( dx * dx ) + ( dy * dy ) );
		}
		
		/**
		 * Rotates a point by a certain number of radians
		 * @param p The point that we're trying to rotate
		 * @param radians The amount of radians to rotate it by
		 * @param out A Point to copy our results to. If null, a new one is created
		 * @return A new, rotated, Point
		 */
		public static function rotate( p:Point, radians:Number, out:Point = null ):Point
		{
			// formula is:
			// x1 = x * cos( r ) - y * sin( r )
			// y1 = x * sin( r ) + y * cos( r )
			var sin:Number	= Math.sin( radians );
			var cos:Number	= Math.cos( radians );
			var ox:Number	= p.x * cos - p.y * sin;
			var oy:Number	= p.x * sin + p.y * cos;
			
			// we use ox and oy in case out is one of our points
			if ( out == null )
				out = new Point;
			out.x = ox;
			out.y = oy;
			return out;
		}
		
		/**
		 * Lerps from one number to another
		 * @param a The start number
		 * @param b The end number
		 * @param t How close we want to be (0-1)
		 * @return The lerped number
		 */
		public static function lerp( a:Number, b:Number, t:Number ):Number
		{
			return b * t + ( 1 - t ) * a;
		}

		/**
		 * Damps a number from one value to another
		 * @param source The source number
		 * @param dest The destination number
		 * @param dt The delta time
		 * @param factor The factor of the damp (0-1)
		 * @param precision How close to get before just returning source
		 * @return The damped number
		 */
		public static function damp( source:Number, dest:Number, dt:Number, factor:Number, precision:Number ):Number
		{
			if ( Math.abs( source - dest ) < precision )
				return source;
			return ( ( source * factor ) + ( dest * dt ) ) / ( factor + dt );
		}
		
	}

}