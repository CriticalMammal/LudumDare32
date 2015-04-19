package
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author Dylan Gallardo
	 */
	
	public class Main extends MovieClip
	{
		private var stageRef:Stage;
		private var quit = false;
		public var gameRateMultiplier:Number = 1;
		public var worldSpeed:Number = 60 * gameRateMultiplier;
		public var cameraContainer:Sprite; // everything visual goes in this
		
		// Constructor
		public function Main(stageRef:Stage = null)
		{
			this.stageRef = stageRef;
			stageRef.frameRate = worldSpeed;
			
			init();
		}
		
		// The menu kind of always stays there? It just drops down?
		public function init():void 
		{
			cameraContainer = new Sprite();
			addChild(cameraContainer);
			game();// game will play in background at all times
			
			var menu:Menu = new Menu(); // menu will overlay and allow options
			addChild(menu);
		}
		
		public function game():void
		{
			// placeholder stuff
			var myFormat:TextFormat = new TextFormat();
			myFormat.color = 0xFFFFFF; 
			myFormat.size = 30;
			
			var crowdTextDisplay:TextField = new TextField();
			crowdTextDisplay.x = 300;
			crowdTextDisplay.y = 100;
			crowdTextDisplay.width = 500;
			crowdTextDisplay.height = 100;
			crowdTextDisplay.wordWrap = true;
			crowdTextDisplay.text = "Crowd Count: ";
			crowdTextDisplay.setTextFormat(myFormat);  
			cameraContainer.addChild(crowdTextDisplay);
			
			// game variables
			var crowd:Vector.<Rioter> = new Vector.<Rioter>();
			var crowdCt:int = 150;
			var cityUnrest:int = 0; // total unhappiness?
			
			// crowd bounding box
			var crowdX:int = 300;
			var crowdY:int = 200;
			var crowdWidth:int = 400;
			var crowdHeight:int = 200;
			var crowdBoundaries:Rectangle = new Rectangle(crowdX, crowdY, crowdWidth, crowdHeight);
			
			// create initial scene
			
			
			// initialize people in the crowd
			for (var i:int = 0; i < crowdCt; i++)
			{
				var newRioter:Rioter = new Rioter(stageRef);
				
				//set rioter's emotional properties
				newRioter.rage = randomNumber(20, 70);
				newRioter.sorrow = randomNumber(0, 30);
				newRioter.fear = randomNumber(0, 40);
				newRioter.excitement = randomNumber(20, 90);
				
				// rioter's movement properties
				newRioter.movementSpace = new Rectangle(crowdX, crowdY, crowdWidth, crowdHeight);
				//newRioter.x = stageRef.width + 50;
				newRioter.x = randomNumber(crowdX, crowdX + crowdWidth);
				newRioter.y = randomNumber(crowdY, crowdY + crowdHeight);
				newRioter.xPos = newRioter.x;
				newRioter.yPos = newRioter.y;
				newRioter.goalX = newRioter.x;
				newRioter.goalY = newRioter.y;
				newRioter.timeWaited = randomNumber(0, newRioter.updateDelay);
				newRioter.name = "rioter";
				
				crowd.push(newRioter);
				cameraContainer.addChild(newRioter);
			}
			
			addEventListener(Event.ENTER_FRAME, mainLoop, false, 0, false);
			
			function mainLoop(e:Event):void
			{
				// total the city variables to understand if you need to add more people
				// to the crowd
				cityUnrest = 0;
				
				for (i = 0; i < crowd.length; i++)
				{
					// update rioters
					crowd[i].update();
					if (crowd[i].removeFromRiot == true)
					{
						crowd.splice(i, 1);
						continue;
					}
					
					cityUnrest += crowd[i].rage;
				}
				cityUnrest /= crowdCt; //gives the average rage
				
				crowdTextDisplay.text = "Crowd Count: " + crowd.length;
				crowdTextDisplay.setTextFormat(myFormat);
				
				//mouse pointer stuff?
				var myObjects:Array = getObjectsUnderPoint(new Point(mouseX, mouseY));
				for (var i = 0; i < myObjects.length; i++)
				{
					if (myObjects[i].parent is Rioter)
					{
						var personUnderMouse:Rioter = myObjects[i].parent as Rioter;
						personUnderMouse.fear += 3;
						personUnderMouse.rage -= 1;
						personUnderMouse.timeWaited += 10; // update more frequently
						personUnderMouse.heatOverlay.alpha += 0.035;
						personUnderMouse.goalX += randomNumber(0, 2);
						if (personUnderMouse.heatOverlay.alpha > 1)
						{
							personUnderMouse.heatOverlay.alpha = 1;
						}
					}
				}
				
				// sort the crowd by y positions
				crowd = Vector.<Rioter>(vectorToArray(crowd).sortOn("yPos", Array.NUMERIC));
				for each(var r:Rioter in crowd)
				{
					r.parent && r.parent.addChild(r);
				}
			}
		}
		
		/**
		* Converts vector to an array
		* @param    v:*        vector to be converted
		* @return    Array    converted array
		*/
		public function vectorToArray(v:*):Array
		{
			var n:int = v.length; var a:Array = new Array();
			for(var i:int = 0; i < n; i++) a[i] = v[i];
			return a;
		}
		
		// Get random number in a range
		public function randomNumber(minNum, maxNum)
		{
			return (Math.floor(Math.random() * (maxNum - minNum + 1)) + minNum); 
		}
	}

}