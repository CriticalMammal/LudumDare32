package
{
	import flash.display.MovieClip;
	import flash.events.Event;
	/**
	 * ...
	 * @author Dylan Gallardo
	 */
	public class Menu extends MovieClip
	{
		public var isOpen = false;
		private var fullWidth = 319.95;
		private var fullHeight = 241;
		private var fullX = 0;
		private var fullY = 0;
		private var shrinkX = 160;
		private var shrinkY = 250;
		
		public function Menu() 
		{
			fullWidth = width;
			fullHeight = height;
			width = 0;
			height = 0;
			x = shrinkX;
			y = shrinkY;
			visible = false;
		}
		
		public function popUp():void
		{
			removeEventListener(Event.ENTER_FRAME, shrink);
			addEventListener(Event.ENTER_FRAME, grow);
		}
		
		public function popOut():void
		{
			removeEventListener(Event.ENTER_FRAME, grow);
			addEventListener(Event.ENTER_FRAME, shrink);
		}
		
		private function 
		shrink(e:Event):void
		{
			isOpen = false;
			x = doLerp(x, shrinkX, 0.2);
			y = doLerp(y, shrinkY, 0.2);
			width = doLerp(width, 0, 0.2);
			height = doLerp(height, 0, 0.2);
			
			if (width <= 0 + 0.1 && height <= 0 + 0.1 &&
				x >= shrinkX-0.1 && y >= shrinkY-0.1)
			{
				visible = false;
				removeEventListener(Event.ENTER_FRAME, shrink);
			}
		}
		
		private function grow(e:Event):void
		{
			visible = true;
			isOpen = true;
			x = doLerp(x, fullX, 0.05);
			y = doLerp(y, fullY, 0.05);
			width = doLerp(width, fullWidth, 0.05);
			height = doLerp(height, fullHeight, 0.05);
			
			if (width >= fullWidth - 0.1 && height >= fullWidth - 0.1 &&
				x <= fullX+0.1 && y >= fullY+0.1)
			{
				removeEventListener(Event.ENTER_FRAME, grow);
			}
		}
		
		// current speed, goal speed, amount of lerp
		function doLerp(value:Number, goal:Number, lerpSpeed:Number):Number
		{
			var lerpValue:Number = 0.0;

			// Update
			if (value != goal)
			{
				lerpValue = 0.0;
			}

			if (lerpValue < 1.0)
			{
				lerpValue += lerpSpeed;
			}

			var newVal:Number = lerp(value, lerpValue, goal);
			value = newVal;
			return value;
		}
			
		private function lerp(x:Number, t:Number, y:Number):Number
		{
			return x * (1-t) + y*t;
		}
	}

}