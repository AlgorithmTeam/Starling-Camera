package camera 
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import math.Bounds;

    import starling.display.DisplayObject;

    import update.IUpdateObj;
	
	/**
	 * A camera that we can use to move around our game
	 * @author Damian Connolly
	 */
	public class Camera implements IUpdateObj
	{
		
		/*******************************************************************************************/
		
		/**
		 * The max move velocity that we can have
		 */
		public var maxMoveVel:Number = 50.0;
		
		/**
		 * The max zoom velocity that we can have
		 */
		public var maxZoomVel:Number = 0.5;
		
		/**
		 * Should we snap to the nearest pixel when moving our objects?
		 */
		public var shouldPixelSnap:Boolean = true;
		
		/**
		 * How much to decelerate the move velocity by, every frame
		 */
		public var moveVelDecel:Number = 0.9;
		
		/**
		 * How much to decelerate the zoom velocity by, every frame
		 */
		public var zoomVelDecel:Number = 0.8;
		
		/**
		 * The cutoff for the move velocity, before we set it to 0.0
		 */
		public var moveVelCutoff:Number	= 1.0;
		
		/**
		 * The cutoff for the zoom velocity, before we set it to 0.0
		 */
		private var zoomVelCutoff:Number = 0.05;
		
		/*******************************************************************************************/
		
		private var m_displayRect:Rectangle				= null; // our display rect; x, y, width and height
		private var m_viewRect:Rectangle				= null;	// our view rect, in layer coords (used for child visibility)
		private var m_viewPoint:Point					= null;	// a helper point, when calculating the view rect
		private var m_clickPoint:Point					= null; // a helper point, when clicking the layers
		private var m_layers:Vector.<CameraLayerRef>	= null;	// the references to the layers that we're rendering
		private var m_bounds:Rectangle					= null;	// the bounds for the camera
		private var m_cameraPos:Point					= null;	// the camera center position
		private var m_moveVel:Point						= null;	// the camera velocity
		private var m_isActive:Boolean					= false;// is the camera active?
		private var m_currZoom:Number					= 1.0;	// our current zoom
		private var m_currZoomLog:Number				= 0.0;	// our current zoom (in our log scale)
		private var m_zoomBoundsLog:Bounds				= null;	// our bounds for our zoom (in our log scale)
		private var m_zoomVel:Number					= 0.0;	// our zoom velocity
		
		/*******************************************************************************************/
		
		/**
		 * Returns true if the camera is active
		 */
		[Inline] public final function get active():Boolean { return true; }
		
		/**
		 * The camera's display x position
		 */
		[Inline] public final function get x():Number { return this.m_displayRect.x; }
		[Inline] public final function set x( n:Number ):void
		{
			this.m_displayRect.x 	= n;
			this.m_isActive			= true;
		}
		
		/**
		 * The camera's display y position
		 */
		[Inline] public final function get y():Number { return this.m_displayRect.y; }
		[Inline] public final function set y( n:Number ):void
		{
			this.m_displayRect.y 	= n;
			this.m_isActive			= true;
		}
		
		/**
		 * The camera's display width
		 */
		[Inline] public final function get width():Number { return this.m_displayRect.width; }
		[Inline] public final function set width( n:Number ):void
		{
			this.m_displayRect.width 	= ( n < 0.0 ) ? 0.0 : n;
			this.m_isActive				= true;
		}
		
		/**
		 * The camera's display height
		 */
		[Inline] public final function get height():Number { return this.m_displayRect.height; }
		[Inline] public final function set height( n:Number ):void
		{
			this.m_displayRect.height 	= ( n < 0.0 ) ? 0.0 : n;
			this.m_isActive				= true;
		}
		
		/**
		 * The camera's center x position
		 */
		[Inline] public final function get cameraX():Number { return this.m_cameraPos.x; }
		[Inline] public final function set cameraX( n:Number ):void
		{
			this.m_cameraPos.x	= n;
			this.m_isActive		= true;
			
			// stop our camera so we don't keep moving
			this.stop();
		}
		
		/**
		 * The camera's center y position
		 */
		[Inline] public final function get cameraY():Number { return this.m_cameraPos.y; }
		[Inline] public final function set cameraY( n:Number ):void
		{
			this.m_cameraPos.y 	= n;
			this.m_isActive		= true;
			
			// stop our camera so we don't keep moving
			this.stop();
		}
		
		/**
		 * The current zoom level of the camera
		 */
		[Inline] public final function get zoom():Number { return this.m_currZoom; }
		[Inline] public final function set zoom( n:Number ):void
		{
			var logN:Number		= Math.log( ( n < 0.1 ) ? 0.1 : n );
			this.m_currZoomLog	= ( logN < this.m_zoomBoundsLog.min ) ? this.m_zoomBoundsLog.min : ( logN > this.m_zoomBoundsLog.max ) ? this.m_zoomBoundsLog.max : logN;
			this.m_currZoom		= Math.exp( this.m_currZoomLog );
			this.m_isActive		= true;
			
			// kill our velocity so we don't keep zooming
			this.m_zoomVel = 0.0;
		}
		
		/**
		 * The min zoom level of the camera. When set, this will clamp to maxZoom if high enough
		 */
		[Inline] public final function get minZoom():Number { return Math.exp( this.m_zoomBoundsLog.min ); }
		[Inline] public final function set minZoom( n:Number ):void
		{
			this.m_zoomBoundsLog.min	= Math.log( ( n < 0.1 ) ? 0.1 : n );
			this.m_isActive				= true;
		}
		
		/**
		 * The max zoom level of the camera. When set, this will clamp to the minZoom if low enough
		 */
		[Inline] public final function get maxZoom():Number { return Math.exp( this.m_zoomBoundsLog.max ); }
		[Inline] public final function set maxZoom( n:Number ):void
		{
			this.m_zoomBoundsLog.max	= Math.log( n );
			this.m_isActive				= true;
		}
		
		/*******************************************************************************************/
		
		/**
		 * Creates a new Camera
		 * @param width The camera's display width
		 * @param height The camera's display height
		 */
		public function Camera( width:Number, height:Number ) 
		{
			// create our objects
			this.m_displayRect 		= new Rectangle;
			this.m_viewRect			= new Rectangle;
			this.m_viewPoint		= new Point;
			this.m_clickPoint		= new Point;
			this.m_bounds			= new Rectangle;
			this.m_cameraPos		= new Point;
			this.m_moveVel			= new Point;
			this.m_layers			= new Vector.<CameraLayerRef>;
			this.m_zoomBoundsLog	= new Bounds( Math.log( 0.1 ), Math.log( 10.0 ) );
			this.m_currZoomLog		= Math.log( this.m_currZoom );
			
			// set our display width and height
			this.width 	= width;
			this.height	= height;
		}
		
		/**
		 * Destroys the Camera and clears it for garbage collection
		 */
		public function destroy():void
		{
			// update - NOTE: it still needs to be removed from the Update class
			this.m_isActive = false;
			
			// clear our vector
			for each( var ref:CameraLayerRef in this.m_layers )
				ref.destroy();
			this.m_layers.length = 0;
			
			// null our properties
			this.m_bounds			= null;
			this.m_cameraPos		= null;
			this.m_moveVel			= null;
			this.m_displayRect		= null;
			this.m_viewRect			= null;
			this.m_viewPoint		= null;
			this.m_clickPoint		= null;
			this.m_layers			= null;
			this.m_zoomBoundsLog	= null;
		}
		
		/**
		 * Adds a layer to be controlled by the camera
		 * @param layer The ICameraLayer that we want the camera to control
		 * @param speedFactor The speed factor for this object (e.g. for implementing parallax)
		 * @param offset The offset for this ICameraLayer; used in the final positioning. If null, then
		 * no offset is used, and when the cameraX/camerY is 0, the (0,0) of the ICameraLayer will correspond
		 * with the center of the camera
		 */
		public function addLayerToControl( layer:ICameraLayer, speedFactor:Number = 1.0, offset:Point = null ):void
		{
			var ref:CameraLayerRef 	= new CameraLayerRef( layer );
			ref.speedFactor			= speedFactor;
			ref.origScale.x			= layer.scaleX;
			ref.origScale.y			= layer.scaleY;
			if ( offset != null )
				ref.offset = offset;
			this.m_layers.push( ref );
			this.m_isActive = true;
		}
		
		/**
		 * Removes a layer from the camera's control
		 * @param layer The ICameraLayer to remove from our camera
		 */
		public function removeLayerFromControl( layer:ICameraLayer ):void
		{
			for ( var i:int = this.m_layers.length - 1; i >= 0; i-- )
			{
				if ( this.m_layers[i].layer == layer )
				{
					this.m_layers[i].destroy();
					this.m_layers.splice( i, 1 );
					
					// if this is the last object, kill our velocity
					if ( this.m_layers.length == 0 )
						this.stop();
						
					// activate to update
					this.m_isActive = true;
					return;
				}
			}
			trace( "[Camera] Can't remove " + layer + " from the camera, as we're not controlling it" );
		}
		
		/**
		 * Sets the offset for one of the layers under the camera's control. This offset
		 * will be used when positioning the layer
		 * @param layer The ICameraLayer under the camera's control
		 * @param offset The offset for this layer
		 */
		public function setLayerOffset( layer:ICameraLayer, offset:Point ):void
		{
			// set the offset on the right objects
			for each( var ref:CameraLayerRef in this.m_layers )
			{
				if ( ref.layer == layer )
				{
					ref.offset 		= offset;
					this.m_isActive	= true;
					return;
				}
			}
			
			// we don't have it
			trace( "[Camera] Can't set the offset for " + layer + ", as we're not controlling it" );
		}
		
		/**
		 * Moves the camera center position to a specific position
		 * @param x The x position to move to
		 * @param y The y position to move to
		 */
		public function moveCameraTo( x:Number, y:Number ):void
		{
			this.cameraX = x;
			this.cameraY = y;
		}
		
		/**
		 * Moves the camera center position by a specific amount
		 * @param x The x amount to move by
		 * @param y The y amount to move by
		 */
		public function moveCameraBy( x:Number, y:Number ):void
		{
			this.cameraX += x;
			this.cameraY += y;
		}
		
		/**
		 * Sets the move velocity of the camera to a specific amount
		 * @param x The camera move x velocity
		 * @param y The camera move y velocity
		 */
		public function setMoveVelocityTo( x:Number, y:Number ):void
		{
			// set it and clamp if necessary
			this.m_moveVel.setTo( x, y );
			if ( this.m_moveVel.length > this.maxMoveVel )
				this.m_moveVel.normalize( this.maxMoveVel );
			this.m_isActive = true;
		}
		
		/**
		 * Sets the camera move velocity by a specific amount
		 * @param x The camera move x velocity difference
		 * @param y The camera move y velocity difference
		 */
		public function setMoveVelocityBy( x:Number, y:Number ):void
		{
			this.setMoveVelocityTo( this.m_moveVel.x + x, this.m_moveVel.y + y );
		}
		
		/**
		 * Sets the camera zoom using a logarithmic scale - this will give smoother results
		 * than just setting the zoom directly
		 * @param n The amount that we want to zoom the camera by
		 */
		public function zoomCameraLogarithmicallyBy( n:Number ):void
		{				
			// set our current log zoom, clear our zoom velocity and set that we're active
			this.m_currZoomLog += n;
			this.m_zoomVel		= 0.0; // no velocity
			this.m_isActive		= true;
		}
		
		/**
		 * Sets the camera zoom velocity to a specific amount
		 * @param n The camera zoom velocity
		 */
		public function setZoomVelocityTo( n:Number ):void
		{
			this.m_zoomVel 	= ( n < -this.maxZoomVel ) ? -this.maxZoomVel : ( n > this.maxZoomVel ) ? this.maxZoomVel : n;
			this.m_isActive	= true;
		}
		
		/**
		 * Set the camera zoom velocity by a specific amount
		 * @param n The camera zoom velocity difference
		 */
		public function setZoomVelocityBy( n:Number ):void
		{
			this.setZoomVelocityTo( this.m_zoomVel + n );
		}
		
		/**
		 * Stops the camera from moving and zooming
		 */
		public function stop():void
		{
			// NOTE: don't set active to false as we might have been stopped because we set the
			// camera position directly, and we still need it to update
			// NOTE: don't kill the zoomVel as stop() is called by the cameraX/cameraY setters,
			// which are used in some controllers (moveTo()), such as the follow controller. If
			// we zero out the zoomVel, then we won't be able to zoom while the camera is
			// tracking an object
			this.m_moveVel.setTo( 0.0, 0.0 );
		}
		
		/**
		 * Sets the bounds for the camera
		 * @param x The x bounds for the camera
		 * @param y The y bounds for the camera
		 * @param w The width for the bounds
		 * @param h The height for the bounds
		 */
		public function setBounds( x:Number, y:Number, w:Number, h:Number ):void
		{
			// make sure our width and height are good
			w = ( w < 0 ) ? 0 : w;
			h = ( h < 0 ) ? 0 : h;
			
			// set our bounds
			this.m_bounds.setTo( x, y, w, h );
			this.m_isActive = true;
		}
		
		/**
		 * Goes through and clicks each of the layers that we control
		 * @param stageX The x position of the click, in global space
		 * @param stageY The y position of the click, in global space
		 */
		public function onClick( stageX:Number, stageY:Number ):void
		{
			// stop the camera from moving
			this.stop();
			
			// notify our layers
			this.m_clickPoint.x	= stageX;
			this.m_clickPoint.y	= stageY;
			for each( var ref:CameraLayerRef in this.m_layers )
			{
				var localPos:Point = ref.layer.globalToLocal( this.m_clickPoint );
				ref.layer.onClick( localPos.x, localPos.y );
			}
		}
		
		/**
		 * Updates the Camera so that we render our view objects etc
		 * @param dt The delta time since the last update
		 */
		public function update( dt:Number ):void
		{
			// only update the camera position etc if we're active
			if ( this.m_isActive )
			{	
				// update our zoom based on our vel and clamp it.
				// NOTE: as scale is logarithmic, we're using Math.log() and Math.exp()
				// to get the final value
				this.m_currZoomLog += this.m_zoomVel;
				if ( this.m_currZoomLog < this.m_zoomBoundsLog.min )
				{
					this.m_currZoomLog 	= this.m_zoomBoundsLog.min;
					this.m_zoomVel		= 0.0;
				}
				else if ( this.m_currZoomLog > this.m_zoomBoundsLog.max )
				{
					this.m_currZoomLog	= this.m_zoomBoundsLog.max;
					this.m_zoomVel		= 0.0;
				}
				this.m_currZoom = Math.exp( this.m_currZoomLog );
				
				// update our position
				this.m_cameraPos.x += this.m_moveVel.x;
				this.m_cameraPos.y += this.m_moveVel.y;
				
				// clamp it to our bounds
				if ( this.m_bounds.width > 0 || this.m_bounds.height > 0 )
				{
					var invZoom:Number	= ( this.m_currZoom == 0.0 ) ? 1.0 : 1.0 / this.m_currZoom;
					var hw:Number 		= this.m_displayRect.width * 0.5 * invZoom;
					var hh:Number 		= this.m_displayRect.height * 0.5 * invZoom;
					
					// horizontal
					if ( this.m_cameraPos.x < this.m_bounds.x + hw )
					{
						this.m_cameraPos.x 	= this.m_bounds.x + hw;
						this.m_moveVel.x	= 0.0; // stop moving
					}
					else if ( this.m_cameraPos.x > this.m_bounds.x + this.m_bounds.width - hw )
					{
						this.m_cameraPos.x 	= this.m_bounds.x + this.m_bounds.width - hw;
						this.m_moveVel.x	= 0.0; // stop moving
					}
						
					// vertical
					if ( this.m_cameraPos.y < this.m_bounds.y + hh )
					{
						this.m_cameraPos.y 	= this.m_bounds.y + hh;
						this.m_moveVel.y	= 0.0; // stop moving
					}
					else if ( this.m_cameraPos.y > this.m_bounds.y + this.m_bounds.height - hh )
					{
						this.m_cameraPos.y 	= this.m_bounds.y + this.m_bounds.height - hh;
						this.m_moveVel.y	= 0.0; // stop moving
					}
				}
				
				// update all our controlled objects
				for each( var ref:CameraLayerRef in this.m_layers )
				{
					// update the zoom
					var zoom:Number		= ( ref.layer.isZoomEnabled ) ? this.m_currZoom : 1.0;
					var scaleX:Number 	= zoom * ref.origScale.x;
					var scaleY:Number 	= zoom * ref.origScale.y;
					if ( ref.layer.isZoomEnabled && ( ref.layer.scaleX != scaleX || ref.layer.scaleY != scaleY ) )
					{
						ref.layer.scaleX = scaleX;
						ref.layer.scaleY = scaleY;
					}
						
					// NOTE: the camera position is inversed, because, as the camera moves right, the object should move left
					var x:Number 	= this.m_displayRect.x + ( this.m_displayRect.width * 0.5 ) - ( this.m_cameraPos.x * ref.speedFactor * scaleX ) + ( ref.offset.x * scaleX );
					var y:Number 	= this.m_displayRect.y + ( this.m_displayRect.height * 0.5 ) - ( this.m_cameraPos.y * ref.speedFactor * scaleY ) + ( ref.offset.y * scaleY );
					ref.layer.x		= ( this.shouldPixelSnap ) ? Math.round( x ) : x;
					ref.layer.y		= ( this.shouldPixelSnap ) ? Math.round( y ) : y;
				}
				
				// slow down
				this.m_moveVel.x 	*= this.moveVelDecel;
				this.m_moveVel.y 	*= this.moveVelDecel;
				this.m_zoomVel		*= this.zoomVelDecel;
				if ( this.m_moveVel.x < this.moveVelCutoff && this.m_moveVel.x > -this.moveVelCutoff )
					this.m_moveVel.x = 0.0;
				if ( this.m_moveVel.y < this.moveVelCutoff && this.m_moveVel.y > -this.moveVelCutoff )
					this.m_moveVel.y = 0.0;
				if ( this.m_zoomVel < this.zoomVelCutoff && this.m_zoomVel >- this.zoomVelCutoff )
					this.m_zoomVel = 0.0;
			}
			
			// we need to update the children visibility and sort on our layers every frame, as even if
			// we're not moving, they could be
			this.m_viewPoint.x 	= this.m_displayRect.x;
			this.m_viewPoint.y 	= this.m_displayRect.y;
			for each( ref in this.m_layers )
			{
				// get our view rect in local space
				var localPos:Point	= ref.layer.globalToLocal( this.m_viewPoint );
				this.m_viewRect.x	= localPos.x;
				this.m_viewRect.y	= localPos.y;
				
				// get our view rect size
				var invScaleX:Number 	= ( this.m_currZoom == 0.0 || ref.origScale.x == 0.0 ) ? 1.0 : 1.0 / ( this.m_currZoom * ref.origScale.x );
				var invScaleY:Number	= ( this.m_currZoom == 0.0 || ref.origScale.y == 0.0 ) ? 1.0 : 1.0 / ( this.m_currZoom * ref.origScale.y );
				this.m_viewRect.width	= this.m_displayRect.width * invScaleX;
				this.m_viewRect.height	= this.m_displayRect.height * invScaleY;
				
				// update children visibility
				ref.layer.checkChildrenVisibility( this.m_viewRect );
				
				// sort them
				ref.layer.sortChildren( this._sortChildren );
			}
				
			// if our velocity is zero, stop update
			if ( this.m_moveVel.x == 0.0 && this.m_moveVel.y == 0.0 && this.m_zoomVel == 0.0 )
				this.m_isActive = false;
		}
		
		/*******************************************************************************************/
		
		// the function we use to sort all the children in a layer
		private function _sortChildren( a:DisplayObject, b:DisplayObject ):int
		{
			return ( ( a.x + a.y ) < ( b.x + b.y ) ) ? -1 : 1;
		}
		
	}

}