package
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

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
		public var stageContainer:Sprite; // put even the cameraContainer in this
		
		// game variables
		public var crowdTextDisplay:TextField;
		public var crowd:Vector.<Rioter>;
		public var tank:Tank;
		public var menu:Menu;
		public var background:bgImage
		
		// constant playing sounds
		public var bgAmbience:Sound = new bgAmbienceSound();
		public var bgAmbienceChannel:SoundChannel = new SoundChannel();
		public var bgAmbienceTransform:SoundTransform = new SoundTransform();
		
		public var crowdYell:Sound = new crowdYellSound();
		public var crowdYellChannel:SoundChannel = new SoundChannel();
		public var crowdYellTransform:SoundTransform = new SoundTransform();
		
		public var microwaveGun:Sound = new microwaveGunSound();
		public var microwaveGunChannel:SoundChannel = new SoundChannel();
		public var microwaveGunTransform:SoundTransform = new SoundTransform();
		
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
			stageContainer = new Sprite();
			stageContainer.name = "stageContainer";
			addChild(stageContainer);
			
			var background:bgImage = new bgImage();
			stageContainer.addChild(background);
			
			cameraContainer = new Sprite();
			cameraContainer.x = 0;
			cameraContainer.y = 0;
			stageContainer.addChild(cameraContainer);
			game();// game will play in background at all times
			
			menu = new Menu(); // menu will overlay and allow options
			addChild(menu);
			
			bgAmbienceTransform.volume = 1.8;
			bgAmbienceChannel.soundTransform = bgAmbienceTransform;
			bgAmbienceChannel = bgAmbience.play(0, int.MAX_VALUE, bgAmbienceTransform);
			
			crowdYellTransform.volume = 0;
			crowdYellChannel.soundTransform = crowdYellTransform;
			crowdYellChannel = crowdYell.play(0, int.MAX_VALUE, crowdYellTransform);
			
			microwaveGunTransform.volume = 0;
			microwaveGunChannel.soundTransform = microwaveGunTransform;
			microwaveGunChannel = microwaveGun.play(0, int.MAX_VALUE, microwaveGunTransform);
		}
		
		public function game():void
		{
			// for subtle screen movement
			var stageX:Number = stageContainer.x;
			var stageY:Number = stageContainer.y;
			var motionAmt = 12;
			var randStageX:Number = randomNumber( -motionAmt, motionAmt);
			var randStageY:Number = randomNumber( -motionAmt, motionAmt);
			var motionSpeed = 0.005;
			var updateTime = 1 * 60;
			var currentScreenTime = 0;
			
			var restartButton:RestartButton = new RestartButton();
			restartButton.x = 350;
			restartButton.y = 50;
			restartButton.visible = false;
			restartButton.name = "restartButton";
			restartButton.addEventListener(MouseEvent.CLICK, selfDestruct);
			stageContainer.addChild(restartButton);
			
			// placeholder stuff
			var myFormat:TextFormat = new TextFormat();
			myFormat.color = 0xDED5D1; 
			myFormat.size = 30;
			myFormat.bold = true;
			
			crowdTextDisplay = new TextField();
			crowdTextDisplay.type = TextFieldType.DYNAMIC;
			crowdTextDisplay.selectable = false;
			crowdTextDisplay.x = 300;
			crowdTextDisplay.y = 100;
			crowdTextDisplay.width = 500;
			crowdTextDisplay.height = 100;
			crowdTextDisplay.wordWrap = true;
			crowdTextDisplay.text = "Control the Rioting Crowd";
			crowdTextDisplay.setTextFormat(myFormat);  
			stageContainer.addChild(crowdTextDisplay);
			
			var instructionsDisplayCt:int = 0;
			var restartButtonWait:int = 0;
			
			// game variables
			crowd = new Vector.<Rioter>();
			var crowdCt:int = 150;
			var crowdDeathCt:int = 0;
			var crowdRealCt:int = crowdCt;
			var cityUnrest:Number = 50; // total unhappiness?
			var mouseIsDown:Boolean = false;
			var microwaveRageAmt:Number = 0;
			var microwaveSorrowAmt:Number = 0;
			var microwaveFearAmt:Number = 0;
			var microwaveDamage:Number = 0;
			
			// crowd bounding box
			var crowdX:int = 365;
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
				var newRioter:Rioter = new Rioter(stageRef, tank);
				
				//set rioter's emotional properties
				newRioter.rage = randomNumber(30, 80);
				newRioter.sorrow = randomNumber(0, 10);
				newRioter.fear = randomNumber(0, 60);
				//newRioter.excitement = randomNumber(20, 90);
				
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
			
			// sounds/audio
			
			// play + fade volume in example
			//buildSongChannel = buildupSong.play(0, 1, buildSongTransform);
			//changeVolume(buildSongChannel, buildSongTransform, buildSongTransform.volume, 1, 0.002);
			
			addEventListener(Event.ENTER_FRAME, mainLoop, false, 0, false);
			stageRef.addEventListener(MouseEvent.MOUSE_DOWN, mouseClicked, false, 0, false);
			stageRef.addEventListener(MouseEvent.MOUSE_UP, mouseUp, false, 0, false);
			//stageRef.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, selfDestruct);
			
			
			function mainLoop(e:Event):void
			{
				if (currentScreenTime >= updateTime)
				{
					randStageX = randomNumber( -motionAmt, motionAmt);
					randStageY = randomNumber( -motionAmt, motionAmt);
					
					currentScreenTime = 0;
				}
				stageX = doLerp(stageX, randStageX, motionSpeed);
				stageY = doLerp(stageY, randStageY, motionSpeed);
				stageContainer.x = stageX;
				stageContainer.y = stageY;
				currentScreenTime++;
				
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
						crowdDeathCt ++;
					}
					
					crowd[i].rage += cityUnrest / 1000;
					
					if (cityUnrest <= 0)
					{
						crowd[i].sorrow += 0.01;
					}
					
					if (tank.destroyed)
					{
						crowd[i].updateDelay = 0.5 * stageRef.frameRate;
						crowd[i].fear = randomNumber(20, 60);
						crowd[i].rage = 100;
						crowd[i].movementSpace.x = crowdBoundaries.x;
					}
				}
				
				crowdCt = crowd.length;
				crowdRealCt = crowdCt - crowdDeathCt;
				changeVolume(crowdYellChannel, crowdYellTransform, crowdYellTransform.volume, crowdRealCt/200, 0.002);
				
				cityUnrest -= 0.005;
				cityUnrest = stayInBounds(cityUnrest, 200, 0);
				
				crowdTextDisplay.text = "City Unrest: " + cityUnrest;
				if (instructionsDisplayCt <= 6*60 && instructionsDisplayCt>2*60)
				{
					crowdTextDisplay.text = "Control the Rioting Crowd";
				}
				else
				{
					crowdTextDisplay.text = " ";
				}
				instructionsDisplayCt ++;
				
				if (crowdRealCt <= 0)
				{
					crowdTextDisplay.text = "Crowd was Controlled : " + crowdDeathCt + " Killed";
					restartButtonWait ++;
				}
				else if (tank.destroyed)
				{
					crowdTextDisplay.text = "Disorder : Tank Operator Killed";
					restartButtonWait ++;
				}
				crowdTextDisplay.setTextFormat(myFormat);
				
				if (restartButtonWait >= 60 * 5)
				{
					restartButton.visible = true;
				}
				
				// updating microwave laser thing
				if (tank.destroyed)
				{
					menu.emotionControlRage.turnOffPower();
					menu.emotionControlSorrow.turnOffPower();
					menu.emotionControlFear.turnOffPower();
					
					crowdBoundaries.x = 50;
					/*
					crowdBoundaries.x -= 2;
					if (crowdBoundaries.x <= 50)
					{
						crowdBoundaries.x = 50;
					}
					*/
				}
				microwaveRageAmt = menu.emotionControlRage.powerLevel*2;
				microwaveSorrowAmt = menu.emotionControlSorrow.powerLevel*2;
				microwaveFearAmt = menu.emotionControlFear.powerLevel*2;
				
				microwaveDamage = (Math.abs(microwaveRageAmt) + Math.abs(microwaveSorrowAmt) + Math.abs(microwaveFearAmt)) / 5;
				var tempDisplay = int((microwaveDamage)*100)/100;
				menu.microwaveDamage.text = tempDisplay;
				
				var tankHealth = tank.health;
				if (tankHealth >= 90)
				{
					menu.tankStatus.text = "Very Shiny";
					if (tank.currentLabel != "shiny")
					{
						//tank.gotoAndPlay("shiny");
					}
				}
				else if (tankHealth >= 80)
				{
					menu.tankStatus.text = "Pretty Great";
				}
				else if (tankHealth >= 65)
				{
					menu.tankStatus.text = "Light Damage";
				}
				else if (tankHealth >= 50)
				{
					menu.tankStatus.text = "Bruised"
					if (tank.currentLabel != "bruised")
					{
						tank.gotoAndPlay("bruised");
					}
				}
				else if (tankHealth >= 35)
				{
					menu.tankStatus.text = "Heavy Damage";
				}
				else if (tankHealth >= 20)
				{
					menu.tankStatus.text = "Limping";
				}
				else if (tankHealth > 0)
				{
					menu.tankStatus.text = "Last Leg";
				}
				else
				{
					menu.tankStatus.text = "Destroyed";
				}
				
				// mouse interaction
				if (mouseIsDown)
				{
					var hittingRioter:int = 0;
					// microwave gun sound vol
					//microwaveGunChannel = microwaveGun.play(0, 1, microwaveGunTransform);
					
					
					var myObjectsArray:Array = getObjectsUnderPoint(new Point(mouseX, mouseY));
					var myObjects:Vector.<DisplayObject> = Vector.<DisplayObject>(myObjectsArray);
					for (var i = 0; i < myObjects.length; i++)
					{
						trace(getQualifiedClassName(myObjects[i]));
						var personUnderMouse:Rioter;
						
						if (myObjects[i].parent is Rioter)
						{
							hittingRioter += 10;
							personUnderMouse = myObjects[i].parent as Rioter;
							personUnderMouse.fear += microwaveFearAmt;
							personUnderMouse.sorrow += microwaveSorrowAmt;
							personUnderMouse.rage += microwaveRageAmt;
							personUnderMouse.health -= microwaveDamage;
							personUnderMouse.currentThrowCooldown -= microwaveRageAmt;
							personUnderMouse.timeWaited += 10; // update more frequently
							personUnderMouse.goalX += randomNumber(0, microwaveDamage);
							if (personUnderMouse.heatOverlay.alpha > 1)
							{
								personUnderMouse.heatOverlay.alpha = 1;
							}
						}
						else if (getQualifiedClassName(myObjects[i]) != "flash.text::TextField" && !(myObjects[i].parent is Stage) &&
							getQualifiedClassName(myObjects[i].parent.parent) == "Rioter")
						{
							hittingRioter += 10;
							personUnderMouse = myObjects[i].parent.parent as Rioter;
							personUnderMouse.fear += microwaveFearAmt;
							personUnderMouse.sorrow += microwaveSorrowAmt;
							personUnderMouse.rage += microwaveRageAmt;
							personUnderMouse.health -= microwaveDamage;
							personUnderMouse.currentThrowCooldown -= microwaveRageAmt;
							personUnderMouse.timeWaited += 10; // update more frequently
							personUnderMouse.goalX += randomNumber(0, microwaveDamage);
							if (personUnderMouse.heatOverlay.alpha > 1)
							{
								personUnderMouse.heatOverlay.alpha = 1;
							}
						}
						else
						{
							hittingRioter--;
							
							//trace(getQualifiedClassName(myObjects[i].parent.parent));
						}
					}
					
					if (hittingRioter > 0)
					{
						changeVolume(microwaveGunChannel, microwaveGunTransform, microwaveGunTransform.volume, 0.4, 0.003);
					}
					else
					{
						changeVolume(microwaveGunChannel, microwaveGunTransform, microwaveGunTransform.volume, 0, 0.002);
					}
				}
				else
				{
					changeVolume(microwaveGunChannel, microwaveGunTransform, microwaveGunTransform.volume, 0, 0.002);
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
				/*
				crowd = Vector.<Rioter>(vectorToArray(crowd).sortOn("yPos", Array.NUMERIC));
				for each(var r:Rioter in crowd)
				{
					r.parent && r.parent.addChild(r);
				}
				*/
				
				var children = getChildren(cameraContainer);
				children = Vector.<DisplayObject>(vectorToArray(children).sortOn("yPos", Array.NUMERIC));
				for each(var r:DisplayObject in children)
				{
					r.parent && r.parent.addChild(r);
				}
			}
			
			function getChildren( parObj:DisplayObjectContainer ):Vector.<DisplayObject>
			{
				var kids:Vector.<DisplayObject> = new Vector.<DisplayObject>();
				var kidCount:int = parObj.numChildren;
				for( var i:int = 0; i < kidCount; i++ ) 
					kids.push( parObj.getChildAt( i ) );
				return kids
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
				restartButton.removeEventListener(MouseEvent.CLICK, selfDestruct);
				stageContainer.removeChild(restartButton);
				
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
			
			stageContainer.removeChild(crowdTextDisplay);
			cameraContainer.removeChild(tank);
			menu.emotionControlRage.powerOff = false;
			menu.emotionControlSorrow.powerOff = false;
			menu.emotionControlFear.powerOff = false;
			
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
		
		// Change sound volume
		public function changeVolume(soundChannel, transform, currentTransformVolume, newVolume, changeSpeed)
		{
			addEventListener(Event.ENTER_FRAME, volumeChangeLoop, false, 0, false);
			transform.volume = currentTransformVolume;
			
			function volumeChangeLoop(event:Event)
			{
				if (transform.volume != newVolume)
				{
					//if the value is close enough but not quite equal...
					if (transform.volume < newVolume + changeSpeed && transform.volume > newVolume - changeSpeed)
					{
						transform.volume = newVolume;
					}
					//otherwise check if greater or less than and do appropriate calculation
					 if (transform.volume > newVolume)
					{
						transform.volume -= changeSpeed;
					}
					else if (transform.volume < newVolume)
					{
						transform.volume += changeSpeed;
					}
					
					//update the sound channel
					soundChannel.soundTransform = transform;
				}
				else
				{
					transform.volume = newVolume;
					soundChannel.soundTransform = transform;
					removeEventListener(Event.ENTER_FRAME, volumeChangeLoop, false);
				}
			}
		}
		
		// current speed, goal speed, amount of lerp
		public function doLerp(value:Number, goal:Number, lerpSpeed:Number):Number
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
			
		public function lerp(x:Number, t:Number, y:Number):Number
		{
			return x * (1-t) + y*t;
		}
	}

}