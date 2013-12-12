package flixel.addons.tile.isoXel;
import flixel.tile.FlxTilemapBuffer;
import flixel.FlxCamera;
import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Rectangle;

/**
 * ...
 * @author Masadow
 */
class FlxTilemapBufferIso extends FlxTilemapBuffer
{
	
	override public function new(TileWidth:Int, TileHeight:Int, WidthInTiles:Int, HeightInTiles:Int, Camera:FlxCamera = null, ScaleX:Float = 1.0, ScaleY:Float = 1.0)
	{
		//F*ck this, constructor call needed; Compiler is complaining :( Duplication of flash instiantiation
		super(TileWidth, TileHeight, WidthInTiles, HeightInTiles, Camera, ScaleX, ScaleY);

		#if flash
		_pixels = new BitmapData(Std.int((columns * TileWidth) / 2 + (rows * TileWidth) / 2), Std.int((columns * TileHeight) / 2 + (rows * TileHeight) / 2), true, 0);
		_flashRect = new Rectangle(0, 0, _pixels.width, _pixels.height);
		_matrix = new Matrix();
		#end
	}

	override public function updateColumns(TileWidth:Int, WidthInTiles:Int, ScaleX:Float = 1.0, Camera:FlxCamera = null):Void
	{
		if (WidthInTiles < 0) 
		{
			WidthInTiles = 0;
		}
		
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}

		columns = Math.ceil(Camera.width / (TileWidth * ScaleX)) + 1;
		
		if (columns > WidthInTiles)
		{
			columns = WidthInTiles;
		}
		
		width = Std.int(columns * TileWidth * ScaleX);
	}
	
	override public function updateRows(TileHeight:Int, HeightInTiles:Int, ScaleY:Float = 1.0, Camera:FlxCamera = null):Void
	{
		if (HeightInTiles < 0) 
		{
			HeightInTiles = 0;
		}
		
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		
		rows = Math.ceil(Camera.height / (TileHeight * ScaleY)) + 1;
		
		if (rows > HeightInTiles)
		{
			rows = HeightInTiles;
		}
		
		height = Std.int(rows * TileHeight * ScaleY);
	}
}