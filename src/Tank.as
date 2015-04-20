package 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Dylan Gallardo
	 */
	public class Tank extends MovieClip 
	{
		public var hitbox:Sprite;
		public var isClicked = false;
		public var health = 100;
		public var destroyed = false;
		private var playHitFadeIn = false;
		private var playHitFadeOut = false;
		private var maxHitAlpha = 0.4;
		public var yPos;
		
		public function Tank() 
		{
			yPos = y+height;
			var padding = 30;
			
			hitbox = new Sprite();
			hitbox.graphics.beginFill(0x333333,0); 
			hitbox.graphics.drawRect(x + padding, y + padding, width - (padding * 2), height - (padding * 2));     
			hitbox.graphics.endFill();
			
			addChild(hitbox);
			
			//tankHitOverlay.x = hitbox.x;
			//tankHitOverlay.y = hitbox.y;
			//tankHitOverlay.width = hitbox.width;
			//tankHitOverlay.height = hitbox.height;
			
			addEventListener(MouseEvent.CLICK, clickFunction, false, 0, false);
			addEventListener(Event.ENTER_FRAME, update, false, 0, false);
		}
		
		private function update(e:Event):void
		{
			yPos = y+(height/2+15);
			
			if (health <= 0)
			{
				destroyed = true;
			}
			
			if (playHitFadeIn)
			{
				tankHitOverlay.alpha = doLerp(tankHitOverlay.alpha, maxHitAlpha, 0.3);
				
				if (tankHitOverlay.alpha >= maxHitAlpha-0.1)
				{
					playHitFadeOut = true;
					playHitFadeIn = false;
				}
			}
			else if (playHitFadeOut)
			{
				tankHitOverlay.alpha = doLerp(tankHitOverlay.alpha, 0, 0.1);
				
				if (tankHitOverlay.alpha <= 0.1)
				{
					playHitFadeOut = false;
				}
			}
		}
		
		public function takeDamage():void
		{
			playHitFadeIn = true;
			playHitFadeOut = false;
			health -= 3.8;
		}
		
		private function clickFunction(e:MouseEvent):void
		{
			isClicked = true;
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