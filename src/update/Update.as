package update 
{
	import flash.utils.getTimer;

    import starling.display.Stage;
    import starling.events.Event;

    /**
	 * Our update class, which calls update() on all registered objects
	 * @author Damian Connolly
	 */
	public class Update 
	{
		
		/*******************************************************************************************/
		
		private var m_prevTime:int 				= 0;	// our previous time
		private var m_objs:Vector.<IUpdateObj>	= null;	// the list of objects that we're updating
		
		/*******************************************************************************************/
		
		/**
		 * Creates a new Update object
		 * @param stage The main stage
		 */
		public function Update( stage:Stage ) 
		{
			this.m_objs 	= new Vector.<IUpdateObj>;
			this.m_prevTime	= getTimer();
			stage.addEventListener( Event.ENTER_FRAME, this._onEnterFrame );
		}
		
		/**
		 * Adds an object to the update
		 * @param obj The object to add
		 */
		public function add( obj:IUpdateObj ):void
		{
			this.m_objs.push( obj );
		}
		
		/**
		 * Removes an object from the update
		 * @param obj The object to remove
		 */
		public function remove( obj:IUpdateObj ):void
		{
			// NOTE: this should really handle removing an object in the middle
			// of an update, but it's good enough for this demo
			var index:int = this.m_objs.indexOf( obj );
			if ( index != -1 )
				this.m_objs.splice( index, 1 );
		}
		
		/*******************************************************************************************/
		
		// called every frame
		private function _onEnterFrame( e:Event ):void
		{
			// get our delta time
			var currTime:int 	= getTimer();
			var deltaTime:int	= currTime - this.m_prevTime;
			this.m_prevTime		= currTime;
			var dt:Number		= deltaTime * 0.001; // deltaTime is in millis, so convert to seconds
			
			// update all our objects
			for each( var obj:IUpdateObj in this.m_objs )
			{
				if ( obj.active )
					obj.update( dt );
			}
		}
		
	}

}