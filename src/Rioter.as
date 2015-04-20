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
		private var walkSpeed:Number = 1;
		private var runSpeed:Number = 1.5;
		private var maxSpeed:Number = walkSpeed;
		private var walkVelocity:Number = 0.005;
		private var runVelocity:Number = 0.03;
		private var velocity:Number = walkVelocity;
		private var friction:Number = 0.85;
		private var goalDeviation:Number = 10; // maximum allowed deviation from goal spot
		
		// decision-making
		public var updateDelay:int; // in seconds
		public var timeWaited:int;
		private var emotionChangeCooldown:int = 0;
		private var personalZone:Rectangle;
		private var personalZoneSize:int;
		private var comfortLevel:int;
		private var runningAway:Boolean = false;
		private var givingUp:Boolean = false;
		public var removeFromRiot:Boolean = false;
		private var runAwayZone:int;
		private var runAwayFinished:Boolean = true;
		
		// other
		private var tankRef:Tank;
		private var throwCooldown:Number = 1.5 * 60;
		private var currentThrowCooldown:Number = 0;
		
		// emotions
		public var rage:Number = 0;
		public var sorrow:Number = 0;
		public var fear:Number = 0;
		public var excitement:Number = 0;
		
		// health
		public var health:Number = 100;
		public var dead:Boolean = false;
		public var deathCollected:Boolean = false;
		
		
		public function Rioter(stageIn:Stage, tank:Tank) 
		{
			stageRef = stageIn;
			tankRef = tank;
			updateDelay = 2 * stageRef.frameRate;
			timeWaited = 0;
			comfortLevel = randomNumber(0, 100);
			currentThrowCooldown = randomNumber(0, throwCooldown);
			//this.cacheAsBitmap = true;
			
			runAwayZone =  800 + 100;
			personalZoneSize = 10;
			personalZone = new Rectangle(x - personalZoneSize, y - personalZoneSize,
									x + width + personalZoneSize*2, y + height + personalZoneSize*2);
		}
		
		public function update():void
		{
			if (dead)
			{
				return;
			}
			
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
			
			if (givingUp == true)
			{
				if (this.x >= runAwayZone)
				{
					removeFromRiot = true;
				}
			}
			if (runningAway == true)
			{
				if (x >= runAwayZone)
				{
					fear -= 0.3;
					rage += 0.5;
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
			
			heatOverlay.alpha = (100-health)/100; // percentage of health
			if (heatOverlay.alpha <= 0)
			{
				heatOverlay.alpha = 0;
			}
			
			// return status to a normal level
			if (fear >= 50)
			{
				fear -= 0.1;
			}
			if (rage >= 70)
			{
				rage -= 0.1;
			}
			
			// health based stuff
			if (health <= 100)
			{
				if (health <= 40)
				{
					rage -= 2;
					fear += 3;
					
					if (health <= 20)
					{
						if (health <= 0)
						{
							dead = true;
							
							var currentAlpha = heatOverlay.alpha;
							heatOverlay.alpha = 0;
							this.gotoAndPlay("death");
						}
					}
				}
				
				health += (health/100)/30; //slow health regen
			}
			
			fear = stayInBounds(fear, 100, 0);
			rage = stayInBounds(rage, 100, 0);
			health = stayInBounds(health, 100, 0);
		}
		
		private function makeDecisions():void
		{	
			if (dead)
			{
				return;
			}
			
			// attack tank
			if (x - tankRef.x <= 550 && currentThrowCooldown <= 0) //330
			{
				var thrownObject:ThrownObject = new ThrownObject(this.height, tankRef);
				addChild(thrownObject);
				
				currentThrowCooldown = throwCooldown;
			}
			else
			{
				currentThrowCooldown -= 1;
			}
			
			comfortLevel -= 10;
			
			if (emotionChangeCooldown > 0)
			{
				emotionChangeCooldown --;
			}
			
			// do a fear check to see if they should run away
			if (fear > 80 && emotionChangeCooldown <= 0)
			{
				var roll1 = randomNumber(0, rage);
				var roll2 = randomNumber(0, rage);
				var roll3 = randomNumber(0, rage);
				
				var rageResist = (roll1 + roll2 + roll3) / 3;
				
				// fear succeeded, they're running away now. Rage roll was too low
				if (rageResist <= 40)
				{
					maxSpeed = runSpeed;
					velocity = runVelocity;
					goalX = runAwayZone + randomNumber(1, 20);
					runningAway = true;
					runAwayFinished = false;
				}
				else // fear failed
				{
					maxSpeed = walkSpeed;
					velocity = walkVelocity;
					goalX = randomNumber(movementSpace.x, movementSpace.x + movementSpace.width);
					goalY = randomNumber(movementSpace.y, movementSpace.y + movementSpace.height);
					runningAway = false;
					emotionChangeCooldown = 10;
				}
			}
			else
			{
				roll1 = randomNumber(0, rage);
				roll2 = randomNumber(0, rage);
				roll3 = randomNumber(0, rage);
				
				rageResist = (roll1 + roll2 + roll3) / 3;
				
				if (rageResist >= 40)
				{
					maxSpeed = walkSpeed;
					velocity = walkVelocity;
					runningAway = false;
					runAwayFinished = false;
				}
			}
			
			if (runningAway)
			{
				if (sorrow >= 60)
				{
					// roll sorrow vs. rage
					roll1 = randomNumber(0, rage);
					roll2 = randomNumber(0, rage);
					roll3 = randomNumber(0, rage);
					
					rageResist = (roll1 + roll2 + roll3) / 3;
					
					// giving up succeeds, rage roll was too low
					if (rageResist <= 60)
					{
						givingUp = true;
					}
				}
			}
			
			if (comfortLevel <= 30 && runningAway == false)
			{
				// generate new, feasible position
				var offsetNorm = Math.abs( 50 + randomNumber(0, rage) + randomNumber(0, fear) );
				var offsetAmtMin = Math.abs(offsetNorm - fear*(offsetNorm/100));
				var offsetAmtMax = Math.abs(offsetNorm - rage*(offsetNorm/100));
				var randomOffsetX = randomNumber( -offsetAmtMin, offsetAmtMax);
				var randomOffsetY = randomNumber( -offsetNorm, offsetNorm);
				
				if (runningAway == false && runAwayFinished == false)
				{
					goalX = randomNumber(movementSpace.x, movementSpace.x + movementSpace.width - 50);
					goalY = randomNumber(movementSpace.y, movementSpace.y + movementSpace.height);
					comfortLevel = 100;
					
					if (x < movementSpace.x + movementSpace.width &&
							x > movementSpace.x)
							{
								runAwayFinished = true;
							}
					return;
				}
				
				var iterations = 0;
				while (goalX + randomOffsetX > movementSpace.x + movementSpace.width ||
						goalX + randomOffsetX < movementSpace.x)
				{
					if (iterations > 100)
					{
						randomOffsetX = randomNumber( -offsetNorm, offsetNorm);
					}
					else if (iterations > 500)
					{
						goalX = movementSpace.x + movementSpace.width - 50;
						goalY = movementSpace.y + movementSpace.height;
						return;
					}
					else
					{
						randomOffsetX = randomNumber( -offsetAmtMin, offsetAmtMax);
					}
					
					iterations ++;
				}
					
				while (goalY + randomOffsetY > movementSpace.y + movementSpace.height ||
						goalY + randomOffsetY < movementSpace.y)
				{
					randomOffsetY = randomNumber(-offsetNorm, offsetNorm);
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
		
		private function stayInBounds(value:Number, max:Number, min:Number):Number
		{
			if (value > max)
			{
				value = max;
			}
			else if (value < min)
			{
				value = min;
			}
			
			return value;
		}
	}

}