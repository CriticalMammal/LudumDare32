package 
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Dylan Gallardo
	 */
	public class Tank extends MovieClip 
	{
		public var isClicked = false;
		
		public function Tank() 
		{
			addEventListener(MouseEvent.CLICK, clickFunction, false, 0, false);
		}
		
		private function clickFunction(e:MouseEvent):void
		{
			isClicked = true;
		}
	}

}