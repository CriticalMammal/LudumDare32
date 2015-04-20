package
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldType;
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
		
		// game variables
		public var crowdTextDisplay:TextField;
		public var crowd:Vector.<Rioter>;
		public var tank:Tank;
		public var menu:Menu;
		
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
			
			menu = new Menu(); // menu will overlay and allow options
			addChild(menu);
			//menu.popUp();
		}
		
		public function game():void
		{
			// placeholder stuff
			var myFormat:TextFormat = new TextFormat();
			myFormat.color = 0xFFFFFF; 
			myFormat.size = 30;
			
			crowdTextDisplay = new TextField();
			crowdTextDisplay.type = TextFieldType.DYNAMIC;
			crowdTextDisplay.selectable = false;
			crowdTextDisplay.x = 300;
			crowdTextDisplay.y = 100;
			crowdTextDisplay.width = 500;
			crowdTextDisplay.height = 100;
			crowdTextDisplay.wordWrap = true;
			crowdTextDisplay.text = "Crowd Count: ";
			crowdTextDisplay.setTextFormat(myFormat);  
			cameraContainer.addChild(crowdTextDisplay);
			
			// game variables
			crowd = new Vector.<Rioter>();
			var crowdCt:int = 200;
			var cityUnrest:Number = 50; // total unhappiness?
			var mouseIsDown:Boolean = false;
			var microwaveRageAmt:Number = 0;
			var microwaveSorrowAmt:Number = 0;
			var microwaveFearAmt:Number = 0;
			var microwaveDamage:Number = 0;
			
			// crowd bounding box
			var crowdX:int = 350;
			var crowdY:int = 200;
			var crowdWidth:int = 400;
			var crowdHeight:int = 200;
			var crowdBoundaries:Rectangle = new Rectangle(crowdX, crowdY, crowdWidth, crowdHeight);
			
			// create initial scene
			tank = new Tank();
			tank.x = 30;
			tank.y = 230;
			cameraContainer.addChild(tank);
			
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
			stageRef.addEventListener(MouseEvent.MOUSE_DOWN, mouseClicked, false, 0, false);
			stageRef.addEventListener(MouseEvent.MOUSE_UP, mouseUp, false, 0, false);
			//stageRef.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, selfDestruct);
			
			
			function mainLoop(e:Event):void
			{	
				for (i = 0; i < crowd.length; i++)
				{
					// update rioters
					crowd[i].update();
					if (crowd[i].removeFromRiot == true)
					{
						var personRef:Rioter = crowd[i];
						crowd.splice(i, 1);
						cameraContainer.removeChild(personRef);
						continue;
					}
					
					if (crowd[i].dead && crowd[i].deathCollected == false)
					{
						cityUnrest ++;
						crowd[i].deathCollected = true;
					}
					
					crowd[i].rage += cityUnrest / 200;
					
					if (cityUnrest <= 0)
					{
						crowd[i].sorrow += 0.05;
					}
				}
				
				cityUnrest -= 0.005;
				cityUnrest = stayInBounds(cityUnrest, 200, 0);
				
				crowdTextDisplay.text = "City Unrest: " + cityUnrest;
				crowdTextDisplay.text = " ";
				crowdTextDisplay.setTextFormat(myFormat);
				
				// updating microwave laser thing
				microwaveRageAmt = menu.emotionControlRage.powerLevel*2;
				microwaveSorrowAmt = menu.emotionControlSorrow.powerLevel*2;
				microwaveFearAmt = menu.emotionControlFear.powerLevel*2;
				
				microwaveDamage = (Math.abs(microwaveRageAmt) + Math.abs(microwaveSorrowAmt) + Math.abs(microwaveFearAmt)) / 3;
				var tempDisplay = int((microwaveDamage)*100)/100;
				menu.microwaveDamage.text = tempDisplay;
				
				// mouse interaction
				if (mouseIsDown)
				{
					var myObjects:Array = getObjectsUnderPoint(new Point(mouseX, mouseY));
					for (var i = 0; i < myObjects.length; i++)
					{
						if (myObjects[i].parent is Rioter)
						{
							var personUnderMouse:Rioter = myObjects[i].parent as Rioter;
							personUnderMouse.fear += microwaveFearAmt;
							personUnderMouse.sorrow += microwaveSorrowAmt;
							personUnderMouse.rage += microwaveRageAmt;
							personUnderMouse.health -= microwaveDamage;
							personUnderMouse.timeWaited += 10; // update more frequently
							personUnderMouse.goalX += randomNumber(0, microwaveDamage);
							if (personUnderMouse.heatOverlay.alpha > 1)
							{
								personUnderMouse.heatOverlay.alpha = 1;
							}
						}
					}
				}
				
				if (tank.isClicked)
				{
					if (menu.isOpen)
					{
						menu.popOut();
					}
					else
					{
						menu.popUp();
					}
					tank.isClicked = false;
				}
				
				// sort the crowd by y positions
				crowd = Vector.<Rioter>(vectorToArray(crowd).sortOn("yPos", Array.NUMERIC));
				for each(var r:Rioter in crowd)
				{
					r.parent && r.parent.addChild(r);
				}
			}
			
			function mouseClicked(e:MouseEvent):void
			{
				mouseIsDown = true;
			}
			
			function mouseUp(e:MouseEvent):void
			{
				mouseIsDown = false;
			}
			
			function selfDestruct(e:MouseEvent):void
			{
				removeEventListener(Event.ENTER_FRAME, mainLoop);
				stageRef.removeEventListener(MouseEvent.MOUSE_DOWN, mouseClicked);
				stageRef.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
				stageRef.removeEventListener(MouseEvent.RIGHT_MOUSE_DOWN, selfDestruct);
				
				removeGame();
			}
		}
		
		public function removeGame():void
		{
			// fade to black?
			
			
			// remove events
			//removeEventListener(Event.ENTER_FRAME, mainLoop);
			//removeEventListener(MouseEvent.MOUSE_DOWN, mouseClicked);
			//removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
			//removeEventListener(KeyboardEvent.KEY_DOWN, removeGame);
			
			// remove instances
			for each (var r:Rioter in crowd)
			{
				cameraContainer.removeChild(r);
			}
			
			cameraContainer.removeChild(crowdTextDisplay);
			cameraContainer.removeChild(tank);
			
			game();
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