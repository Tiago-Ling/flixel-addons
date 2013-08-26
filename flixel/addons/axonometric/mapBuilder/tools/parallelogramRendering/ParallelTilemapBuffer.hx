package flixel.addons.axonometric.mapBuilder.tools.parallelogramRendering;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Matrix;
import flixel.FlxCamera;
import flixel.FlxG;

/**
 * A modified version of FlxTilemapBuffer (@author Adam Atomic), modiffied to render parallelograms
 * 
 * @author	AS3 Original: Miguel Ángel Piedras Carrillo; 
 * 			Original Haxe 2.10 Port: Masadow
 * 			Second Haxe Port: Tiago Ling Alexandre
 */
class ParallelTilemapBuffer
{
	/**
	 * The current X position of the buffer.
	 */
	public var x:Float;
	
	/**
	 * The current Y position of the buffer.
	 */
	public var y:Float;
	
	/**
	 * The width of the buffer(usually just a few tiles wider than the camera).
	 */
	public var width:Float;
	
	/**
	 * The height of the buffer(usually just a few tiles taller than the camera).
	 */
	public var height:Float;
	
	/**
	 * Whether the buffer needs to be redrawn.
	 */
	public var dirty:Bool;
	
	/**
	 * How many rows of tiles fit in this buffer.
	 */
	public var rows:Int;
	
	/**
	 * How many columns of tiles fit in this buffer.
	 */
	public var columns:Int;

	public var forceComplexRender:Bool = false;

	#if flash
	private var _pixels:BitmapData;	
	private var _flashRect:Rectangle;
	private var _matrix:Matrix;
	#end

	/**
	 * Instantiates a new camera-specific buffer for storing the visual tilemap data.
	 *  
	 * @param TileWidth		The width of the tiles in this tilemap.
	 * @param TileHeight	The height of the tiles in this tilemap.
	 * @param WidthInTiles	How many tiles wide the tilemap is.
	 * @param HeightInTiles	How many tiles tall the tilemap is.
	 * @param Camera		Which camera this buffer relates to.
	 */
	public function new (TileWidth:Int, TileHeight:Int, WidthInTiles:Int, HeightInTiles:Int, Camera:FlxCamera = null, maxWidth:Int = 0, maxHeight:Int = 0)
	{						
		//im not so sure how this works, if you know please be my guest and modify this
		
		/*if(Camera==null)
			Camera=FlxG.camera;
		columns=FlxU.ceil(Camera.width/TileWidth)+1;
		if(columns>WidthInTiles)
			columns=WidthInTiles;
		rows=FlxU.ceil(Camera.height/TileHeight)+1;
		if(rows>HeightInTiles)
			rows=HeightInTiles;*/

		columns = WidthInTiles;
		rows = HeightInTiles;

		#if flash
		_pixels = new BitmapData(maxWidth > 0 ? maxWidth : columns * TileWidth, maxHeight > 0 ? maxHeight : rows	* TileHeight, true, 0);
		width = _pixels.width;
		height = _pixels.height;
		_flashRect = new Rectangle(0, 0, width, height);
		_matrix = new Matrix();
		#else
		width = Std.int(columns * TileWidth);
		height = Std.int(rows * TileHeight);
		#end
		dirty = true;
	}
	
	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		#if flash
		_pixels = null;
		_matrix = null;
		#end
	}
	
	/**
	 * Fill the buffer with the specified color.
	 * Default value is transparent.
	 * 
	 * @param	Color	What color to fill with, in 0xAARRGGBB hex format.
	 */
	#if flash
	public function fill(Color:Int = 0):Void
	{
		_pixels.fillRect(_flashRect, Color);
	}
	
	public var pixels(get_pixels, never):BitmapData;

	/**
	 * Read-only, nab the actual buffer<code>BitmapData</code>object.
	 * 
	 * @return	The buffer bitmap data.
	 */
 	private function get_pixels():BitmapData
	{
		return _pixels;
	}
	
	/**
	 * Just stamps this buffer onto the specified camera at the specified location.
	 * 
	 * @param	Camera		Which camera to draw the buffer onto.
	 * @param	FlashPoint	Where to draw the buffer at in camera coordinates.
	 */
	public function draw(Camera:FlxCamera, FlashPoint:Point):Void
	{
		if (!forceComplexRender) 
		{
			Camera.buffer.copyPixels(_pixels, _flashRect, FlashPoint, null, null, true);
		}
		else 
		{
			_matrix.identity();
			_matrix.translate(FlashPoint.x, FlashPoint.y);
			Camera.buffer.draw(_pixels, _matrix);
		}
	}
	#end
}