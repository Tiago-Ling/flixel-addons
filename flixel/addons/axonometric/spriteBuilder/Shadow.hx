package flixel.addons.axonometric.spriteBuilder ;

import flash.geom.Point;
import flixel.FlxSprite;
import openfl.Assets;
import flash.display.BitmapData;

/**
 * shadow of the sprite.
 * 
 * @author	AS3 Original: Miguel Ángel Piedras Carrillo; 
 * 			Original Haxe 2.10 Port: Masadow
 * 			Second Haxe Port: Tiago Ling Alexandre
 */
class Shadow extends FlxSprite
{	

	private var owner:AxonometricSprite;
	private var mywidth:Float;
	private var myheight:Float;
	private var shadow_size_steps:Int;
	private var MaxHeight:Float;
	
	/*
	 * the current drop size
	 */ 
	public var dropsize:Float;
	
	/**
	 * contructor
	 * 
	 * @param owner the owner of the shadow
	 * 
	 */ 
	public function new(owner:AxonometricSprite, shadowGfx:BitmapData, gfxWidth:Int, gfxHeight:Int, numFrames:Int)
	{
		super();

		loadGraphic(shadowGfx, true, true, gfxWidth, gfxHeight);
		shadow_size_steps = numFrames;

		for (i in 0...shadow_size_steps) 
		{				
			addAnimation(i + "", [i], 0, false);
		}			
		mywidth	= gfxWidth;
		myheight = gfxHeight;
		width = 0;
		height = 0;
		MaxHeight = 300;
		dropsize = 0;

		this.offset.x = (mywidth  - width) / 2;
		this.offset.y = (myheight - height) / 2;
					
		if (owner != null)
		{
			owner.offset.x += this.offset.x;
			owner.offset.y += this.offset.y;						
		}			
		this.owner=owner;
		active = true;
	}
	
	override public function update():Void 
	{
		owner.moveOrder();
		super.update();
	}
			
	/**
	 * sets the size of the shadow
	 * 
	 * @param jumpHeight the size of the jummp
	 * 
	 * 
	 */
	public function shadowSize(jumpHeight:Float):Void 
	{			
		jumpHeight = (jumpHeight <= 0) ? 0 : jumpHeight;
		jumpHeight = (jumpHeight > MaxHeight) ? MaxHeight : jumpHeight;
		play((Math.floor((jumpHeight * (shadow_size_steps - 1)) / MaxHeight)) + "");
	}

	/**
	 * check the drop, of the shaeow
	 * 
	 * @param dropsize the size of the drop
	 */
	public function walldrop(dropsize:Float):Bool 
	{
		var nudge:Float = 0;
		if (dropsize > 0)
		{
			this.dropsize = dropsize;
			this.y += dropsize;			
			this.y += nudge;
			owner.jumping = true;
			owner.jumpHeight += dropsize;
			owner.jump_now(0, 320);
			return true;
		}
		else if (dropsize < 0) 
		{				
			if (owner.jumpHeight > ( -dropsize)) 
			{
				this.dropsize=dropsize;
				this.y += dropsize;
				this.y -= nudge;
				owner.jumpHeight += dropsize;
				owner.jump_now(0, 320);
				return true;
			}
		}
		return false;			
	}
}