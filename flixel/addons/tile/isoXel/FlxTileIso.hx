package flixel.addons.tile.isoXel;
import flixel.FlxObject;
import openfl.utils.Float32Array;
import flixel.tile.FlxBaseTile;

/**
 * A simple helper object for <code>FlxTilemap</code> that helps expand collision opportunities and control.
 * You can use <code>FlxTilemap.setTileProperties()</code> to alter the collision properties and
 * callback functions and filters for this object to do things like one-way tiles or whatever.
 */
class FlxTileIso extends FlxBaseTile<FlxTilemapIso>
{
	public var tileDepth: Float;
	public var tileHeight: Float;
	
	/**
	 * Instantiate this new tile object.  This is usually called from <code>FlxTilemap.loadMap()</code>.
	 * 
	 * @param 	Tilemap			A reference to the tilemap object creating the tile.
	 * @param 	Index			The actual core map data index for this tile type.
	 * @param 	Width			The width of the tile.
	 * @param 	Height			The height of the tile.
	 * @param 	Visible			Whether the tile is visible or not.
	 * @param 	AllowCollisions	The collision flags for the object.  By default this value is ANY or NONE depending on the parameters sent to loadMap().
	 */
	public function new(Tilemap:FlxTilemapIso, Index:Int, Width:Float, Depth:Float, Height:Float, Visible:Bool, AllowCollisions:Int)
	{
		super(Tilemap, Index, Width, Depth, Visible, AllowCollisions);

		tileDepth = Depth;
		tileHeight = Height;
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}
}