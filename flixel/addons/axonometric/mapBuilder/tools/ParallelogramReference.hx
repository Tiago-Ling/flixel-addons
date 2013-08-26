package flixel.addons.axonometric.mapBuilder.tools ;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.*;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxColor;
import flixel.util.loaders.CachedGraphics;

/**
 * A reference to the transformed images used in ParallelogramRendering, it helps reduce the amount of repeated information between nodes.
 * 
 * @author Miguel Angel Piedras Carrillo
 */
class ParallelogramReference 
{		
		
	private var showboundingboxes:Bool = false;
	private var hideTile:Bool = false;
	private var showmytiles:Bool = false;
	
	/**
	 * sets the debugging on or off
	 */
	public var tilemapdebug:Bool = false;
	
	/**
	 * Vector that tells the direction of the first axis, it is related with the width of the tile
	 */
	public var AxisA:Point;
	
	/**
	 * Vector that tells the direction of the first axis, it is related with the height of the tile
	 */
	public var AxisB:Point;
	
	/**
	 * Generated Point
	 */
	public var Generated:Point;
		
	/**
	 * UpperLeft corner
	 */		
	public var UpperLeft:Point;
	
	/**
	 *LowerRight corner
	 */
	public var LowerRight:Point;
	
	/**
	 * UpperRight corner
	 */
	public var UpperRight:Point;
	
	/**
	 * LowerLeft corner
	 */
	public var LowerLeft:Point;	
	
	/**
	 * height of the rectangle that has the tile
	 */
	public var Rectanglewidht:Int;
	
	/**
	 * widht of the rectangle that has the tile
	 */
	public var Rectangleheight:Int;	
	
	/**
	 * Paralelogram Tiles reference
	 */
	public var ParalelogramTiles:BitmapData;
	
	/**
	 * moodle of AxisA
	 */
	public var a:Int;
	
	/**
	 * moodle of AxisB
	 */
	public var b:Int;	
	
	/**
	 * unitary vector of AxisA
	 */
	public var axA:Point;
	
	/**
	 * unitary vector of  AxisB
	 */
	public var axB:Point;

	/*
	 * tells to use a positive angle on the rendering
	 */ 
	public var positiveAngle:Bool = false;
	
	/*
	 * tells to rotate the tiles on the rendering
	 */ 
	public var rotatetile:Bool = false;
	
	/*
	 * tells to inver the tile on the rendering
	 */ 
	public var inverttile:Bool = false;
	
	/*
	 * original tilemap
	 */ 
	public var _tiles:BitmapData;
		
	/**
	 * Initialices the reference with the selected debugging options
	 * 
	 * @param	tilemapdebug				sets the reference in debugging mode
	 * @param	showboundingboxes			shows the bounding boxes of each tile
	 * @param	hideTile					hides each tile
	 * @param	showmytiles					shows the generated image on stage
	 */		
	public function new(tilemapdebug:Bool = false, showboundingboxes:Bool = false, hideTile:Bool = false, showmytiles:Bool = false)
	{
		this.tilemapdebug = tilemapdebug;
		this.showboundingboxes = showboundingboxes;
		this.hideTile = hideTile;
		this.showmytiles = showmytiles;
	}

