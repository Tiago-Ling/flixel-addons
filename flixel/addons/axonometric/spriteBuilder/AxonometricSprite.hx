package flixel.addons.axonometric.spriteBuilder;

import flixel.group.FlxGroup;
import flixel.addons.axonometric.mapBuilder.blueprint.Node;
import flixel.addons.axonometric.mapBuilder.AxoMap;
import flash.geom.Point;
import flixel.FlxSprite;

/**
 * Sprite created to Interact with the new stage, since it extends flxSprite, all of its behaviour is also ihnerited
 * 
 * @author	AS3 Original: Miguel Ángel Piedras Carrillo; 
 * 			Original Haxe 2.10 Port: Masadow
 * 			Second Haxe Port: Tiago Ling Alexandre
 */
class AxonometricSprite extends FlxSprite 
{
	
	private var upy:Float;
	private var downy:Float;
	private var prevYpos:Float;
	private var prevXpos:Float;
	private var limitVel:Float;

	/*
	 * tells if the sprite is jumping
	 */ 		
	public var jumping:Bool;

	/*
	 * tells the current height of the jump
	 */ 		
	public var jumpHeight:Float;

	/*
	 * the shadows determines the movement of the sprite, if the shadow moves, the sprite moves.
	 */
	public var shadow:Shadow;
	
	/*
	 * reference to the stage builder
	 */
	public var map:AxoMap;

	/*
	 * reference to the current node
	 */
	public var currentNode:Node;

	/*
	 * reference to the current layer
	 */
	public var currgroup:FlxGroup;
	
	/*
	 *  variable to reference the chage of layers in the stage
	 */ 
	
	public var changeLayer:Bool;
	
	/*
	 *  variable to avoid un necesary re-checks of layer collition 
	 */ 
	public var checkedi:Float;

	/*
	 *  variable to avoid un necesary re-checks of layer collition
	 */ 
	public var checkedj:Float;

	public function new(noshadow:Bool = false) 
	{
		super();			
		alive = true;
		jumping	= false;
		width = 0;
		height = 0;
		jumpHeight = 0;
		upy = 0;
		downy = 0;
		limitVel = 0;
		acceleration.x = 0;
		prevYpos = 0;
		prevXpos = 0;
		changeLayer = false;
		checkedi = -1;
		checkedj = -1;
		shadow = new Shadow(this, noshadow);			
	}		
	
	override public function update():Void 
	{
		super.update();
		move();
		map.CheckBounds(this);
		animate();
	}

	private function move():Void 
	{
		var deltay:Float;
		var deltax:Float;
		if (jumping) 
		{
			jumpHeight= (limitVel * limitVel - (this.velocity.y) * (this.velocity.y)) / (2 * acceleration.y);
			//jumpHeight=this.y - shadow.y;
			if (jumpHeight < 0) 
			{ 
				jumping = false;
				this.x = shadow.x;
				this.y = shadow.y;
				acceleration.y = 0;
				velocity.y = 0;
				jumpHeight = 0;
				limitVel = 0;
			}
			else 
			{
				deltay = shadow.y - prevYpos - shadow.dropsize;
				deltax = shadow.x - prevXpos;
				this.y += deltay;
				this.x += deltax;
				shadow.dropsize = 0;
			}
			shadow.shadowSize(jumpHeight);
		}
		else 
		{	
			this.x = shadow.x;
			this.y = shadow.y;
		}
		prevYpos = shadow.y;
		prevXpos = shadow.x;
	}				
	
	/**
	 * gives an order to the sprite to jump
	 * 
	 * @param jumpSize the power of the jump
	 * @param accellsize the power of the gravity during the jump
	 */
	public function jump_now(jumpSize:Float, accellsize:Float = 320):Void 
	{
		acceleration.y = accellsize;
		velocity.y -= jumpSize;
		if (!jumping) 
		{
			limitVel = jumpSize;
		} 
		else 
		{
			limitVel = Math.sqrt(2 * acceleration.y * jumpHeight + velocity.y * velocity.y);
		}
		jumping = true;
	}
	
	
	/*
	 * function that is called in order to animate the sprite, it must be overriden in order to be used
	 */ 
	public function animate():Void { }
	
	/*
	 * function that is called in order to move the sprite, it must be overriden in order to be used
	 */
	public function moveOrder():Void { }
	
	/*
	 * sets the sprite in a specific x,y location
	 */
	public function setLocation(x:Float, y:Float):Void 
	{
		shadow.x = x;
		shadow.y = y;
	}
	
	/**
	 * destroys the current object, freeing memory
	 * 
	 */		
	override public function destroy():Void 
	{
		shadow.kill();
		kill();
	}
	
}