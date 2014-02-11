package camera.enums 
{
	
	/**
	 * The different ease types we can use when following an object
	 * @author Damian Connolly
	 */
	public class CameraFollowEaseType
	{
		
		/*******************************************************************************************/
		
		/**
		 * No interpolation, just straight following
		 */
		public static const NONE:CameraFollowEaseType = new CameraFollowEaseType;
		
		/**
		 * Use linear interpolation when following our object
		 */
		public static const LERP:CameraFollowEaseType = new CameraFollowEaseType;
		
		/**
		 * Use curved damping when following our object
		 */
		public static const DAMP:CameraFollowEaseType = new CameraFollowEaseType;
		
		/*******************************************************************************************/
		
		/**
		 * Gives the description of the CameraFollowEaseType
		 * @param type The CameraFollowEaseType that we want to describe
		 * @return The CameraFollowEaseType String description
		 */
		public static function toString( type:CameraFollowEaseType ):String
		{
			if ( type == CameraFollowEaseType.NONE )
				return "None";
			else if ( type == CameraFollowEaseType.LERP )
				return "Linear interpolation";
			else if ( type == CameraFollowEaseType.DAMP )
				return "Damping";
			return "Unknown ease type";
		}
		
	}

}