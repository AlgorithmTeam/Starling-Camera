package  
{
	import flash.display.Sprite;
	import math.MathHelper;
	
	[SWF(width=240, height=140, backgroundColor=0xffffff)]
	public class MainLerpDamp extends Sprite
	{
		
		public function MainLerpDamp() 
		{
			this.graphics.lineStyle( 2.0, 0 );
			
			// graph outline
			this.graphics.moveTo( 20.0, 20.0 );
			this.graphics.lineTo( 20.0, this.stage.stageHeight - 15.0 );
			this.graphics.moveTo( 15.0, this.stage.stageHeight - 20.0 );
			this.graphics.lineTo( this.stage.stageWidth - 20.0, this.stage.stageHeight - 20.0 );
			
			// ticks
			for ( var i:int = 0; i <= 10; i++ )
			{
				this.graphics.moveTo( 20 + 20 * i, this.stage.stageHeight - 20.0 );
				this.graphics.lineTo( 20 + 20 * i, this.stage.stageHeight - 15.0 );
			}
			
			// set up some vars
			var start:Number 		= 0.0;
			var end:Number			= 1.0;
			var factor:Number		= 0.1; // 0.1 as we're looping 10 times, going from 0.0 to 1.0, so 1.0 / 10
			var dt:Number			= 1.0 / 2.0; // delta time - used for damping - modify to see the effects
			var showLerp:Boolean	= true;
			var showDamp:Boolean	= false;
			
			// lerp
			if ( showLerp )
			{
				this.graphics.lineStyle( 1.0, 0xff0000 );
				this.graphics.beginFill( 0xff0000 );
				for ( i = 0; i <= 10; i++ )
				{
					// with lerp, 0.0 = source, 1.0 = dest for the factor
					var n:Number = MathHelper.lerp( start, end, ( factor * i ) );
					this.graphics.drawCircle( 20 + 200 * n, this.stage.stageHeight - 20 - ( 10 * i ), 2.0 + i * 0.25 );
				}
			}
			
			// damp
			if ( showDamp )
			{
				this.graphics.lineStyle( 2.0, 0x0000ff );
				this.graphics.beginFill( 0x0000ff );
				for ( i = 0; i <= 10; i++ )
				{
					// with damping, the factor is reversed, so 0.0 = dest, 1.0 = source
					n = MathHelper.damp( start, end, dt, ( factor * i ), 0.0 );
					this.graphics.drawCircle( 20 + 200 * n, this.stage.stageHeight - 20 - ( 10 * i ), 2.0 + i * 0.25 );
				}
			}
		}
		
	}

}