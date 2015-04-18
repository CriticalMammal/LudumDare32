package 
{
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Dylan Gallardo
	 */
	public class Rioter extends MovieClip
	{
		public var stageRef:Stage;
		
		// movement
		public var movementSpace:Rectangle = new Rectangle(0, 0, 400, 200);
		public var xPos:Number = 0;
		public var yPos:Number = 0;
		public var goalX:Number = 0;
		public var goalY:Number = 0;
		private var speedX:Number = 0;
		private var speedY:Number = 0;
		private var maxSpeed:Number = 2;
		private var velocity:Number = 0.05;
		private var friction:Number = 0.85;
		private var goalDeviation:Number = 10; // maximum allowed deviation from goal spot
		
		// decision-making
		public var updateDelay:int; // in seconds
		public var timeWaited:int;
		private var personalZone:Rectangle;
		private var personalZoneSize:int;
		private var comfortLevel:int;
		private var runningAway:Boolean = false;
		public var removeFromRiot:Boolean = false;
		private var runAwayZone:int;
		
		// emotions
		public var rage:int = 0;
		public var sorrow:int = 0;
		public var fear:int = 0;
		public var excitement:int = 0;
		
		public function Rioter(stageIn:Stage) 
		{
			stageRef = stageIn;
			updateDelay = 2 * stageRef.frameRate;
			timeWaited = 0;
			comfortLevel = randomNumber(0, 100);
			
			runAwayZone =  800 + 100;
			personalZoneSize = 10;
			personalZone = new Rectangle(x - personalZoneSize, y - personalZoneSize,
									x + width + personalZoneSize*2, y + height + personalZoneSize*2);
		}
		
		public function update():void
		{
			// Movement
			if (Math.abs(xPos - goalX) > goalDeviation) // move on x axis
			{
				if (xPos < goalX)
				{
					speedX += velocity;
				}
				else
				{
					speedX -= velocity;
				}
				
				if (speedX > maxSpeed)
				{
					speedX = maxSpeed;
				}
				else if (speedX < -maxSpeed)
				{
					speedX = -maxSpeed;
				}
			}
			else
			{
				speedX *= friction;
			}
			
			if (Math.abs(yPos - goalY) > goalDeviation) // move on y axis
			{
				if (yPos < goalY)
				{
					speedY += velocity;
				}
				else
				{
					speedY -= velocity;
				}
				
				if (speedY > maxSpeed)
				{
					speedY = maxSpeed;
				}
				else if (speedY < -maxSpeed)
				{
					speedY = -maxSpeed;
				}
			}
			else // create friction to stop
			{
				speedY *= friction;
			}
			
			xPos += speedX;
			yPos += speedY;
			
			this.x = xPos;
			this.y = yPos;
			
			if (runningAway == true)
			{
				if (this.x >= runAwayZone)
				{
					removeFromRiot = true;
				}
			}
			
			personalZone = new Rectangle(x - personalZoneSize, y - personalZoneSize,
									x + width + personalZoneSize*2, y + height + personalZoneSize*2);
			
			// do time based stuff
			if (timeWaited >= updateDelay)
			{
				makeDecisions();
				timeWaited = 0;
			}
			else
			{
				timeWaited++;
			}
		}
		
		private function makeDecisions():void
		{
			fear += randomNumber(0, 4);
			comfortLevel -= 40;
			if (rage <= 0)
			{
				rage = 0;
			}
			
			// do a fear check to see if they should run away
			if (fear > 60)
			{
				var roll1 = randomNumber(0, rage);
				var roll2 = randomNumber(0, rage);
				var roll3 = randomNumber(0, rage);
				
				var rageResist = (roll1 + roll2 + roll3) / 3;
				
				// fear succeeded, they're running away now
				if (rageResist <= 50)
				{
					goalX = runAwayZone + 500;
					runningAway = true;
				}
				else // fear failed
				{
					goalX = randomNumber(movementSpace.x, movementSpace.x + movementSpace.width);
					goalY = randomNumber(movementSpace.y, movementSpace.y + movementSpace.height);
					runningAway = false;
				}
			}
			
			if (comfortLevel <= 30 && runningAway == false)
			{
				//goalX = randomNumber(movementSpace.x, movementSpace.x + movementSpace.width);
				//goalY = randomNumber(movementSpace.y, movementSpace.y + movementSpace.height);
				
				// generate new, feasible position
				var randomOffsetX = randomNumber( -50, 50);
				var randomOffsetY = randomNumber( -50, 50);
				while (goalX + randomOffsetX > movementSpace.x + movementSpace.width ||
						goalX + randomOffsetX < movementSpace.x)
					{
						randomOffsetX = randomNumber( -50, 50);
					}
				while (goalY + randomOffsetY > movementSpace.y + movementSpace.height ||
						goalY + randomOffsetY < movementSpace.y)
						{
							randomOffsetY = randomNumber( -50, 50);
						}
						
				goalX += randomOffsetX;
				goalY += randomOffsetY;
				comfortLevel = 100;
			}
		}
		
		// Get random number in a range
		public function randomNumber(minNum, maxNum)
		{
			return (Math.floor(Math.random() * (maxNum - minNum + 1)) + minNum); 
		}
	}

}