package 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Dylan Gallardo
	 */
	public class EmotionControl extends MovieClip 
	{
		public var powerLevel:int = 0; // 0 is neutral
		
		public function EmotionControl() 
		{
			// make all the buttons invisible initially
			powerDown2.visible = false;
			powerDown1.visible = false;
			powerDown0.visible = false;
			powerUp0.visible = false;
			powerUp1.visible = false;
			powerUp2.visible = false;
			
			// event listeners
			increaseButton.addEventListener(MouseEvent.CLICK, increaseClick);
			decreaseButton.addEventListener(MouseEvent.CLICK, decreaseClick);
		}
		
		private function increaseClick(e:MouseEvent):void
		{
			powerLevel ++;
			if (powerLevel > 3)
			{
				powerLevel = 3;
			}
			
			if (powerLevel > 0)
			{
				if (powerLevel == 3)
				{
					powerUp2.visible = true;
					powerUp1.visible = true;
					powerUp0.visible = true;
				}
				else if (powerLevel == 2)
				{
					powerUp1.visible = true;
					powerUp0.visible = true;
				}
				else
				{
					powerUp0.visible = true;
				}
			}
			else if (powerLevel < 0)
			{
				if (powerLevel == -2)
				{
					powerDown2.visible = false;
					powerDown1.visible = true;
					powerDown0.visible = true;
				}
				else
				{
					powerDown2.visible = false;
					powerDown1.visible = false;
					powerDown0.visible = true;
				}
			}
			else
			{
				powerDown2.visible = false;
				powerDown1.visible = false;
				powerDown0.visible = false;
				powerUp0.visible = false;
				powerUp1.visible = false;
				powerUp2.visible = false;
			}
		}
		
		private function decreaseClick(e:MouseEvent):void
		{
			powerLevel --;
			if (powerLevel < -3)
			{
				powerLevel = -3;
			}
			
			if (powerLevel > 0)
			{
				if (powerLevel == 2)
				{
					powerUp2.visible = false;
				}
				else if (powerLevel == 1)
				{
					powerUp2.visible = false;
					powerUp1.visible = false;
				}
			}
			else if (powerLevel < 0)
			{
				if (powerLevel == -3)
				{
					powerDown2.visible = true;
					powerDown1.visible = true;
					powerDown0.visible = true;
				}
				else if (powerLevel == -2)
				{
					powerDown1.visible = true;
					powerDown0.visible = true;
				}
				else
				{
					powerDown0.visible = true;
				}
			}
			else
			{
				powerDown2.visible = false;
				powerDown1.visible = false;
				powerDown0.visible = false;
				powerUp0.visible = false;
				powerUp1.visible = false;
				powerUp2.visible = false;
			}
		}
		
	}

}