	/**
	 * Creates the shape of the reference
	 * 
	 * @param	alpha			first angle, measured towards negative Y(positive on regular trig)
	 * @param	a				distance of the first axis
	 * @param	beta			second angle, measured towards alpha
	 * @param	b				distance of the second axix
	 * @param	_tiles			original tilemap
	 * @param	positiveAngle	tells to use a positive angle on the rendering
	 * @param	rotatetile		tells to rotate the tiles on the rendering
	 * @param	inverttile		tells to inver the tile on the rendering
	 */
	public function SetParalelogram(alpha:Float, a:Int, beta:Float, b:Int, _tiles:BitmapData, positiveAngle:Bool = false, rotatetile:Bool = false, inverttile:Bool = false):Void 
	{			
		this._tiles = _tiles;
		this.positiveAngle = positiveAngle;
		this.rotatetile = rotatetile;
		this.inverttile = inverttile;
		
		// i learned trig on up y being positive, this just makes mental calculation easier for me
		alpha *= -1;
		beta *= -1;						
		axA	= new Point(Math.sin(alpha), -Math.cos(alpha));
		axB	= new Point(Math.sin(alpha + beta), -Math.cos(alpha + beta));
		this.a = a;
		this.b = b;
		//Paralelogram corners
		AxisA = new Point(axA.x * a , axA.y * a);
		AxisB = new Point(axB.x * b , axB.y * b);
		Generated = new Point(AxisA.x + AxisB.x, AxisA.y + AxisB.y);
		UpperLeft = new Point(Math.min(Math.min(AxisA.x, AxisB.x), Math.min(Generated.x, 0)),
								Math.min(Math.min(AxisA.y, AxisB.y), Math.min(Generated.y, 0)));
		
		LowerRight = new Point(Math.max(Math.max(AxisA.x, AxisB.x), Math.max(Generated.x, 0)),
								Math.max(Math.max(AxisA.y, AxisB.y), Math.max(Generated.y, 0)));
		UpperRight = new Point(LowerRight.x , UpperLeft .y);
		LowerLeft = new Point(UpperLeft .x , LowerRight.y);
		Rectanglewidht = Std.int(UpperRight.x - UpperLeft.x + 5);
		Rectangleheight = Std.int(LowerLeft.y  - UpperLeft.y + 5);
		var r:Int = Std.int(_tiles.height / a);
		var c:Int = Std.int(_tiles.width / b);

		ParalelogramTiles = new BitmapData(Math.ceil(Rectanglewidht  * c),
			Math.ceil(Rectangleheight * r), true, 0x00000000);

		Rectanglewidht++;
		Rectangleheight++;
		if (showmytiles)
		{
			FlxG.stage.addChild(new Bitmap(ParalelogramTiles));
		}
		var P:Point	= new Point();
		var rec:Rectangle = new Rectangle(0, 0, a, b);						
		var Buffer:BitmapData = new BitmapData(a, b, true, 0xFF000000);			
		var sk:Skew = new Skew(true, false);			
		var gfx:Graphics = FlxSpriteUtil.flashGfx;
		var Point1:Point = new Point(0, 0);
		var Point2:Point = new Point(0, 0);
		var Point3:Point = new Point(0, 0);
		var Point4:Point = new Point(0, 0);
		var cx:Float = 0;
		var cy:Float = 0;
		
		//variables streaches the tiles a little bit
		var temp:Float;
		var unitaryAtoB:Point = new Point(AxisB.x - AxisA.x, AxisB.y - AxisA.y);
		temp = Math.sqrt(unitaryAtoB.x * unitaryAtoB.x + unitaryAtoB.y * unitaryAtoB.y);
		unitaryAtoB.x = unitaryAtoB.x / temp;
		unitaryAtoB.y = unitaryAtoB.x / temp;
		temp = Math.sqrt(Generated.x * Generated.x + Generated.y * Generated.y);
		var unitaryG:Point = new Point(Generated.x / temp, Generated.y / temp);	
		ParalelogramTiles.lock();
		for (i in 0...r) 
		{
			for (j in 0...c) 
			{
				gfx.clear();
				rec.x = j * a;
				rec.y = i * b;
				cx = -UpperLeft.x + Rectanglewidht * j;
				cy = -UpperLeft.y + Rectangleheight * i;

				Buffer.copyPixels(_tiles, rec, P, null, null, true);

				Point1.x = cx - unitaryG.x;
				Point1.y = cy - unitaryG.y;
				Point2.x = cx + AxisA.x - unitaryAtoB.x;
				Point2.y = cy + AxisA.y - unitaryAtoB.y;
				Point3.x = cx + Generated.x + unitaryG.x;
				Point3.y = cy + Generated.y + unitaryG.y;
				Point4.x = cx + AxisB.x + unitaryAtoB.x;
				Point4.y = cy + AxisB.y + unitaryAtoB.y;
				
				if (!hideTile)
				{
					if (!rotatetile)
					{
						if (!positiveAngle)
						{
							RenderParallelogram(Buffer, sk, Point1, Point2, Point3, Point4);
						}
						else 
						{
							RenderParallelogram(Buffer, sk, Point2, Point1, Point4, Point3);
						}
					}
					else 
					{
						if (!positiveAngle)
						{
							if (!inverttile)
							{
								RenderParallelogram(Buffer, sk, Point2, Point3, Point4, Point1);
							}
							else 
							{
								RenderParallelogram(Buffer, sk, Point3, Point2, Point1, Point4);
							}
						}
						else 
						{
							if (!inverttile)
							{
								RenderParallelogram(Buffer, sk, Point3, Point2, Point1, Point4);
							}
							else 
							{
								RenderParallelogram(Buffer, sk, Point2, Point3, Point4, Point1);
							}								
						}
					}
				}
				
				gfx.clear();
				var linesize:Float = 1;
				if (tilemapdebug)
				{				
					gfx.lineStyle(1, FlxColor.RED, linesize);
					
					gfx.moveTo(cx, cy);			
					
					gfx.lineTo(cx + AxisA.x, cy + AxisA.y);
					
					gfx.lineStyle(1, FlxColor.GREEN, linesize);
					gfx.moveTo(cx, cy);
					gfx.lineTo(cx + AxisB.x, cy + AxisB.y);
					gfx.lineStyle(1, FlxColor.BLUE, linesize);
					gfx.moveTo(cx + AxisA.x, cy + AxisA.y);
					gfx.lineTo(cx + Generated.x, cy + Generated.y);
					gfx.moveTo(cx + AxisB.x, cy + AxisB.y);
					gfx.lineTo(cx + Generated.x, cy + Generated.y);												
				}	
				if (showboundingboxes)
				{
					gfx.lineStyle(1, FlxColor.WHITE, linesize);
					gfx.moveTo(cx + UpperLeft .x, cy + UpperLeft .y);
					gfx.lineTo(cx + UpperRight.x, cy + UpperRight.y);
					gfx.lineTo(cx + LowerRight.x, cy + LowerRight.y);
					gfx.lineTo(cx + LowerLeft .x, cy + LowerLeft .y);
					gfx.lineTo(cx + UpperLeft .x, cy + UpperLeft .y);
				}
				ParalelogramTiles.draw(FlxSpriteUtil.flashGfxSprite);					
			}
		}
		ParalelogramTiles.unlock();				
	}
			
	private function RenderParallelogram(Buffer:BitmapData, sk:Skew, P1:Point, P2:Point, P3:Point, P4:Point):Void 
	{
		var arA = [P1.x, P1.y];
		var arB = [P2.x, P2.y];
		var arC = [P3.x, P3.y];
		var arD = [P4.x, P4.y];
		//TODO: Replace with correct constant
		sk.transformer(arA, arB, arC, arD, Buffer, FlxSpriteUtil.flashGfxSprite,
			Std.int(1.79769313486231e+308), Std.int(1.79769313486231e+308));

		ParalelogramTiles.draw(FlxSpriteUtil.flashGfxSprite);
	}
			
	public function Get2dPos(row:Float, column:Float):Point 
	{
		var c:Float = a * column;
		var r:Float = b * row;

		return  new Point(axA.x * c + axB.x * r, axA.y * c + axB.y * r);
	}
	
	public function destroy():Void
	{			
		AxisA = null;
		AxisB = null;
		Generated = null;
		UpperLeft = null;	
		LowerRight = null;
		UpperRight = null;
		LowerLeft = null;
		ParalelogramTiles = null;
		axA = null;
		axB = null;	
	}			
}