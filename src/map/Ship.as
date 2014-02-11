package map 
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	import math.MathHelper;
	import update.IUpdateObj;
	
	/**
	 * A ship that we can use to fly around
	 * @author Damian Connolly
	 */
	public class Ship extends Sprite implements IUpdateObj
	{
		
		/*******************************************************************************************/
		
		private var m_flame:Shape 				= null; // the flame behind our ship, when we move
		private var m_isFlameScalingUp:Boolean	= false;// is our flame scaling up?
		private var m_destPoint:Point			= null;	// the destination point to move to, if we have one
		private var m_dir:Point					= null;	// the direction that we're headed
		private var m_speed:Number				= 0.0;	// the speed for our ship
		
		/*******************************************************************************************/
		
		/**
		 * The ship is active if we've a destination
		 */
		public function get active():Boolean { return ( this.m_destPoint != null && this.m_destPoint.length != 0.0 ) || this.m_flame.visible }
		
		/**
		 * The speed of the ship
		 */
		public function get speed():Number { return this.m_speed; }
		
		/*******************************************************************************************/
		
		/**
		 * Creates a new Ship
		 */
		public function Ship() 
		{
			this.m_flame		= new Shape;
			this.m_destPoint 	= new Point;
			this.m_dir			= new Point;
			this.m_speed		= 100.0;
			this._draw();
		}
		
		/**
		 * Destroys the Ship and clears it for garbage collection
		 */
		public function destroy():void
		{
			// graphics
			if ( this.parent != null )
				this.parent.removeChild( this );
			this.removeChildren();
			
			// null our properties
			this.m_destPoint	= null;
			this.m_dir			= null;
			this.m_flame		= null;
		}
		
		/**
		 * Moves to a specific position
		 * @param x The x position that we want to move to
		 * @param y The y position that we want to move to
		 */
		public function moveTo( x:Number, y:Number ):void
		{
			this.m_destPoint.setTo( x, y );
		}
		
		/**
		 * Called when the ship is active - move to our destination point
		 * @param dt The delta time since the last update
		 */
		public function update( dt:Number ):void
		{
			// hide our flame if we're not moving
			if ( this.m_destPoint.x == 0.0 && this.m_destPoint.y == 0.0 && this.m_flame.visible )
			{
				this.m_flame.visible = false;
				return;
			}
				
			// get the delta that we want to move 
			var dx:Number = ( this.m_destPoint.x - this.x );
			var dy:Number = ( this.m_destPoint.y - this.y );
			
			// get how much we're going to move
			this.m_dir.setTo( dx, dy );
			var len:Number = this.m_dir.length; // the total length we have to move
			this.m_dir.normalize( 1.0 );
			var mx:Number = this.m_dir.x * this.m_speed * dt;
			var my:Number = this.m_dir.y * this.m_speed * dt;
			
			// if we're close enough, just set it and clear, otherwise move as much as we can
			if ( len < this.m_speed * dt ) // NOTE: dir after normalising is 1.0, so our move length is just speed * dt here
			{
				this.x = this.m_destPoint.x;
				this.y = this.m_destPoint.y;
				this.m_destPoint.setTo( 0.0, 0.0 );
			}
			else
			{
				this.x += mx;
				this.y += my;
				
				// show our flame
				this.m_flame.visible = true;
				
				// animate it a bit
				if ( this.m_isFlameScalingUp )
				{
					this.m_flame.scaleX += dt * 4.0;
					this.m_flame.scaleY = this.m_flame.scaleX;
					if ( this.m_flame.scaleX >= 1.2 )
						this.m_isFlameScalingUp = false;
				}
				else
				{
					this.m_flame.scaleX -= dt * 4.0;
					this.m_flame.scaleY = this.m_flame.scaleX;
					if ( this.m_flame.scaleX <= 1.0 )
						this.m_isFlameScalingUp = true;
				}
			}
			
			// orient towards the destination
			this.rotation = MathHelper.radiansToDegrees( MathHelper.radianAngle( this.m_dir.x, this.m_dir.y ) );
		}
		
		/*******************************************************************************************/
		
		// draws our ship
		private function _draw():void
		{
			// draw our body
			var hw:Number = 7.5;
			var hl:Number = 10.0;
			this.graphics.lineStyle( 2.0, 0x009900 );
			this.graphics.beginFill( 0x00ff00 );
			this.graphics.moveTo( -hl, -hw );
			this.graphics.lineTo( hl, 0.0 );
			this.graphics.lineTo( -hl, hw );
			this.graphics.lineTo( -hl, -hw );
			
			// draw our flame (circle)
			this.m_flame.graphics.beginFill( 0xff7f00 );
			this.m_flame.graphics.drawCircle( 0.0, 0.0, hw - 2.0 );
			this.m_flame.graphics.endFill();
			
			// draw our flame (point)
			this.m_flame.graphics.beginFill( 0xff7f00 );
			this.m_flame.graphics.moveTo( 0.0, -hw + 3.0 );
			this.m_flame.graphics.lineTo( 0.0, hw - 3.0 );
			this.m_flame.graphics.lineTo( -hw * 2.0, 0.0 );
			this.m_flame.graphics.lineTo( 0.0, -hw + 3.0 );
			this.m_flame.graphics.endFill();
			
			// position and add the flame
			this.m_flame.visible 	= false; // hide at the start
			this.m_flame.x			= -hl;
			this.addChild( this.m_flame );
		}
		
	}

}