package flixel.addons.axonometric.mapBuilder.tools;

import flash.geom.Point;	
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
import flixel.FlxG;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxColor;

/**
 * The axis manager is in charge of the positioning of the items on stage, in reference to the 2D sistem.
 * 
 * @author	AS3 Original: Miguel Ángel Piedras Carrillo; 
 * 			Original Haxe 2.10 Port: Masadow
 * 			Second Haxe Port: Tiago Ling Alexandre
 */
class AxisManager 
{
	/**
	 * the center of the stage in reference to the new 2.5d stage
	 */
	public var center:Point;
	
	/**
	 * vector pointing to the X axis
	 */
	public var axisX:Point;
	
	/**
	 * vector pointing to the Y axis, it's alwais pointing to the negative y axis of the original stage to use its jump physics 
	 */
	public var axisY:Point;
	
	/**
	 * vector pointing to the Z axis
	 */
	public var axisZ:Point;	
	
	/*
	 * descritpor of the block used in the stage
	 */ 		
	public var descriptor:BlockDescriptor;		
	
	/*
	 * first creator angle
	 */ 		
	public var theta:Float;
	
	/*
	 * second creator angle
	 */ 		
	public var phi:Float;	
	
	/*
	 * shared object, reference to the tranformed image that the ground uses
	 */ 
	public var floorReference:ParallelogramReference;
	
	/*
	 * shared object, reference to the tranformed image that the side A uses
	 */ 
	public var sideAReference:ParallelogramReference;
	
	/*
	 * shared object, reference to the tranformed image that the side B uses
	 */ 
	public var sideBReference:ParallelogramReference;	
	
	/**
	 * constructor of the manager
	 * 
	 * @param	Descriptor	block descriptor.
	 * @param	Center   	center of the stge with reference at the 2D stage.
	 */
	public function new(Descriptor:BlockDescriptor, Center:Point)
	{
		this.descriptor = Descriptor;
		this.center	= Center;
	}
			
	/**
	 * gets the equivalent 2D position of the stage given the coordinates of the topography
	 * 
	 * @param	i	row of the topography
	 * @param	j	column of the topography
	 * @param	h	height of the topography
	 */
	public function Get2DLocationFromTopography(i:Float, j:Float, h:Float):Point 
	{
		var x:Float = j * descriptor.BlockWidth + descriptor.BlockWidth / 2;
		var y:Float = -h * descriptor.BlockHeight;
		var z:Float = i * descriptor.BlockDepth + descriptor.BlockDepth / 2;
		var point:Point = Get2dCord(x, y, z);
		point.x += center.x;
		point.y += center.y;
		return point;
	}
	
	/**
	 * gets the equivalent 2D position of a 3D point.
	 * 
	 * @param	x	coordinate on the x axis
	 * @param	y	coordinate on the y axis
	 * @param	z	coordinate on the z axis
	 */
	public function Get2dCord(x:Float, y:Float , z:Float):Point 
	{
		return new Point(Math.round(x * axisX.x + y * axisY.x + z * axisZ.x), Math.round(x * axisX.y + y * axisY.y + z * axisZ.y));
	}

	/**
	 * sets the shape of the axis
	 * 
	 * @param	theta	the angle of the first plane
	 * @param	phi		the angle of the second plane
	 * @param	debug	sets up the debugging mode on
	 */
	public function setAxis(theta:Float, phi:Float, debug:Bool = false):Void 
	{
		this.theta = theta;
		this.phi = phi;
		
		//y is negative "up" in computers, so a "computer positve angle" is a trig negative
		axisX = new Point(Math.sin(-theta), -Math.cos(-theta));
		axisZ = new Point(Math.sin(-theta -phi), -Math.cos(-theta -phi));
		axisY = new Point(0, 1);
		
		sideBReference = new ParallelogramReference(debug);
		sideBReference.SetParalelogram(0, descriptor.BlockHeight, theta, descriptor.BlockWidth, FlxG.bitmap.add(descriptor.TilemapWidthHeight).bitmap, false, true, false);

		sideAReference = new ParallelogramReference(debug);
		sideAReference.SetParalelogram(0, descriptor.BlockHeight, theta+phi, descriptor.BlockDepth, FlxG.bitmap.add(descriptor.TilemapDepthHeight).bitmap, true, true, true);
		
		floorReference = new ParallelogramReference(debug);
		floorReference.SetParalelogram(theta, descriptor.BlockWidth, phi, descriptor.BlockDepth, FlxG.bitmap.add(descriptor.TilemapWidthDepth).bitmap, false, false, false);
		
		if (debug)
		{
			var gfx:Graphics = FlxSpriteUtil.flashGfx;
			var dist:Float = 1500;
			var linesize:Float = 1;
			gfx.lineStyle(1, FlxColor.WHITE, linesize);
			gfx.moveTo((center.x) * FlxG.camera.zoom , (center.y) * FlxG.camera.zoom);
			gfx.lineTo((center.x + axisX.x * dist) * FlxG.camera.zoom, (center.y + axisX.y * dist) * FlxG.camera.zoom);
			gfx.moveTo((center.x) * FlxG.camera.zoom, (center.y) * FlxG.camera.zoom);
			gfx.lineTo((center.x - axisY.x * dist) * FlxG.camera.zoom, (center.y - axisY.y * dist) * FlxG.camera.zoom);
			gfx.moveTo((center.x) * FlxG.camera.zoom , (center.y) * FlxG.camera.zoom);
			gfx.lineTo((center.x + axisZ.x * dist) * FlxG.camera.zoom, (center.y + axisZ.y * dist) * FlxG.camera.zoom);
			
			var Axis:BitmapData = new BitmapData(Std.int(FlxG.stage.width), Std.int(FlxG.stage.height), true, 0x00000000);
			Axis.draw(FlxSpriteUtil.flashGfxSprite);
			FlxG.stage.addChild(new Bitmap(Axis));
		}
	}
	
	/**
	 * Destroys this element, freeing memeory.
	 * 
	 */		
	public function destroy():Void 
	{
		descriptor.destroy();
		sideBReference.destroy();
		sideAReference.destroy();
		sideBReference.destroy();
		center = null;
		axisX = null;
		axisY = null;
		axisZ = null;
	}

}