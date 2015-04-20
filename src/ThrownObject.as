package 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Dylan Gallardo
	 */
	public class ThrownObject extends MovieClip 
	{
		// movement
		public var xPos:Number = 0;
		public var yPos:Number = 0;
		private var speedX:Number = 0;
		private var speedY:Number = 0;
		private var momentumX:Number = 12;
		private var momentumY:Number = 8;
		private var maxSpeed:Number = 4;
		private var velocity:Number = 0.3;
		private var friction:Number = 0.85;
		private var gravity:Number = 1;
		private var ground:Number = 500;
		
		// animation/other
		private var tankRef:Tank;
		public var broken:Boolean = false;
		private var object:int = 0; // for object type (image/animation)
		private var maxObjects:int = 2;
		
		public function ThrownObject(groundLevel:Number, tank:Tank) 
		{
			object = randomNumber(0, maxObjects-1); // randomly select object type
			
			for (var i = 0; i < maxObjects; i++)
			{
				this["object" + i].visible = false;
			}
			this["object" + object].visible = true;
			
			ground = groundLevel;
			tankRef = tank;
			addEventListener(Event.ENTER_FRAME, update, false, 0, false);
		}
		
		public function update(e:Event):void
		{
			speedX = 0;
			speedY = 0;
			
			// Movement
			speedX -= maxSpeed;
			if (speedX < -maxSpeed)
			{
				speedX = -maxSpeed;
			}
			
			// y axis
			momentumY -= velocity;
			speedY -= momentumY;
			
			if (speedY < -maxSpeed)
			{
				speedY = -maxSpeed;
			}
			
			xPos += speedX;
			yPos += speedY;
			//yPos -= gravity;
			
			this.x = xPos;
			this.y = yPos;
			
			if (y+height >= ground || broken == true)
			{
				//play break animation, and remove
				gotoAndPlay("break");
				
				for (var i = 0; i < maxObjects; i++)
				{
					this["object" + i].visible = false;
				}
				this["object" + object].visible = true;
				
				removeEventListener(Event.ENTER_FRAME, update);
			}
			else if (this.hitTestObject(tankRef.hitbox))
			{
				tankRef.takeDamage();
				
				//play break animation, and remove
				gotoAndPlay("break");
				
				for (i = 0; i < maxObjects; i++)
				{
					this["object" + i].visible = false;
				}
				this["object" + object].visible = true;
				
				removeEventListener(Event.ENTER_FRAME, update);
			}
		}
		
		// Get random number in a range
		public function randomNumber(minNum, maxNum)
		{
			return (Math.floor(Math.random() * (maxNum - minNum + 1)) + minNum); 
		}
	}

}