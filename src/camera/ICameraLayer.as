package camera 
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * The interface that describes the layers that we add to our camera
	 * @author Damian Connolly
	 */
	public interface ICameraLayer 
	{
		
		/*******************************************************************************************/
		
		/**
		 * The x position of the layer
		 */
		function get x():Number;
		function set x( n:Number ):void;
		
		/**
		 * The y position of the layer
		 */
		function get y():Number;
		function set y( n:Number ):void;
		
		/**
		 * The x scale of the layer
		 */
		function get scaleX():Number;
		function set scaleX( n:Number ):void;
		
		/**
		 * The y scale of the layer
		 */
		function get scaleY():Number;
		function set scaleY( n:Number ):void;
		
		/**
		 * Should this layer be scaled when the camera is zoomed?
		 */
		function get isZoomEnabled():Boolean;
		
		/*******************************************************************************************/
		
		/**
		 * Converts the Point coordinates from stage space to local space
		 * @param point A Point with coordinates declared in stage space
		 * @return A Point, where our coordinates have been translated to local space
		 */
		function globalToLocal( point:Point ):Point
		
		/**
		 * Checks the visibility of the children based on the camera view rect
		 * @param viewRect The view rect of the camera, in layer space
		 */
		function checkChildrenVisibility( viewRect:Rectangle ):void;
		
		/**
		 * Sorts all the children
		 * @param compareFunction The function to use to sort the children; works similar to Vector or Array sort
		 */
		function sortChildren( compareFunction:Function ):void;
		
		/**
		 * Called when there's a click on the layer
		 * @param localX The x position of the click, in layer space
		 * @param localY The y position of the click, in layer space
		 */
		function onClick( localX:Number, localY:Number ):void;
		
	}

}