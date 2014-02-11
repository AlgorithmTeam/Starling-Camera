package update 
{
	
	/**
	 * Interface for an update object
	 * @author Damian Connolly
	 */
	public interface IUpdateObj 
	{
		
		/*******************************************************************************************/
		
		/**
		 * Returns if the object is active and should be updated
		 */
		function get active():Boolean;
		
		/*******************************************************************************************/
		
		/**
		 * Updates the object, if it's active
		 * @param dt The delta time since the last update
		 */
		function update( dt:Number ):void;
		
	}
	
}