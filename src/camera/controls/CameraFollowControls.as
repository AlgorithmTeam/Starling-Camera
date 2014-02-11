package camera.controls 
{
	import camera.Camera;
	import camera.enums.CameraFollowEaseType;
	import camera.enums.CameraFollowOffsetType;
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.geom.Point;
	import math.MathHelper;
	
	/**
	 * Controls a camera by following an object
	 * @author Damian Connolly
	 */
	public class CameraFollowControls extends CameraControls 
	{
		
		/*******************************************************************************************/
		
		/**
		 * The ease type to use when following our object
		 */
		public var followEaseType:CameraFollowEaseType = CameraFollowEaseType.NONE;
		
		/**
		 * The offset type to use when applying our follow offset
		 */
		public var followOffsetType:CameraFollowOffsetType = CameraFollowOffsetType.NONE;
		
		/**
		 * The follow factor to add some smoothing between the camera position and the target
		 * position. If we're lerping, then from 0.0 to 1.0 is loose to tight. If damping, then 
		 * 0.0 to 1.0 is tight to loose. Generally this number is between 0.0 and 1.0, but with
		 * damping, you can experiment with other values
		 */
		public var followFactor:Number = 0.5;
		
		/*******************************************************************************************/
		
		private var m_followObj:DisplayObject	= null;	// the object that we're following
		private var m_offset:Point 				= null; // the offset point for where we're following
		private var m_rotatedOffset:Point		= null;	// the rotated offset point, if we're using rotation
		private var m_prevCameraPos:Point		= null;	// the previous camera position
		private var m_prevObjPos:Point			= null;	// the previous follow object position
		
		/*******************************************************************************************/
		
		/**
		 * The object that we're following
		 */
		[Inline] public final function get followObj():DisplayObject { return this.m_followObj; }
		[Inline] public final function set followObj( d:DisplayObject ):void
		{
			this.m_followObj = d;
			if ( this.m_followObj != null )
				this.m_prevObjPos.setTo( this.m_followObj.x, this.m_followObj.y );
		}
		
		/*******************************************************************************************/
		
		/**
		 * Creates a new CameraFollowControls object
		 * @param camera The camera that we're controlling
		 * @param stage The main stage
		 * @param followObj The object that we're following
		 */
		public function CameraFollowControls( camera:Camera, stage:Stage, followObj:DisplayObject = null ) 
		{
			super( camera, stage );
			this.m_offset			= new Point; // anchor point
			this.m_rotatedOffset	= new Point; // if we're using rotation
			this.m_prevCameraPos	= new Point;
			this.m_prevObjPos		= new Point;
			this.followObj 			= followObj; // NOTE: use the setter
		}
		
		/**
		 * Destroys the CameraFollowControls and clears it for garbage collection
		 */
		override public function destroy():void 
		{
			super.destroy();
			this.followEaseType		= null;
			this.followOffsetType	= null;
			this.m_followObj		= null;
			this.m_offset			= null;
			this.m_rotatedOffset	= null;
			this.m_prevCameraPos	= null;
			this.m_prevObjPos		= null;
		}
		
		/**
		 * Sets the offset point, or the offset that we'll apply when following our object
		 * @param ox The offset x position
		 * @param oy The offset y position
		 * @param offsetType The CameraFollowOffsetType to use when applying this. If null, then
		 * CameraFollowOffsetType.NONE is used
		 */
		public function setOffsetPoint( ox:Number, oy:Number, offsetType:CameraFollowOffsetType = null ):void
		{
			this.m_offset.setTo( ox, oy );
			this.followOffsetType = ( offsetType == null ) ? CameraFollowOffsetType.NONE : offsetType;
		}
		
		/**
		 * Updates the CameraFollowControls every frame it's active
		 * @param dt The delta time since the last call to update
		 */
		override public function update( dt:Number ):void 
		{
			// if we don't have a follow object, do nothing
			if ( this.m_followObj == null )
				return;
				
			// get our camera position based on our object and offset
			// NOTE: we're not using global position as the camera will probably move the layer that the object
			// is on, so it'll get screwed up
			var tx:Number = this.m_followObj.x;
			var ty:Number = this.m_followObj.y;
			
			// apply our offset type
			if ( this.followOffsetType == CameraFollowOffsetType.NONE )
			{
				// just add the offset
				tx += this.m_offset.x;
				ty += this.m_offset.y;
			}
			else if ( this.followOffsetType == CameraFollowOffsetType.OBJ_ROTATION )
			{
				// our offset is based on our object's rotation
				MathHelper.rotate( this.m_offset, MathHelper.degreesToRadians( this.m_followObj.rotation ), this.m_rotatedOffset );
				tx += this.m_rotatedOffset.x;
				ty += this.m_rotatedOffset.y;
			}
			else // CameraFollowOffsetType.OBJ_POS_DELTA
			{
				// rotate our offset 
				var radians:Number = MathHelper.radianAngle( this.followObj.x - this.m_prevObjPos.x, this.followObj.y - this.m_prevObjPos.y );
				MathHelper.rotate( this.m_offset, radians, this.m_rotatedOffset );
				
				// multiply our offset by our delta position
				var posDelta:Number = MathHelper.dist( this.m_prevObjPos.x, this.m_prevObjPos.y, this.followObj.x, this.followObj.y );
				tx 					+= this.m_rotatedOffset.x * posDelta;
				ty 					+= this.m_rotatedOffset.y * posDelta;
			}
			
			// interpolate to the position. NOTE: CameraFollowEaseType.NONE is already taken
			// care of 
			if ( this.followEaseType == CameraFollowEaseType.DAMP )
			{
				tx = MathHelper.damp( this.m_camera.cameraX, tx, dt, this.followFactor, 1.0 );
				ty = MathHelper.damp( this.m_camera.cameraY, ty, dt, this.followFactor, 1.0 );
			}
			else if ( this.followEaseType == CameraFollowEaseType.LERP )
			{
				tx = MathHelper.lerp( this.m_camera.cameraX, tx, this.followFactor );
				ty = MathHelper.lerp( this.m_camera.cameraY, ty, this.followFactor );
			}
			
			// move the camera (only if we've moved)
			if ( this.m_prevCameraPos.x != tx || this.m_prevCameraPos.y != ty )
			{
				this.m_camera.moveCameraTo( tx, ty );
				this.m_prevCameraPos.setTo( tx, ty );
			}
			
			// update our previous object position
			this.m_prevObjPos.setTo( this.m_followObj.x, this.m_followObj.y );
		}
		
	}

}