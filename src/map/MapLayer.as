package map 
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import camera.ICameraLayer;
	import flash.geom.Point;
	import org.osflash.signals.Signal;
	
	/**
	 * A simple MapLayer, that we'll control using the camera
	 * @author Damian Connolly
	 */
	public class MapLayer extends Sprite implements ICameraLayer 
	{
		// NOTE: a lot of the interface (x, y, scaleX, scaleY, and globalToLocal) are inherited from
		// Sprite
		
		/*******************************************************************************************/
		
		private static var m_helperPoint:Point = new Point; // helper point for when we're dealing with click events
		
		/*******************************************************************************************/
		
		/**
		 * The signal dispatched when we click on a ship. It should take one parameter of type Ship
		 */
		public var signalOnSelectShip:Signal = null;
		
		/**
		 * The signal dispatched when we select a position on the screen. It should take two parameters
		 * of type Number (x, y)
		 */
		public var signalOnSelectPos:Signal = null;
		
		/*******************************************************************************************/
		
		private var m_ships:Vector.<Ship>	= null; // the list of ships that we have in this layer
		private var m_isZoomEnabled:Boolean = true; // should we scale when the camera is zoomed?
		
		/*******************************************************************************************/
		
		/**
		 * Should this layer be scaled when the camera is zoomed?
		 */
		public function get isZoomEnabled():Boolean { return this.m_isZoomEnabled; }
		public function set isZoomEnabled( b:Boolean ):void
		{
			this.m_isZoomEnabled = b;
		}
		
		/*******************************************************************************************/
		
		/**
		 * Creates a new MapLayer
		 * @param drawPlanets Should we draw our planets?
		 * @param drawStars Should we draw our stars?
		 * @param rows The number of rows for our grid, or 0 if we shouldn't draw it
		 * @param cols The number of cols for our grid, or 0 if we shouldn't draw it
		 */
		public function MapLayer( drawPlanets:Boolean, drawStars:Boolean, rows:int = 0, cols:int = 0 )
		{
			// the width and height of the layer
			// NOTE: all the graphics are centered around 0,0, so the layer bounds are -1000, 1000
			var w:Number = 2000;
			var h:Number = 2000;
				
			// grid
			if ( rows != 0 && cols != 0 )
			{
				this.graphics.lineStyle( 1.0, 0xffffff, 0.2 );
				
				// rows
				var tileW:Number 	= w / cols;
				var tileH:Number	= h / rows;
				for ( var r:int = 0; r <= rows; r++ )
				{
					this.graphics.moveTo( -w * 0.5, -h * 0.5 + r * tileH );
					this.graphics.lineTo( -w * 0.5 + cols * tileW, -h * 0.5 + r * tileH );
				}
				
				// cols
				for ( var c:int = 0; c <= cols; c++ )
				{
					this.graphics.moveTo( -w * 0.5 + c * tileW, -h * 0.5 );
					this.graphics.lineTo( -w * 0.5 + c * tileW, -h * 0.5 + rows * tileH );
				}
			}
			
			// planets
			if ( drawPlanets )
			{				
				var numPlanets:int = 5 + int( Math.random() * 10 );
				for ( var p:int = 0; p < numPlanets; p++ )
				{
					this.graphics.lineStyle( 2.0, 0x000066 );
					this.graphics.beginFill( 0x7f7fff );
					this.graphics.drawCircle( -w * 0.5 + Math.random() * w, -h * 0.5 + Math.random() * h, 25 + Math.random() * 30 );
					this.graphics.endFill();
				}
			}
			
			// stars
			if ( drawStars )
			{
				var numStars:int = 50 + int( Math.random() * 50 );
				for ( var s:int = 0; s < numStars; s++ )
				{
					this.graphics.lineStyle( 1.0, 0xffffff );
					this.graphics.beginFill( 0xffffff );
					this.graphics.drawCircle( -w * 0.5 + Math.random() * w, -h * 0.5 + Math.random() * h, 2 + Math.random() * 4 );
					this.graphics.endFill();
				}
			}
			
			// create our signals
			this.signalOnSelectPos	= new Signal( Number, Number );
			this.signalOnSelectShip	= new Signal( Ship );
		}
		
		/**
		 * Checks the visibility of the children based on the camera view rect
		 * @param viewRect The view rect of the camera, in layer space
		 */
		public function checkChildrenVisibility( viewRect:Rectangle ):void
		{
			// here we can check if our internal object's bounds intersect with the
			// view rect from the camera. we can add/remove or toggle visibility depending
			// on your layer implementation, the idea being to not render objects that
			// aren't visible
		}
		
		/**
		 * Sorts all the children
		 * @param compareFunction The function to use to sort the children; works similar to Vector or Array sort
		 */
		public function sortChildren( compareFunction:Function ):void
		{
			// here we can sort any children that need it. often the camera will
			// move to track an object - in this demo, a ship - and so we may need
			// to resort to make sure that it appears in front of objects that it should.
		}
		
		/**
		 * Called when there's a click on the layer
		 * @param localX The x position of the click, in layer space
		 * @param localY The y position of the click, in layer space
		 */
		public function onClick( localX:Number, localY:Number ):void
		{
			// here we can take the localX, localY click location and run through
			// any internal objects in the layer to see if we've clicked on them. you
			// can use this to select objects in your layer
			if ( this.m_ships == null )
				return;
				
			// NOTE: we're going to use hitTestPoint to test the position against
			// each ship. hitTestPoint works in stage coords, so we need to convert
			// our local position
			MapLayer.m_helperPoint.setTo( localX, localY );
			var p:Point = this.localToGlobal( MapLayer.m_helperPoint );
				
			// check against each ship
			for each( var ship:Ship in this.m_ships )
			{
				if ( ship.hitTestPoint( p.x, p.y, true ) )
				{
					this.signalOnSelectShip.dispatch( ship );
					return;
				}
			}
			
			// we didn't hit any ship, so just dispatch the point
			this.signalOnSelectPos.dispatch( localX, localY );
		}
		
		/**
		 * Adds a DisplayObject as a child of the layer
		 * @param child The DisplayObject to add
		 * @return The DisplayObject added
		 */
		override public function addChild( child:DisplayObject ):DisplayObject 
		{
			// if it's a ship, add it to our vector
			if ( child is Ship )
			{
				this.m_ships ||= new Vector.<Ship>;
				this.m_ships.push( ( child as Ship ) );
			}
			
			// add it as normal
			return super.addChild( child );
		}
		
	}

}