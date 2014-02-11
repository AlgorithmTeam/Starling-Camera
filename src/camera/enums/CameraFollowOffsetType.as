package camera.enums 
{
	
	/**
	 * The different types for following an object with an offset
	 * @author Damian Connolly
	 */
	public class CameraFollowOffsetType
	{
		
		/*******************************************************************************************/
		
		/**
		 * There's no offset type - just use the offset provided
		 */
		public static const NONE:CameraFollowOffsetType = new CameraFollowOffsetType;
		
		/**
		 * Use the offset provided, multiplied by the object's rotation
		 */
		public static const OBJ_ROTATION:CameraFollowOffsetType = new CameraFollowOffsetType;
		
		/**
		 * Use the offset provided, multiplied by the object's position delta
		 */
		public static const OBJ_POS_DELTA:CameraFollowOffsetType = new CameraFollowOffsetType;
		
		/*******************************************************************************************/
		
		/**
		 * Gives the description of the CameraFollowOffsetType
		 * @param type The CameraFollowOffsetType that we want to describe
		 * @return The CameraFollowOffsetType String description
		 */
		public static function toString( type:CameraFollowOffsetType ):String
		{
			if ( type == CameraFollowOffsetType.NONE )
				return "None";
			else if ( type == CameraFollowOffsetType.OBJ_ROTATION )
				return "Object rotation";
			else if ( type == CameraFollowOffsetType.OBJ_POS_DELTA )
				return "Object position delta";
			return "Unknown offset type";
		}
		
	}

}